import 'package:flutter/material.dart';
import './product_edit_page.dart';
import './product_list_page.dart';
import '../scoped_models/main.dart';

import '../widgets/ui_elements/logout_list_tile.dart';
import '../widgets/helpers/app_side_drawer.dart';

class ProductsAdminPage extends StatelessWidget {

  final MainModel model;

  ProductsAdminPage(this.model);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: SideDrawer(),
          appBar: AppBar(
            title: Text('Manage Products'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.create),
                  text: 'Create Product',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'My Products',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ProductEditPage(),
              ProductListPage(model),
            ],
          ),
        ));
  }
}
