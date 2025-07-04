import 'dart:io';
import 'dart:math';

import 'package:destination_user/models/BookRoomModel.dart';
import 'package:destination_user/utils/Extensions/Colors.dart';
import 'package:destination_user/utils/Extensions/Widget_extensions.dart';
import 'package:destination_user/utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../main.dart';
import '../pdf/model/customer_supplier.dart';
import '../pdf/model/invoice.dart';
import '../pdf/pdf_invoice_api.dart';
import '../services/FileStorageService.dart';
import '../utils/AppColor.dart';
import '../utils/AppConstant.dart';
import '../utils/Common.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';

class BookRoomWidget extends StatefulWidget {
  final roomId, hotelId,amount;

  const BookRoomWidget(
      {required this.hotelId, required this.roomId, required this.amount, super.key});

  @override
  State<BookRoomWidget> createState() => _BookRoomWidgetState();
}

class _BookRoomWidgetState extends State<BookRoomWidget> {
  TextEditingController guestNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController checkInDateController = TextEditingController();
  TextEditingController checkOutDateController = TextEditingController();
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int days = 1;
  int qtyId = 1;

  XFile? primaryImage;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    appStore.setLoading(false);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_1lKla9TIeLGNsr',
      'amount': (widget.amount * qtyId * days) * 100,
      'name': guestNameController.text,
      'description': 'Payment',
      'prefill': {'contact': mobileController.text, 'email': emailController.text},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {

    appStore.setLoading(true);

    BookRoomModel bookRoomModel = BookRoomModel();

    bookRoomModel.name = guestNameController.text;
    bookRoomModel.email = emailController.text;
    bookRoomModel.mobile = mobileController.text;
    bookRoomModel.checkInDate = checkInDate;
    bookRoomModel.checkOutDate = checkOutDate;
    bookRoomModel.paymentId = response.paymentId;
    bookRoomModel.hotelId = widget.hotelId;
    bookRoomModel.quantity = qtyId;
    bookRoomModel.roomId = widget.roomId;
    bookRoomModel.amount = widget.amount * qtyId * days;
    bookRoomModel.createdAt = DateTime.now();

    if (primaryImage != null) {
      await uploadFile(bytes: await primaryImage!.readAsBytes(), prefix: mPlacesStoragePath).then((path) async {
        bookRoomModel.proof = path;
      }).catchError((e) {
        toast(e.toString());
      });
    }

    await bookRoomService.addDocument(bookRoomModel.toJson()).then((value) async {
      appStore.setLoading(false);

      finish(context);
      toast("Room Booked");
      genratePdf();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Failed: " +

          response.message.toString(),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName.toString());
  }

  genratePdf(){
    final date = DateTime.now();

    final invoice = Invoice(
      supplier: Supplier(
        name: widget.hotelId,
        address: widget.roomId,
        paymentInfo: 'https://paypal.me/sarahfieldzz',
      ),
      customer: Customer(
        name: guestNameController.text,
        address: emailController.text,
      ),
      info: InvoiceInfo(
        date: date,
        dueDate: checkOutDate!,
        description: checkInDate.toString(),
        number: '${DateTime.now().year}-9999',
      ),
      items: List.generate(qtyId, (index) => InvoiceItem(
        description: 'DLX ${Random().nextInt(50)}',
        guestDetail: guestNameController.text,
        quantity: 1,
        vat: 0.19,
        unitPrice: double.parse(widget.amount.toString()),
      )),
    );

    PdfInvoiceApi.generate(invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(""),),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Guest Name", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: guestNameController,
                    autoFocus: false,
                    textFieldType: TextFieldType.NAME,
                    keyboardType: TextInputType.name,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Guest Name"),
                  ),
                  16.height,
                  Text("Mobile Number", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: mobileController,
                    autoFocus: false,
                    textFieldType: TextFieldType.PHONE,
                    keyboardType: TextInputType.phone,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Mobile Number"),
                  ),
                  16.height,
                  Text("Email", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: emailController,
                    autoFocus: false,
                    textFieldType: TextFieldType.EMAIL,
                    keyboardType: TextInputType.emailAddress,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Email"),
                  ),
                  16.height,

                  Text("Check In Date", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: checkInDateController,
                    onTap: () async {
                       checkInDate = await showDatePicker(context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 15)),
                          initialDate: DateTime.now());

                      checkInDateController.text =
                          checkInDate!.day.toString() + "-" + checkInDate!.month.toString() + "-" +
                              checkInDate!.year.toString();
                      setState(() {});
                    },
                    autoFocus: false,
                    readOnly: true,
                    textFieldType: TextFieldType.USERNAME,
                    keyboardType: TextInputType.text,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Select Date"),
                  ),
                  16.height,
                  Text("Check Out Date", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: checkOutDateController,
                    onTap: () async {
                      if(checkInDate != null) {
                        checkOutDate = await showDatePicker(context: context,
                            firstDate: checkInDate!.add(Duration(days: 1)),
                            lastDate: DateTime.now().add(Duration(days: 15)),
                            initialDate: checkInDate!.add(Duration(days: 1)));
                        checkOutDateController.text =
                            checkOutDate!.day.toString() + "-" +
                                checkOutDate!.month.toString() + "-" +
                                checkOutDate!.year.toString();

                        days = checkOutDate!.difference(checkInDate!).inDays;
                        setState(() {});
                      }
                      else{
                        toast("Please Select CheckIn Date");
                      }
                    },
                    autoFocus: false,
                    readOnly: true,
                    textFieldType: TextFieldType.USERNAME,
                    keyboardType: TextInputType.text,
                    errorThisFieldRequired: errorThisFieldRequired,
                    decoration: commonInputDecoration(hintText: "Select Date"),
                  ),
                  16.height,
                  Text("Number Of Rooms", style: primaryTextStyle()),
                  8.height,
                  DropdownButtonFormField<int>(
                    dropdownColor: Theme
                        .of(context)
                        .cardColor,
                    value: qtyId,
                    decoration: commonInputDecoration(),
                    items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map<
                        DropdownMenuItem<int>>((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.toString(), style: primaryTextStyle()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      qtyId = value!;
                      setState(() {});
                    },
                    validator: (s) {
                      if (s == null) return errorThisFieldRequired;
                      return null;
                    },
                  ),
                  16.height,
                  Text("Upload Identity Proof", style: primaryTextStyle()),
                  8.height,
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: radius(defaultRadius),
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButtonWidget(
                              child: Text("Browse", style: primaryTextStyle(
                                  color: Colors.white)),
                              color: primaryColor.withOpacity(0.5),
                              hoverColor: primaryColor,
                              splashColor: primaryColor,
                              focusColor: primaryColor,
                              elevation: 0,
                              onTap: () async {
                                primaryImage = await ImagePicker().pickImage(
                                    source: ImageSource.gallery, imageQuality: 100);
                                setState(() {});
                              },
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                            ),
                            16.width,
                            Text("Clear", style: primaryTextStyle(
                                decoration: TextDecoration.underline))
                                .onTap(() async {
                              if (primaryImage != null) {
                                primaryImage = null;
                              }
                              setState(() {});
                            }),
                          ],
                        ),
                        8.height,
                        getPrimaryImage(),

                      ],
                    ),
                  ),
                  10.height,

                ],),
              ),
            ),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
            color: cardDarkColor),
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min,
            children: [
              Text( "₹ "+ (widget.amount * qtyId * days).toString(),style: boldTextStyle(),),
              Text("$days Days",style: primaryTextStyle(size: 12),),
            ],
          ),
          Spacer(),
          GestureDetector(onTap: () {
            if (formKey.currentState!.validate()) {
              if (primaryImage != null ) {
                //genratePdf();
                 openCheckout();
              } else {
                toast("Please Select Identity Proof");
              }
            }
          },
            child: Container(padding: EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor)),
              child: Text("Pay Now"),),
          )
        ],),
      )
      ,
    );
  }

  Widget getPrimaryImage() {
    if (primaryImage != null) {
      return Image.file(File(primaryImage!.path), height: 100,
          width: 100,
          fit: BoxFit.cover,
          alignment: Alignment.center);
    } else {
      return SizedBox(height: 100);
    }
  }
}


