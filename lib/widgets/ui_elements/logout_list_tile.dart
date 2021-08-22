import 'dart:async';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../scoped_models/users_model.dart';
import '../../shared/global_functions.dart';


class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<UsersModel>(
      builder: (context, model, child) {
        return ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            model.logout();
            Navigator.pop(context);
            //we do not need to do this anymore as it will be done automatically as the listener is fired on logout
          },
        );
      },
    );
  }
}
