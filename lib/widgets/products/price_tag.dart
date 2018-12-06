import 'package:flutter/material.dart';


class PriceTag extends StatelessWidget {

  final String _price;

  PriceTag(this._price);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      padding:
      EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      child: Text('\$$_price',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}