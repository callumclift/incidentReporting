import 'package:flutter/material.dart';
import 'package:incident_reporting_new/pages/home_page.dart';
import './pages/login_page.dart';
import './pages/undefined_page.dart';
import 'constants/route_paths.dart' as routes;

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name) {
    case routes.HomePageRoute:
      return MaterialPageRoute(builder: (context) => HomePage());
    case routes.LoginPageRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
      break;
    default:
      return MaterialPageRoute(builder: (context) => UndefinedPage(name: settings.name,));
  }

}
