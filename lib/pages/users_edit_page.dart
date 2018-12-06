import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user_mode.dart';
import '../models/user.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/ui_elements/dropdown_formfield.dart';
import '../scoped_models/main.dart';

class UsersEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UsersEditPageState();
  }
}

class _UsersEditPageState extends State<UsersEditPage> {
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

  Widget _buildFirstNameText(User user) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (user == null && _firstNameTextController.text.trim() == '') {
      _firstNameTextController.text = '';
    } else if (user != null && _firstNameTextController.text.trim() == '') {
      _firstNameTextController.text = user.firstName;
    } else if (user != null && _firstNameTextController.text.trim() != '') {
      _firstNameTextController.text = _firstNameTextController.text;
    } else if (user == null && _firstNameTextController.text.trim() != '') {
      _firstNameTextController.text = _firstNameTextController.text;
    } else {
      _firstNameTextController.text = '';
    }

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

  Widget _buildSurnameText(User user) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (user == null && _surnameTextController.text.trim() == '') {
      _surnameTextController.text = '';
    } else if (user != null && _surnameTextController.text.trim() == '') {
      _surnameTextController.text = user.surname;
    } else if (user != null && _surnameTextController.text.trim() != '') {
      _surnameTextController.text = _surnameTextController.text;
    } else if (user == null && _surnameTextController.text.trim() != '') {
      _surnameTextController.text = _surnameTextController.text;
    } else {
      _surnameTextController.text = '';
    }

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

  Widget _buildEmailTextField(User user) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (user == null && _emailFieldController.text.trim() == '') {
      _emailFieldController.text = '';
    } else if (user != null && _emailFieldController.text.trim() == '') {
      _emailFieldController.text = user.email;
    } else if (user != null && _emailFieldController.text.trim() != '') {
      _emailFieldController.text = _emailFieldController.text;
    } else if (user == null && _emailFieldController.text.trim() != '') {
      _emailFieldController.text = _emailFieldController.text;
    } else {
      _emailFieldController.text = '';
    }
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

//  Widget _buildOrganisationDrop() {
//    return ButtonTheme(
//        alignedDropdown: true,
//        child: DropdownButton<String>(
//          hint: Text('Organisation'),
//          value: _organisationValue,
//          items: _organisationDrop.map((String value) {
//            return new DropdownMenuItem<String>(
//              value: value,
//              child: new Text(value),
//            );
//          }).toList(),
//          onChanged: (String value) {
//            setState(() {
//              _organisationValue = value;
//              _formData['organisation'] = _organisationValue;
//              print(value);
//            });
//          },
//        ));
//  }

  Widget _buildOrganisationDrop(User user) {
    String _buildOrganisationValue() {
      String value;

      if (user != null && _organisationValue == null) {
        value = user.organisation;
        _organisationValue = user.organisation;
        _formData['organisation'] = value;
      } else if (user == null) {
        value = _organisationValue;
      } else if (user != null && _organisationValue != null) {
        value = _organisationValue;
        _formData['organisation'] = value;
      }
      return value;
    }

    return DropdownFormField(
      hint: 'Organisation',
      value: _buildOrganisationValue(),
      items: _organisationDrop.toList(),
      onChanged: (val) => setState(() {
            _organisationValue = val;
            _formData['organisation'] = _organisationValue;
          }),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Please choose an organisation' : null,
      initialValue: user == null ? '' : user.organisation,
      onSaved: (val) => setState(() {
            _organisationValue = val;
            _formData['organisation'] = val;
          }),
    );
  }

  Widget _buildRoleDrop(User user) {
    print('building role drop');

    String _buildRoleValue() {
      String value;

      if (user != null && _roleValue == null) {
        value = user.role;
        _roleValue = user.role;
        _formData['role'] = value;
      } else if (user == null) {
        value = _roleValue;
      } else if (user != null && _roleValue != null) {
        value = _roleValue;
        _formData['role'] = value;
      }
      return value;
    }

    return DropdownFormField(
      hint: 'Role',
      value: _buildRoleValue(),
      items: _roleDrop.toList(),
      onChanged: (val) => setState(() {
            _roleValue = val;
            _formData['role'] = val;
          }),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Please choose a role' : null,
      initialValue: user == null ? '' : user.role,
      onSaved: (val) => setState(() {
            _roleValue = val;
            _formData['role'] = val;
          }),
    );
  }

  Widget _buildSubmitButton(User user) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(
              child: AdaptiveProgressIndicator(),
            )
          : Center(
              child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: RaisedButton(
                color: Colors.deepOrange,
                textColor: Colors.white,
                child: user == null ? Text('Save') : Text('Edit'),
                onPressed: () => _saveUser(user, model.addUser, model.editUser,
                    model.selectUser, model.selectedUserIndex),
              ),
            ));
    });
  }

  Widget _buildPageContent(BuildContext context, User user) {
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
              _buildFirstNameText(user),
              _buildSurnameText(user),
              _buildEmailTextField(user),
              //_buildPasswordTextField(),

              _buildOrganisationDrop(user),

              _buildRoleDrop(user),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(user),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUser(User user, Function addUser, Function editUser,
      Function setSelectedUser, int selectedUserIndex) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    if (user != null) {
      editUser(
        user,
        _formData['firstName'],
        _formData['surname'],
        _formData['email'],
        _formData['organisation'],
        _formData['role'],
      ).then((Map<String, dynamic> response) {
        print(response);
        if (response['success']) {
          Navigator.of(context).pushReplacementNamed('/admin');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(response['message']),
                  content: Text('Press OK to continue'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () { Navigator.of(context).pop();
                      setSelectedUser(null);
                      },
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
    } else {
      addUser(
        _formData['firstName'],
        _formData['surname'],
        _formData['email'],
        _formData['organisation'],
        _formData['role'],
      ).then((Map<String, dynamic> response) {
        print(response);
        if (response['success']) {
          setSelectedUser(null);
          Navigator.of(context).pushReplacementNamed('/admin');
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
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedUser);
        return model.selectedUser == null
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit User'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
