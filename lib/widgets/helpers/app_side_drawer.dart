import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../ui_elements/logout_list_tile.dart';
import '../../scoped_models/incidents_model.dart';
import '../../scoped_models/users_model.dart';
import '../../models/authenticated_user.dart';

class SideDrawer extends StatelessWidget {
  bool _extraDivider = false;

  Widget _buildUserAdmin(BuildContext context, AuthenticatedUser user) {
    Widget returnedWidget;

    if(user == null){
      returnedWidget = new Container();
    }else if (user.isClientAdmin || user.isSuperAdmin) {
      returnedWidget = ListTile(
        leading: Icon(Icons.people),
        title: Text('Add Users'),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/usersAdmin');
        },
      );
      _extraDivider = true;
    } else {
      returnedWidget = new Container();
    }
    return returnedWidget;
  }

  Widget _buildIncidentAdmin(BuildContext context, AuthenticatedUser user) {
    Widget returnedWidget;

    if(user == null){
      returnedWidget = new Container();
    }else if (user.isClientAdmin || user.isSuperAdmin) {
      returnedWidget = ListTile(
        leading: Icon(Icons.insert_drive_file),
        title: Text('Incident Types'),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/incidentTypes');
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
    return ScopedModelDescendant<UsersModel>(
        builder: (BuildContext context, Widget child, UsersModel model) {
      return Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
                automaticallyImplyLeading: false,
                title: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  double drawerWidth = constraints.maxWidth;
                  double drawerHeight = constraints.maxHeight * 0.9;

                  return Image.asset(
                    'assets/ontrac.png',
                    color: Colors.black,
                    height: drawerHeight,
                    width: drawerWidth,
                  );
                })),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Raise Incident'),
              onTap: () => Navigator.of(context).pushReplacementNamed('/raiseIncident'),
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
            _buildUserAdmin(context, model.authenticatedUser),
            _extraDivider ? Divider() : new Container(),
            _buildIncidentAdmin(context, model.authenticatedUser),
            _extraDivider ? Divider() : new Container(),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('My Incidents'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/myIncidents');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            Divider(),
            LogoutListTile(),
          ],
        ),
      );
    });
  }
}
