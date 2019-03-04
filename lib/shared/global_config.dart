import 'package:flutter/material.dart';

final Map apiKey = {
  'ios': 'AIzaSyCtOvgwFQl_5J2evCmN1OTK2mKgwmdYqrQ',
  'android': 'AIzaSyBXazM8m1tt-F42gJV6tqXzpUpIP7SoF0Y'
};
final String browserApi = 'AIzaSyD0GMuGPrP8eqRWYc1sJRiZvc34BPqLNks';
final encryptionKey = 'XRxDN7H77M1sRdOfQPlbsfC8QSxJ7MTz';
final String secureIncidentToken =
    'sam24S3{vQ!d(n8{raeiRHd531fhH)cLE*ct?VEyD-o4zr!M0qMWS9@5V0h}K#iY';
//final String serverUrl = 'http://192.168.1.124/incidents/login';
final String serverUrl = 'https://swp-dev.on-trac.co.uk/incidents_api/';
final String serverUrlTest =
    'https://swp-dev.on-trac.co.uk/incidents_api/getTestCustomFields';
String cookie;
Color orangeDesign1 = Color.fromARGB(255, 255, 147, 94);
final bool testMode = false;