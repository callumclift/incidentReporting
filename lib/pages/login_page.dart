import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rxdart/subjects.dart';
import '../scoped_models/main.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../models/auth.dart';
import '../models/authenticated_user.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  Map<String, dynamic> _authFormData = {
    'username': null,
    'password': null,
  };

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



  void _submitForm(MainModel model) async {
    if (!_authFormKey.currentState.validate()) {
      return;
    }
    _authFormKey.currentState.save();
    print(_authFormData);

    Map<String, dynamic> successInformation = await model.login(
        _authFormData['username'], _authFormData['password']);


    if (successInformation['success']) {


     // Navigator.pushReplacementNamed(context, '/');
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
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.9;
    final double targetHeight = deviceHeight * 0.4;
    print('[AuthPage] - build page');

    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.deepOrange,
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
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10.0)),
                      padding: EdgeInsets.all(10.0),
                      width: targetWidth,

                      child: Form(
                        key: _authFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/ontrac.png',
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildEmailTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            _buildPasswordTextField(),
                            SizedBox(
                              height: 10.0,
                            ),
                            ScopedModelDescendant<MainModel>(builder: (
                              BuildContext context,
                              Widget child,
                              MainModel model,
                            ) {
                              return model.isLoading
                                  ? CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),)
                                  : RaisedButton(
                                      textColor: Colors.white,
                                      onPressed: () =>
                                          _submitForm(model),
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
}
