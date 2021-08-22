import 'package:flutter/material.dart';
import 'package:ontrac_incident_reporting/models/authenticated_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;

final Map apiKey = {
  'ios': 'AIzaSyCtOvgwFQl_5J2evCmN1OTK2mKgwmdYqrQ',
  'android': 'AIzaSyBXazM8m1tt-F42gJV6tqXzpUpIP7SoF0Y'
};
final String browserApi = 'AIzaSyD0GMuGPrP8eqRWYc1sJRiZvc34BPqLNks';
final String secureIncidentToken =
    'sam24S3{vQ!d(n8{raeiRHd531fhH)cLE*ct?VEyD-o4zr!M0qMWS9@5V0h}K#iY';
//final String serverUrl = 'http://192.168.1.124/incidents/login';
final String serverUrl = 'https://swp-dev.on-trac.co.uk/incidents_api/';
final String serverUrlTest =
    'https://swp-dev.on-trac.co.uk/incidents_api/getTestCustomFields';
String cookie;
String corsUrl = "https://cryptic-shelf-82365.herokuapp.com/";
Color orangeDesign1 = Color.fromARGB(255, 255, 147, 94);
Color orangeGradient = Color.fromARGB(255, 255, 146, 92);
Color purpleGradient = Color.fromARGB(255, 103, 2, 69);
SharedPreferences sharedPreferences;
String databasePassword = 'eRt5<vnV)vX)6z{3?DertY~fbX:4E/h/';
AuthenticatedUser user;
final Encrypt.Key  encryptionKey = Encrypt.Key.fromUtf8('e9et67y/B?E(H-7bQeT!emZ8ut7w!z%C');

