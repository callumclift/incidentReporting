import 'package:flutter/material.dart';


class TitleDefault extends StatelessWidget {

  final String productTitle;

  TitleDefault(this.productTitle);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    // TODO: implement build
    return Text(
      productTitle,
      softWrap: true,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: deviceWidth > 700 ? 26.0: 14.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'Oswald',
      ),
    );
  }
}