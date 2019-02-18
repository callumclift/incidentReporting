import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../ui_elements/logout_list_tile.dart';
import '../../scoped_models/incidents_model.dart';
import '../../scoped_models/users_model.dart';
import '../../models/authenticated_user.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';

class SideDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SideDrawerState();
  }
}

class _SideDrawerState extends State<SideDrawer> {
  bool _extraDivider = false;
  bool _pendingItems = false;

  @override
  void initState() {

    final AuthenticatedUser _authenticatedUser =
    ScopedModel.of<UsersModel>(context).authenticatedUser;

    IncidentsModel _incidentsModel = IncidentsModel();
    _checkPendingIncidents(_incidentsModel, _authenticatedUser);


    super.initState();

  }

  _checkPendingIncidents(IncidentsModel model, AuthenticatedUser authenticatedUser) async{

    model.checkPendingIncidents(authenticatedUser).then((int value) {
      if (value == 1) {
        setState(() {
          _pendingItems = true;
        });
      }
    });
  }


//  Widget _buildUserAdmin(BuildContext context, AuthenticatedUser user) {
//    Widget returnedWidget;
//
//    if (user == null) {
//      returnedWidget = new Container();
//    } else if (user.isClientAdmin || user.isSuperAdmin) {
//      returnedWidget = ListTile(
//        leading: Icon(Icons.people),
//        title: Text('Add Users'),
//        onTap: () {
//          Navigator.pushReplacementNamed(context, '/usersAdmin');
//        },
//      );
//      _extraDivider = true;
//    } else {
//      returnedWidget = new Container();
//    }
//    return returnedWidget;
//  }
//
//  Widget _buildIncidentAdmin(BuildContext context, AuthenticatedUser user) {
//    Widget returnedWidget;
//
//    if (user == null) {
//      returnedWidget = new Container();
//    } else if (user.isClientAdmin || user.isSuperAdmin) {
//      returnedWidget = ListTile(
//        leading: Icon(Icons.insert_drive_file),
//        title: Text('Incident Types'),
//        onTap: () {
//          Navigator.pushReplacementNamed(context, '/incidentTypes');
//        },
//      );
//      _extraDivider = true;
//    } else {
//      returnedWidget = new Container();
//    }
//    return returnedWidget;
//  }

  void _uploadPendingIncidents(IncidentsModel model, AuthenticatedUser authenticatedUser){

    GlobalFunctions.showLoadingDialog(context, 'Uploading');
    print('finished loading dialog');





    model.uploadPendingIncidents1(authenticatedUser, context).then((Map<String, dynamic> response){

      if(response['success']){
        setState(() {
          _pendingItems = false;
        });
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: response['message'],
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 2,
            gravity: ToastGravity.CENTER,
            backgroundColor: orangeDesign1,
            textColor: Colors.black);
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: response['message'],
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 2,
            gravity: ToastGravity.CENTER,
            backgroundColor: orangeDesign1,
            textColor: Colors.black);
      }

    });


  }



  @override
  Widget build(BuildContext context) {
    final IncidentsModel _incidentsModel =
        ScopedModel.of<IncidentsModel>(context, rebuildOnChange: true);

    // TODO: implement build
    return ScopedModelDescendant<UsersModel>(
        builder: (BuildContext context, Widget child, UsersModel model) {
      return Drawer(
        child: Column(
          children: <Widget>[
            AppBar(backgroundColor: orangeDesign1,
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
            Expanded(child: ListView(padding: EdgeInsets.symmetric(vertical: 0.0), children: <Widget>[
              ListTile(
                leading: Icon(Icons.create),
                title: Text('Raise Incident'),
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/raiseIncident'),
              ),
              Divider(),
//              _buildUserAdmin(context, model.authenticatedUser),
//              _extraDivider ? Divider() : new Container(),
//              _buildIncidentAdmin(context, model.authenticatedUser),
//              _extraDivider ? Divider() : new Container(),
              ListTile(
                leading: Icon(Icons.description),
                title: model.authenticatedUser.isSuperAdmin || model.authenticatedUser.isClientAdmin ? Text('Incidents') : Text('My Incidents'),
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
              _pendingItems ? Column(children: <Widget>[
                Divider(),
                ListTile(
                  leading: Icon(Icons.file_upload, color: orangeDesign1,),
                  title: Text('Upload Incidents'),
                  onTap: () => _uploadPendingIncidents(_incidentsModel, model.authenticatedUser),

                ),
              ],) : Container(),
              Divider(),
              LogoutListTile(),

            ],)),


          ],
        ),
      );
    });
  }
}
