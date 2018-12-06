import 'package:flutter/material.dart';

//import 'package:map_view/map_view.dart';

import 'dart:async';
import '../widgets/ui_elements/title_default.dart';
import '../widgets/products/product_fab.dart';
import '../widgets/products/image_viewer.dart';
import '../models/product.dart';
import '../models/product1.dart';

class ProductView extends StatelessWidget {
  final Product1 product;

  ProductView(this.product);

//  void _showMap() {
//    final List<Marker> markers = <Marker>[
//      Marker('position', 'Position', product.location.latitude,
//          product.location.longitude)
//    ];
//    final CameraPosition cameraPosition = CameraPosition(
//        Location(product.location.latitude, product.location.longitude), 14.0);
//    final MapView mapView = MapView();
//    mapView.show(
//      MapOptions(
//          title: product.location.address,
//          mapViewType: MapViewType.normal,
//          initialCameraPosition: cameraPosition),
//      toolbarActions: [ToolbarAction('Close', 1)],
//    );
//    mapView.onToolbarAction.listen((int id) {
//      if (id == 1) {
//        mapView.dismiss();
//      }
//    });
//    mapView.onMapReady.listen((_) {
//      mapView.setMarkers(markers);
//    });
//  }

  Widget _buildAddressPriceRow(String address, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          //onTap: _showMap,
          child: Text(
            address,
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          '\$ ${price.toString()}',
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(height: 360.0, child: ImageViewer(photos: product.images),),

            _buildAddressPriceRow(product.location.address, double.parse(product.price.toString())),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                product.description,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        floatingActionButton: ProductFAB(product),
      ),
    );
  }
}
