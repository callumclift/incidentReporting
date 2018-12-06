import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_edit_page.dart';
import '../models/product.dart';

import '../scoped_models/main.dart';

class ProductListPage extends StatefulWidget {

  final MainModel model;

  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductListPageState();
  }

}

class _ProductListPageState extends State<ProductListPage>{

  @override
  initState(){
    widget.model.fetchProducts(onlyForUser: true, clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model){
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          model.selectProduct(model.allProducts[index].id);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) {
                return ProductEditPage(
                );
              })).then((_){
                model.selectProduct(null);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      List<Product> products = model.allProducts;
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
              background: Container(
                color: Colors.red,
              ),
              key: Key(products[index].title),
              onDismissed: (DismissDirection direction){
                if(direction == DismissDirection.endToStart){
                  print('Swiped end to start, deleting product');
                  model.selectProduct(model.allProducts[index].id);
                  model.deleteProduct();
                } else if (direction == DismissDirection.startToEnd){
                  print('Swiped start to end');
                } else {
                  print('Swiped another way');
                }
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(products[index].image),
                    ),
                    title: Text(products[index].title),
                    subtitle: Text('\$${products[index].price.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider(),
                ],
              ));
        },
        itemCount: products.length,
      );
    },);
  }
}
