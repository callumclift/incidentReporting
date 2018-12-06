import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import './users_edit_page.dart';
import '../models/user.dart';

import '../scoped_models/main.dart';

class UsersListPage extends StatefulWidget {
  final MainModel model;

  UsersListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UsersListPageState();
  }
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  initState() {
    widget.model.fetchUsers('Super Admin', clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(MainModel model, int index, BuildContext context, User userData) {


    String edit = 'Edit';
    String suspend = '';
    String delete = 'Delete';

    if (userData.suspended) {
      suspend = 'Resume';
    } else {
      suspend = 'Suspend';
    }

    final List<String> _userOptions = [edit, suspend, delete];

    return PopupMenuButton(
        onSelected: (String value) {
          if (value == 'Delete') {

          } else if (value == 'Suspend' || value == 'Resume') {
            model
                .suspendResumeUser(userData.id, userData.suspended)
                .then((Map<String, dynamic> response) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(response['message']),
                      content: Text('Press OK to continue'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    );
                  });
            });
          } else if (value == 'Edit') {
            model.selectUser(model.allUsers[index].id);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return UsersEditPage(
                  );
                })).then((_){
              model.selectUser(null);
            });

          }
        },
        icon: Icon(Icons.more_horiz),
        itemBuilder: (BuildContext context) {
          return _userOptions.map((String option) {
            return PopupMenuItem<String>(value: option, child: Text(option));
          }).toList();
        });
  }

  String _buildListSubtitle(String role, bool isSuspended){
    String subtitle;
    isSuspended ? subtitle = role + ' - (Suspended)': subtitle = role;
    return subtitle;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        List<User> users = model.allUsers;
        return model.isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/userIcon.png'),
                      ),
                      title: Text(users[index].firstName + ' ' + users[index].surname),
                      subtitle: Text(_buildListSubtitle(users[index].role, users[index].suspended)),
                      trailing: _buildEditButton(model, index, context, users[index]),
                    ),
                    Divider(),
                  ],
                );
          },
          itemCount: users.length,
        );
      },
    );
  }
}
