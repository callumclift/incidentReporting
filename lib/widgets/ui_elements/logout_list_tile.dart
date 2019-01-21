import 'dart:async';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../../scoped_models/users_model.dart';
import '../../shared/global_functions.dart';
import 'package:dynamic_theme/dynamic_theme.dart';


class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<UsersModel>(
      builder: (BuildContext context, Widget child, UsersModel model) {
        return ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {

            model.logout();
            Navigator.pop(context);

            //we do not need to do this anymore as it will be done automatically as the listener is fired on logout
            Navigator.of(context).pushReplacementNamed('/login');
          },
        );
      },
    );
  }
}
