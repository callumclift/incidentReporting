import 'package:flutter/material.dart';
import 'dart:typed_data';

class ImageViewer extends StatelessWidget {
  final List<Uint8List> photos;

  ImageViewer({this.photos});

  Widget _buildCarousel(
      BuildContext context, int carouselIndex, List<Uint8List> photos) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: photos.length == 1 ? deviceHeight * 0.45 : deviceHeight * 0.5,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,

            // store this controller in a State to save the carousel scroll position
            controller: PageController(viewportFraction: 1.0),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(
                  context, carouselIndex, itemIndex, photos);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, int carouselIndex,
      int photoIndex, List<Uint8List> photos) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final imageHeight = deviceHeight * 0.45;

    return Column(
      children: <Widget>[
        Container(
          height: imageHeight,
          width: double.infinity,
          child: Image.memory(
            photos[photoIndex],
            height: imageHeight,
            fit: BoxFit.contain,
          ),
        ),
        photos.length == 1
            ? Container()
            : SizedBox(
                height: 10.0,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildDots(photoIndex),
        ),
      ],
    );
  }

  Widget _inactivePhoto() {
    return new Container(
        child: new Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
      child: Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(4.0)),
      ),
    ));
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, spreadRadius: 0.0, blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  List<Widget> _buildDots(int photoIndex) {
    List<Widget> dots = [];

    for (int i = 0; i < photos.length; ++i) {
      if (photos.length > 1) {
        dots.add(i == photoIndex ? _activePhoto() : _inactivePhoto());
      }
    }

    return dots;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: 1,
      //padding: EdgeInsets.symmetric(vertical: 10.0),
      itemBuilder: (BuildContext context, int index) {
        return _buildCarousel(context, index ~/ 2, photos);
      },
    );
  }
}
