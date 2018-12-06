import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/products/products.dart';
import '../scoped_models/main.dart';
import '../widgets/ui_elements/logout_list_tile.dart';
import '../widgets/helpers/app_side_drawer.dart';

class ProductsPage extends StatefulWidget {

  final MainModel model;

  ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductsPageState();
  }

}

class _ProductsPageState extends State<ProductsPage>{

  @override
  initState(){
    //widget.model.fetchProducts1();
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  Widget _buildProductsList() {

    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      //default is we have got no products yet
      Widget content = Center(child: Text('No Products Found'),);
      if(model.displayedProducts1.length > 0 && !model.isLoading){
        content = Products();
      } else if(model.isLoading){
        content = Center(child: CircularProgressIndicator(),);
      }
      return RefreshIndicator(child: content, onRefresh: model.fetchProducts);

    });


  }

  @override
  Widget build(BuildContext context) {
    print('[Products Page] - build page');
    return Scaffold(
      drawer: SideDrawer(),
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavouritesOnly ? Icons.favorite: Icons.favorite_border),
                onPressed: () {model.toggleDisplayMode();},
              );
            },
          ),
        ],
      ),
      body: _buildProductsList(),
    );
  }
}
