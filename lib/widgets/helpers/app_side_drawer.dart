import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../ui_elements/logout_list_tile.dart';
import '../../scoped_models/main.dart';
import '../../models/authenticated_user.dart';

class SideDrawer extends StatelessWidget {
  bool _extraDivider = false;

  Widget _buildIsAdmin(BuildContext context, AuthenticatedUser user) {
    print(user.role);

    Widget returnedWidget;

    if (user.role == 'Super Admin' || user.role == 'Client Admin') {
      returnedWidget = ListTile(
        leading: Icon(Icons.people),
        title: Text('Manage Users'),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/admin');
        },
      );
      _extraDivider = true;
    } else {
      returnedWidget = new Container();
    }
    return returnedWidget;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
          automaticallyImplyLeading: false,
              title: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {

      double drawerWidth = constraints.maxWidth;
      double drawerHeight = constraints.maxHeight * 0.9;


              return Image.asset(
                'assets/ontrac.png',
                color: Colors.black, height: drawerHeight, width: drawerWidth,
              );

            })),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Raise Incident'),
              onTap: () => Navigator.of(context).pushReplacementNamed('/'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shop),
              title: Text('View Incidents'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/incidents');
              },
            ),
            Divider(),
            _buildIsAdmin(context, model.authenticatedUser),
            _extraDivider ? Divider() : new Container(),
//          ListTile(leading: Icon(Icons.camera_alt), title: Text('Product Gallery'), onTap: (){
//            Navigator.pushReplacementNamed(context, '/gallery');
//          },),
//          Divider(),
//          ListTile(leading: Icon(Icons.camera_alt), title: Text('Side Scroll'), onTap: (){
//            Navigator.pushReplacementNamed(context, '/sidescroll');
//          },),
//          Divider(),
            LogoutListTile(),
          ],
        ),
      );
    });
  }
}
