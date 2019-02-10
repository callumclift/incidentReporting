import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart';
import '../scoped_models/users_model.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../models/auth.dart';
import '../models/authenticated_user.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/global_functions.dart';
import '../shared/global_config.dart';
import 'package:after_layout/after_layout.dart';


class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with AfterLayoutMixin<LoginPage> {
  Map<String, dynamic> _authFormData = {
    'username': null,
    'password': null,
  };

  GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  TextEditingController _passwordFieldController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  bool _rememberMe = false;

  final FocusNode _emailFocusNode = new FocusNode();
  final FocusNode _passwordFocusNode = new FocusNode();

  Color _emailLabelColor = Colors.grey;
  Color _passwordLabelColor = Colors.grey;




  @override
  void initState() {
    // TODO: implement initState
    setupFocusNodes();
    super.initState();
  }

  setupFocusNodes(){

    _emailFocusNode.addListener((){
      if(_emailFocusNode.hasFocus){
        setState(() {
          _emailLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _emailLabelColor = Colors.grey;

        });
      }
    });

    _passwordFocusNode.addListener((){
      if(_passwordFocusNode.hasFocus){
        setState(() {
          _passwordLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _passwordLabelColor = Colors.grey;

        });
      }
    });

  }

  Widget _buildEmailTextField() {
    return TextFormField(focusNode: _emailFocusNode,
      decoration: InputDecoration(labelStyle: TextStyle(color: _emailLabelColor),
        labelText: 'Email/Username',
        filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
      validator: (String value) {
        if (value.isEmpty && value.trim().length <= 0) {
          return 'Please enter a valid email/username';
        }
      },
      onSaved: (String value) {
        _authFormData['username'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(focusNode: _passwordFocusNode,
        controller: _passwordFieldController,
        decoration: InputDecoration(labelStyle: TextStyle(color: _passwordLabelColor),
            labelText: 'Password', fillColor: Colors.white, filled: true),
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty && value.trim().length <= 0 || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          _authFormData['password'] = value;
        });
  }

  Widget _buildRememberMeListTile(){
    return CheckboxListTile(selected: true, activeColor: orangeDesign1,
        title: new Text('Remember Me', style: TextStyle(color: Colors.black),),
        value: _rememberMe,
        onChanged: (bool value) =>
            setState(() => _rememberMe = value));
  }

  void _submitForm(UsersModel model) async {
    if (!_authFormKey.currentState.validate()) {
      return;
    }
    _authFormKey.currentState.save();
    //print(_authFormData);

    Map<String, dynamic> successInformation =
        await model.login(_authFormData['username'], _authFormData['password'], _rememberMe, context);

    if (successInformation['success']) {
      Navigator.pushReplacementNamed(context, '/raiseIncident');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
              title: Text('An error occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('ok', style: TextStyle(color: orangeDesign1),),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double targetWidth = deviceWidth > 768.0 ? deviceWidth * 0.5 : deviceWidth * 0.9;
    final double targetHeight = deviceHeight * 0.4;
    print('[AuthPage] - build page');
    print(_rememberMe);

    // TODO: implement build
    return Scaffold(
        //backgroundColor: Theme.of(context).primaryColor,
//        appBar: AppBar(
//          title: Text('Login'),
//        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromARGB(255, 255, 146, 92), Color.fromARGB(255, 103, 2, 69)])
                    //image: _buildBackgroundImage(),
                    ),
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(10.0)),
                      padding: EdgeInsets.all(10.0),
                      //height: MediaQuery.of(context).orientation == Orientation.portrait ? deviceHeight * 0.50 : deviceHeight* 0.85,
                      width: targetWidth,
                      child: Form(
                        key: _authFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/ontrac.png',
                              color: Colors.black,
                              height: deviceHeight * 0.15,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildEmailTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildPasswordTextField(),
                            _buildRememberMeListTile(),
                            ScopedModelDescendant<UsersModel>(builder: (
                              BuildContext context,
                              Widget child,
                              UsersModel model,
                            ) {
                              return model.isLoading
                                  ? CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              orangeDesign1),
                                    )
                                  : RaisedButton(color: orangeDesign1,
                                      textColor: Colors.white,
                                      onPressed: () => _submitForm(model),
                                      child: Text('Login'),
                                    );
                            }),
//                            RaisedButton(onPressed: _handleSignIn),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    if(Theme.of(context).brightness == Brightness.dark){
      GlobalFunctions.setLightMode(context);
    }
  }

}
