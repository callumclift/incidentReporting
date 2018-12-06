import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../models/product.dart';
import '../../models/product1.dart';

import '../../scoped_models/main.dart';


class Products extends StatelessWidget {

  Widget _buildProductList(List<Product1> products) {
    Widget productCards;

    if (products.length > 0) {
      productCards = ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              ProductCard(products[index]),
          itemCount: products.length);
    } else {
      productCards = Center(
        child: Text('No Products found please add some'),
      );
    }

    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    //you can create the conditions inside the widget of you can do it as
    //a method in the class
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      return _buildProductList(model.displayedProducts1);
    });
  }
}
