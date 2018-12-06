import 'package:flutter/material.dart';

class Slide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SlideState();
  }
}

class SlideState extends State<Slide> {
  int _counter = 0;

  int photoIndex = 0;

  List<String> photos = [
    'assets/testimages/testimage1.jpg',
    'assets/testimages/testimage2.jpg',
    'assets/testimages/testimage3.jpg',
    'assets/testimages/testimage4.jpg',
  ];



  void _previousImage() {
    setState(() {
      photoIndex = photoIndex > 0 ? photoIndex - 1 : 0;
    });
  }

  void _nextImage() {
    setState(() {
      photoIndex = photoIndex < photos.length - 1 ? photoIndex + 1 : photoIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        resizeDuration: null,
        onDismissed: (DismissDirection direction) {
          if(direction == DismissDirection.endToStart){
            _nextImage();
          } else if (direction == DismissDirection.startToEnd){
            _previousImage();
          }
        },
        key: new ValueKey(photoIndex),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              image: DecorationImage(
                  image: AssetImage(photos[photoIndex]),
                  fit: BoxFit.cover)),
          height: 400.0,
          width: 300.0,
        ),
      );
    ;
  }
}


