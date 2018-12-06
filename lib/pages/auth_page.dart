import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import 'package:google_sign_in/google_sign_in.dart';


import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  Map<String, dynamic> _authFormData = {
    'username': null,
    'password': null,
    'acceptTerms': false
  };


  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  TextEditingController _passwordFieldController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    super.initState();
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      image: AssetImage('assets/selling.jpg'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.dstATop,
      ),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email/Username',
        filled: true,
        fillColor: Colors.white,
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
        _authFormData['username'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
        controller: _passwordFieldController,
        decoration: InputDecoration(
            labelText: 'Password', filled: true, fillColor: Colors.white),
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty && value.trim().length <= 0 || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          _authFormData['password'] = value;
        });
  }

  Widget _buildConfirmPasswordTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
            decoration: InputDecoration(
                labelText: 'Confirm Password',
                filled: true,
                fillColor: Colors.white),
            obscureText: true,
            validator: (String value) {
              if (value != _passwordFieldController.text &&
                  _authMode == AuthMode.SignUp) {
                return 'Password fields must match';
              }
            }),
      ),
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
        title: Text('Accept Terms'),
        value: _authFormData['acceptTerms'],
        onChanged: (bool value) {
          setState(() {
            _authFormData['acceptTerms'] = value;
          });
        });
  }

  void _submitForm(Function authenticate) async {
    if (!_authFormKey.currentState.validate() ||
        !_authFormData['acceptTerms']) {
      return;
    }
    _authFormKey.currentState.save();
    print(_authFormData);

    Map<String, dynamic> successInformation = await authenticate(
        _authFormData['username'], _authFormData['password'], _authMode);

    if (successInformation['success']) {
      //Navigator.pushReplacementNamed(context, '/');
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
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.9;
    print('[AuthPage] - build page');

    // TODO: implement build
    return Scaffold(backgroundColor: Colors.deepOrange,
//        appBar: AppBar(
//          title: Text('Login'),
//        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
              decoration: BoxDecoration(
                //image: _buildBackgroundImage(),
              ),
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: targetWidth,
                    child: Form(
                      key: _authFormKey,
                      child: Column(
                        children: <Widget>[
                          _buildEmailTextField(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildPasswordTextField(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildConfirmPasswordTextField(),
                          _buildAcceptSwitch(),
                          SizedBox(
                            height: 10.0,
                          ),
                          FlatButton(
                              onPressed: () {
                                if (_authMode == AuthMode.Login) {
                                  setState(() {
                                    _authMode = AuthMode.SignUp;
                                  });
                                  _controller.forward();
                                } else {
                                  _authMode = AuthMode.Login;
                                  _controller.reverse();
                                }
                              },
                              child: Text(
                                  'Switch to ${_authMode == AuthMode.Login ? 'Sign Up' : 'Login'}')),
                          ScopedModelDescendant<MainModel>(builder: (
                            BuildContext context,
                            Widget child,
                            MainModel model,
                          ) {
                            return model.isLoading
                                ? AdaptiveProgressIndicator()
                                : RaisedButton(
                                    textColor: Colors.white,
                                    onPressed: () =>
                                        _submitForm(model.authenticate),
                                    child: Text(_authMode == AuthMode.Login
                                        ? 'Login'
                                        : 'Sign up'),
                                  );
                          }),
//                GestureDetector(
//                  onTap: _submitForm,
//                  child: Container(
//                    width: 100.0,
//                    color: Colors.green,
//                    padding: EdgeInsets.all(5.0),
//                    child: Text('Submit', textAlign: TextAlign.center,),
//                  ),
//                ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ));
  }
}
