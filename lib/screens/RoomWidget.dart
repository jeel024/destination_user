import 'package:carousel_slider/carousel_slider.dart';
import 'package:destination_user/screens/BookRoomWidget.dart';
import 'package:destination_user/utils/Extensions/Widget_extensions.dart';
import 'package:destination_user/utils/Extensions/context_extensions.dart';
import 'package:destination_user/utils/Extensions/int_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../utils/Extensions/string_extensions.dart';

import '../main.dart';
import '../models/RoomModel.dart';
import '../utils/AppColor.dart';
import '../utils/Common.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import 'ZoomImageScreen.dart';

class RoomWidget extends StatefulWidget {
  final hotelId;

  RoomWidget(this.hotelId);

  @override
  State<RoomWidget> createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Room"),
      ),
      body: FutureBuilder<List<RoomModel>>(
        future: roomService.getRoomsByHotelId(id: widget.hotelId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if ((snapshot.data ?? []).isEmpty)
              return emptyWidget(text: language.noItemsInFavourite);
            return ListView.builder(
              shrinkWrap: true,
              itemCount: (snapshot.data ?? []).length,
              padding: EdgeInsets.only(left: 2, top: 16, right: 2),
              itemBuilder: (_, index) {
                RoomModel room = (snapshot.data ?? [])[index];
                List images = [];
                images.add(room.image);
                images.addAll(room.secondaryImages ?? []);
                int categoryIndex = 0;

                return AnimationConfiguration.staggeredList(
                  duration: Duration(milliseconds: 800),
                  position: index,
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    verticalOffset: 20.0,
                    child: FadeInAnimation(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: cardDarkColor),
                        child: GestureDetector(
                          onTap: () {
                            // PlaceDetailScreen(placeData: place, isRequestPlace: isRequestPlace).launch(context);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 200,
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
                                          .cornerRadiusWithClipRRect(10)
                                          .expand()
                                    );
                                  },
                                  options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: false,
                                    onPageChanged: (i, v) {
                                      categoryIndex = i;
                                    },
                                    initialPage: categoryIndex,
                                    height: context.width(),
                                    viewportFraction: 1,
                                  ),
                                ),
                              ),
                              10.height,
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                        room.name
                                            .toString()
                                            .toUpperCase(),
                                        style: boldTextStyle(
                                            color: whiteColor, size: 18),
                                        maxLines: 2),
                                  ),
                                  6.height,
                                  Wrap(
                                    children: List.generate(
                                        (room.facilities ?? []).length,
                                        (index) => Container(padding: EdgeInsets.all(4),margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),border: Border.all(color: primaryColor)),
                                          child: Row(mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("•"),
                                                  5.width,
                                                  Text(
                                                    room.facilities![
                                                        index],
                                                    style:
                                                        primaryTextStyle(
                                                            size: 12),
                                                  )
                                                ],
                                              ),
                                        )),
                                  ),
                                ],
                              ),
                              Divider(),
                              8.height,
                              Row(
                                children: [
                                  2.width,
                                  Icon(Icons.currency_rupee,
                                      color: whiteColor, size: 20),
                                  4.width,
                                  Text(
                                    room.price.toString(),
                                    style:
                                        secondaryTextStyle(color: whiteColor),
                                    maxLines: 2,
                                  ).expand(),
                                  Spacer(),
                                  GestureDetector(onTap: () {
                                    BookRoomWidget(hotelId: widget.hotelId,roomId: room.id,amount: room.price,).launch(context);
                                  },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text(" Select Room ",style: primaryTextStyle()),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ).paddingAll(8),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return errorWidget(text: snapshot.error.toString());
          } else {
            return loaderWidget();
          }
        },
      ),
    );
  }
}
