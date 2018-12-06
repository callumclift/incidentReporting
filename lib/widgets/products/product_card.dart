import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/product.dart';
import '../../models/product1.dart';
import '../../scoped_models/main.dart';

class ProductCard extends StatelessWidget {
  final Product1 product;

  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: TitleDefault(product.title),
            ),
            Flexible(child: SizedBox(
              width: 8.0,
            ),),
            Flexible(child: PriceTag(product.price.toString()),),
          ],
        ));
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: () {
              model.selectProduct(product.id);
              Navigator.pushNamed<bool>(context, '/productview/' + product.id)
                  .then((_) => model.selectProduct(null));
            },
          ),
          IconButton(
            icon: Icon(product.isFavourite
                ? Icons.favorite
                : Icons.favorite_border),
            color: Colors.red,
            onPressed: () {
              // model.selectProduct(product.id); => Don't do this anymore
              model.toggleProductFavoriteStatus1(product); // Pass the product used in this card
            },
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/food.jpg'),
              image: NetworkImage(product.images[0]),
              height: 300.0,
              fit: BoxFit.cover,
            ),
          ),
          _buildTitlePriceRow(),
          SizedBox(height: 10.0,),
          AddressTag(product.location.address),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
