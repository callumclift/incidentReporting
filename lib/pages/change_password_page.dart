import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart';

import '../scoped_models/main.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';

import '../models/auth.dart';
import '../models/authenticated_user.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChangePasswordPageState();
  }
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with TickerProviderStateMixin {
  Map<String, dynamic> _formData = {
    'currentPassword': null,
    'newPassword': null,
    'confirmPassword': null,
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _currentPasswordFieldController = TextEditingController();
  TextEditingController _newPasswordFieldController = TextEditingController();
  TextEditingController _confirmPasswordFieldController = TextEditingController();
  TextEditingController _surnameTextController = TextEditingController();
  TextEditingController _passwordFieldController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _buildCurrentPasswordField() {
    return TextFormField(
        controller: _currentPasswordFieldController,
        decoration: InputDecoration(
            labelText: 'Current Password'),
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty && value.trim().length <= 0 || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          _formData['currentPassword'] = value;
        });
  }


  Widget _buildNewPasswordField() {
    return TextFormField(
        controller: _newPasswordFieldController,
        decoration: InputDecoration(
            labelText: 'New Password'),
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty && value.trim().length <= 0 || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          _formData['newPassword'] = value;
        });
  }



  Widget _buildConfirmPasswordField() {
    return TextFormField(
        controller: _confirmPasswordFieldController,
        decoration: InputDecoration(
            labelText: 'Confirm Password'),
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty && value.trim().length <= 0 || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }

          if(value != _newPasswordFieldController.text){
            return 'Password fields must match';
          }
          _formData['confirmPassword'] = value;
        });
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          return model.isLoading
              ? Center(
            child: AdaptiveProgressIndicator(),
          )
              : Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RaisedButton(onPressed: () =>
                    _submitForm(model),
                  color: Colors.deepOrange,
                  textColor: Colors.white,
                  child: Text('Save'),
                ),
              ));
        });
  }

  void _submitForm(MainModel model) async {

    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    print(_formData);

    Map<String, dynamic> successInformation =
        await model.newPassword( _formData['newPassword']);

    if (successInformation['success']) {
      // Navigator.pushReplacementNamed(context, '/');
    } else if (successInformation['message'] == 'temp password') {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Notice'),
              content: Text(
                  'Please change your password from the temporary password that you were given'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('ok'),
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An error occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('ok'),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    print('[ChangePasswordPage] - build page');

    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Change Password'),
        ),
        body: GestureDetector(
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
                      _buildCurrentPasswordField(),
                      _buildNewPasswordField(),
                      _buildConfirmPasswordField(),
                      SizedBox(height: 10.0,),
                      _buildSubmitButton(),
                    ],
                  )),
            )));
  }
}
