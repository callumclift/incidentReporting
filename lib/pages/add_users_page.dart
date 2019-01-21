import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user_mode.dart';
import '../models/user.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/ui_elements/dropdown_formfield.dart';
import '../scoped_models/users_model.dart';
import '../widgets/helpers/app_side_drawer.dart';

class AddUsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AddUsersPageState();
  }
}

class _AddUsersPageState extends State<AddUsersPage> {
  final TextEditingController _firstNameTextController =
      TextEditingController();
  final TextEditingController _surnameTextController = TextEditingController();
  final TextEditingController _passwordFieldController =
      TextEditingController();
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _organisationFieldController =
      TextEditingController();

  //this is a map to manage the form data
  final Map<String, dynamic> _formData = {
    'firstName': null,
    'surname': null,
    'email': null,
    'organisation': null,
    'role': null
  };

  String _organisationValue;
  String _roleValue;

  final List<String> _organisationDrop = ['Ontrac', 'Siemens', 'CrossRail'];
  final List<String> _roleDrop = ['Super Admin', 'Client Admin', 'Reporter'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildFirstNameText() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'First Name'),
      controller: _firstNameTextController,
      //initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty) {
          return 'Please enter a name';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['firstName'] = value;
        });
      },
    );
  }

  Widget _buildSurnameText() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Surname'),
      controller: _surnameTextController,
      //initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty) {
          return 'Please enter a surname';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['surname'] = value;
        });
      },
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailFieldController,
      decoration: InputDecoration(
        labelText: 'Email',
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty && value.trim().length <= 0 ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        }
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
        controller: _passwordFieldController,
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty && value.trim().length <= 0 || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          _formData['password'] = value;
        });
  }

//  Widget _buildOrganisationDrop(User user) {
//    String _buildOrganisationValue() {
//      String value;
//
//      if (user != null && _organisationValue == null) {
//        value = user.organisation;
//        _organisationValue = user.organisation;
//        _formData['organisation'] = value;
//      } else if (user == null) {
//        value = _organisationValue;
//      } else if (user != null && _organisationValue != null) {
//        value = _organisationValue;
//        _formData['organisation'] = value;
//      }
//      return value;
//    }
//
//    return DropdownFormField(
//      hint: 'Organisation',
//      value: _buildOrganisationValue(),
//      items: _organisationDrop.toList(),
//      onChanged: (val) => setState(() {
//        _organisationValue = val;
//        _formData['organisation'] = _organisationValue;
//      }),
//      validator: (val) =>
//      (val == null || val.isEmpty) ? 'Please choose an organisation' : null,
//      initialValue: user == null ? '' : user.organisation,
//      onSaved: (val) => setState(() {
//        _organisationValue = val;
//        _formData['organisation'] = val;
//      }),
//    );
//  }

  Widget _buildRoleDrop() {
    print('building role drop');

    return DropdownFormField(
      hint: 'Role',
      value: _roleValue,
      items: _roleDrop.toList(),
      onChanged: (val) => setState(() {
            _roleValue = val;
            _formData['role'] = val;
          }),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Please choose a role' : null,
      initialValue: '',
      onSaved: (val) => setState(() {
            _roleValue = val;
            _formData['role'] = val;
          }),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<UsersModel>(
        builder: (BuildContext context, Widget child, UsersModel model) {
      return model.isLoading
          ? Center(
              child: AdaptiveProgressIndicator(),
            )
          : Center(
              child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: RaisedButton(
                textColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                child: Text('Save'),
                onPressed: () => _saveUser(model.addUser),
              ),
            ));
    });
  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    print('building page content');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildFirstNameText(),
              _buildSurnameText(),
              _buildEmailTextField(),
              //_buildPasswordTextField(),
              //_buildOrganisationDrop(user),
              _buildRoleDrop(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUser(Function addUser) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    addUser(
//        _formData['firstName'],
//        _formData['surname'],
//        _formData['email'],
//        _formData['organisation'],
//        _formData['role'],
            )
        .then((Map<String, dynamic> response) {
      print(response);
      if (response['success']) {
        Navigator.of(context).pushReplacementNamed('/usersAdmin');
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
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(response['message']),
                content: Text('Please try again'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      drawer: SideDrawer(),
      body: _buildPageContent(context),
    );
  }
}
