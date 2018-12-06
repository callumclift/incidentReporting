import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List<String> photos;

  ImageViewer({this.photos});

  Widget _buildCarousel(
      BuildContext context, int carouselIndex, List<String> photos) {
    return Column(
      children: <Widget>[
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: 350.0,
          child: PageView.builder(
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
      int photoIndex, List<String> photos) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),

            ),
            height: 350.0,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: FadeInImage(
              placeholder: AssetImage('assets/placeholder.png'),
              image: NetworkImage(photos[photoIndex]),
              height: 350.0,
              fit: BoxFit.cover,
            ),),
            

          ),
          Positioned(
            top: 325.0,
            left: 25.0,
            right: 25.0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildDots(photoIndex),
              ),
            ),
          )
        ],
      ),
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
      dots.add(i == photoIndex ? _activePhoto() : _inactivePhoto());
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
      padding: EdgeInsets.symmetric(vertical: 10.0),
      itemBuilder: (BuildContext context, int index) {
        return _buildCarousel(context, index ~/ 2, photos);
      },
    );
  }
}
