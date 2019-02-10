import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../scoped_models/users_model.dart';
import '../shared/global_config.dart';
import '../widgets/helpers/app_side_drawer.dart';
import '../utils/database_helper.dart';
import '../shared/global_functions.dart';

class SettingsPage extends StatefulWidget {
  final SharedPreferences preferences;

  SettingsPage(this.preferences);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildPageContent() {
    final _model = ScopedModel.of<UsersModel>(context, rebuildOnChange: true);
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
              children: <Widget>[
                _enableDarkMode(_model),
                _getElrs(_model),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _enableDarkMode(UsersModel model) {

    bool _darkMode = widget.preferences.getBool('darkMode') == null? false : widget.preferences.getBool('darkMode');

    return CheckboxListTile(
        activeColor: model.authenticatedUser.darkMode? orangeDesign1 : Colors.grey,
        title: Text('Enable Dark Mode'),
        value: _darkMode,
        onChanged: (bool value) => setState(() {
              model.authenticatedUser.darkMode = value;
              DatabaseHelper databaseHelper = DatabaseHelper();

              databaseHelper.database.then((Database database) {
                database.rawUpdate(
                    'UPDATE users_table SET dark_mode = ? WHERE user_id = ?', [
                  '$value',
                  '${model.authenticatedUser.userId}'
                ]).then((int success) {
                  if (success != 0) {
                    widget.preferences.setBool('darkMode', value);
                    _darkMode = value;
                    setState(() {

                      if(_darkMode){
                        GlobalFunctions.setDarkMode(context);
                      } else {
                        GlobalFunctions.setLightMode(context);
                      }
                    });

                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Something went wrong'),
                            content: Text('Unable to toggle dark mode'),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'))
                            ],
                          );
                        });
                  }
                });
              });
            }));
  }

  Widget _getElrs(UsersModel model) {

    return ListTile(leading: Text('Resync ELRs', style: TextStyle(fontSize: 16.0),), trailing: IconButton(icon: Icon(Icons.refresh), color: orangeDesign1, onPressed: () {

      GlobalFunctions.showLoadingDialog(context, 'Fetching ELR data');
      model.updateElrs().then((Map<String, dynamic> result){
        if(result['success']){
          Navigator.of(context).pop();
          GlobalFunctions.showToast('ELR data is now up to date');
        } else {
          Navigator.of(context).pop();
          GlobalFunctions.showToast(result['message']);
        }

      });


    }),);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 255, 147, 94,),iconTheme: IconThemeData(color: Colors.black),
        title: Text('Settings', style: TextStyle(color: Colors.black, fontFamily: 'OpenSans'),),
      ),
      drawer: SideDrawer(),
      body: _buildPageContent(),
    );
  }
}
