import 'package:flutter/material.dart';
import '../widgets/helpers/app_side_drawer.dart';
import '../widgets/products/image_carousel.dart';
import '../widgets/products/image_grid.dart';

class SideScroll extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SideScrollState();
  }
}

class SideScrollState extends State<SideScroll> {

  final List<String> _photos = [
    'assets/testimages/testimage1.jpg',
    'assets/testimages/testimage2.jpg',
    'assets/testimages/testimage3.jpg',
    'assets/testimages/testimage4.jpg',
    'assets/testimages/testimage2.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Carousel'),
          centerTitle: true,
        ),
        drawer: SideDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ImageCarousel(photos: _photos),
            ImageGrid(),
          ],
        ));
  }
}
