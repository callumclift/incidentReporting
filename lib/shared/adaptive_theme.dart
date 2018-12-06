import 'package:flutter/material.dart';


final ThemeData _androidTheme = ThemeData(
  //fontFamily: 'Oswald',
  primarySwatch: Colors.deepOrange,
  accentColor: Colors.deepPurple,
  brightness: Brightness.light,
  buttonColor: Colors.deepPurple,
);

final ThemeData _iOSTheme = ThemeData(
  //fontFamily: 'Oswald',
  primarySwatch: Colors.grey,
  accentColor: Colors.deepPurple,
  brightness: Brightness.light,
  buttonColor: Colors.deepPurple,
);

ThemeData getAdaptiveThemData(context){
  return Theme.of(context).platform == TargetPlatform.android ? _androidTheme : _iOSTheme;
}

