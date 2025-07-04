import 'package:carousel_slider/carousel_slider.dart';
import 'package:destination_user/models/RoomModel.dart';
import 'package:destination_user/models/hotelModel.dart';
import 'package:destination_user/screens/RoomWidget.dart';
import 'package:destination_user/utils/AppColor.dart';
import 'package:destination_user/utils/Extensions/Widget_extensions.dart';
import 'package:destination_user/utils/Extensions/context_extensions.dart';
import 'package:destination_user/utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/Commons.dart';
import '../../utils/Extensions/text_styles.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import 'ZoomImageScreen.dart';

class HotelViewScreen extends StatefulWidget {
  final HotelModel hotelModel;

  HotelViewScreen({required this.hotelModel});

  @override
  HotelViewScreenState createState() => HotelViewScreenState();
}

class HotelViewScreenState extends State<HotelViewScreen> {
  bool isLast = true;

  int filterRatingLength = 6;
  int selectedRatingIndex = 0;
  bool isReviewExist = false;
  int categoryIndex = 0;

  List images = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({double? rating}) async {
    appStore.setLoading(true);
    images.add(widget.hotelModel.image);
    images.addAll(widget.hotelModel.secondaryImages!);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.hotelModel.name.validate())),
        body: Observer(builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  child: CarouselSlider.builder(
                    carouselController: CarouselController(),
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int itemIndex,
                        int pageViewIndex) {
                      return GestureDetector(
                        onTap: () {
                          ZoomImageScreen(image: images[itemIndex])
                              .launch(context);
                        },
                        child: cachedImage(images[itemIndex],
                                width: context.width(), fit: BoxFit.cover)
                            .cornerRadiusWithClipRRect(12)
                            .expand()
                            .paddingOnly(left: 6, right: 6),
                      );
                    },
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (i, v) {
                        // selectedCatId = widget.categoryPlaceModel[categoryIndex].category!.id;
                        categoryIndex = i;
                        // placeIndex = 1;
                        //setState(() {});
                      },
                      initialPage: categoryIndex,
                      height: context.width(),
                      viewportFraction: 1,
                    ),
                  ),
                ),
                15.height,
                Container(
                  decoration: BoxDecoration(
                      color: cardDarkColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        8.height,
                        Row(crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(widget.hotelModel.name.validate(),
                                  style: boldTextStyle(
                                    size: 17,
                                  )),
                            ),
                            Text(
                              "Like a ${widget.hotelModel.starId!.validate().toString().substring(0, 1)}"
                              "⭐",
                              style: secondaryTextStyle(),
                            ),
                          ],
                        ),
                        4.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${widget.hotelModel.address.toString()}",
                                      style: secondaryTextStyle()),
                                  4.height,
                                  Text(
                                      "${widget.hotelModel.distance!.toString()} km away",
                                      style: primaryTextStyle()),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                MapsLauncher.launchCoordinates(
                                    widget.hotelModel.latitude.validate(),
                                    widget.hotelModel.longitude.validate());
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.location_pin,
                                    size: 18, color: Colors.white),
                                radius: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                15.height,
                Container(
                  decoration: BoxDecoration(
                      color: cardDarkColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        8.height,
                        Text(widget.hotelModel.description.validate(),
                            style: primaryTextStyle()),
                      ],
                    ),
                  ),
                ),
                60.height
              ],
            ),
          );
        }),
      floatingActionButton: GestureDetector(onTap: () {
        RoomWidget(widget.hotelModel.id).launch(context);
      },child: Container(width: MediaQuery.of(context).size.width * 0.9,decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: primaryColor),padding: EdgeInsets.all(12),child: Text("Select Rooms",textAlign: TextAlign.center,style: primaryTextStyle()),)),
    );
  }
}
