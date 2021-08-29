import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../shared/global_config.dart';
import '../scoped_models/users_model.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loginButtonEnabled = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _passwordController.addListener(() {
      if(_emailController.text.length > 0 && _passwordController.text.length > 7){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _loginButtonEnabled = true;
          });
        });

      } else {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _loginButtonEnabled = false;
          });
        });

      }
    });
    _emailController.addListener(() {
      if(_emailController.text.length > 0 && _passwordController.text.length > 7){
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _loginButtonEnabled = true;
          });
        });

      } else {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _loginButtonEnabled = false;
          });
        });

      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _submitForm() async {
    FocusScope.of(context).unfocus();
    await context.read<UsersModel>().login(_emailController.text, _passwordController.text);
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.email],
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: orangeDesign1, width: 1.5),
              borderRadius: BorderRadius.circular(25)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: orangeDesign1, width: 3.0),
              borderRadius: BorderRadius.circular(25)),
          hintText: 'Email',
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
          filled: true,
          fillColor: Colors.white),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      autofillHints: [AutofillHints.password],
      onEditingComplete: () => TextInput.finishAutofillContext(),
      controller: _passwordController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: orangeDesign1, width: 1.5),
              borderRadius: BorderRadius.circular(25)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: orangeDesign1, width: 3.0),
              borderRadius: BorderRadius.circular(25)),
          labelStyle: TextStyle(color: orangeDesign1),
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
          filled: true,
          fillColor: Colors.white),
      obscureText: true,
      autocorrect: false,
    );
  }

  Widget _buildLoadingLogin() {
    Widget returnedWidget = Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        fontFamily: 'Open Sans',
      ),
      child: Consumer<UsersModel>(
        builder: (context, authenticationModel, child) => authenticationModel.isLoadingLogin ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              orangeDesign1),
        ) : ElevatedButton(
          style: ButtonStyle(minimumSize: MaterialStateProperty.resolveWith((states) => Size(120, 40)),padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.fromLTRB(20, 5, 20, 5)),
            overlayColor: _loginButtonEnabled ? MaterialStateColor.resolveWith((states) => Colors.grey) : MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.resolveWith((states) => 0),
            shape: MaterialStateProperty.resolveWith((states) => RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            )),
            backgroundColor: _loginButtonEnabled ? MaterialStateColor.resolveWith((states) => orangeDesign1) : MaterialStateColor.resolveWith((states) => Colors.grey),
          ),
          onPressed: () => _loginButtonEnabled ? _submitForm() : null,
          child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        ),
      ),
    );

    return returnedWidget;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =
    deviceWidth > 800.0 ? 700 : deviceWidth * 0.8;
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.fromARGB(255, 255, 146, 92), Color.fromARGB(255, 103, 2, 69)])),
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.white30),
                padding: EdgeInsets.all(20.0),
                width: targetWidth,
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 30, bottom: 30),
                        child: Image.asset(
                          'assets/ontrac.png',
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      AutofillGroup(child: Column(
                        children: [
                          _buildEmailTextField(),
                          SizedBox(
                            height: 10.0,
                          ),
                          _buildPasswordTextField(),
                        ],
                      )),
                      SizedBox(
                        height: 10.0,
                      ),
                      //_buildRememberMeListTile(),
                      _buildLoadingLogin(),
                      SizedBox(
                        height: 10,
                      ),
                      Consumer<UsersModel>(
                        builder: (context, authenticationModel, child) => Text(authenticationModel.loginErrorMessage, style: TextStyle(color: Colors.red), textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
