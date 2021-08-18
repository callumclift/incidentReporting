import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './pages/raise_incident_page.dart';
import './pages/settings_page.dart';
import './pages/my_incidents_list_page.dart';
import './pages/login_page.dart';
import 'shared/global_config.dart';
import './scoped_models/incidents_model.dart';
import './scoped_models/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  String platformType;
  if(Platform.isIOS)
    platformType = 'ios';
  else if(Platform.isAndroid)
    platformType = 'android';

  //MapView.setApiKey(apiKey[platformType]);

  runApp(MyApp(
    preferences: preferences,
  ));
}

class MyApp extends StatefulWidget {
  final SharedPreferences preferences;
  MyApp({this.preferences});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final UsersModel _usersModel = UsersModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _usersModel.autoLogin(widget.preferences);

    super.initState();
  }

  @override
  void dispose() {
    _usersModel.logout();
    print('inside dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding main widget build');

    // TODO: implement build
    return MultiProvider(providers: [
      ChangeNotifierProvider<UsersModel>(create: (_) => _usersModel),
      ChangeNotifierProxyProvider<UsersModel, IncidentsModel>(
        update: (context, usersModel, incidentModel) => IncidentsModel(usersModel),
      ),
    ],
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'OpenSans',
          inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                  BorderSide(width: 2.0, color: Color.fromARGB(255, 255, 147, 94))),
              labelStyle: TextStyle(color: Colors.grey)),
          //fontFamily: 'Oswald',
          primaryColor: Color.fromARGB(255, 254, 147, 94),
          //primarySwatch: Colors.deepOrange,
          accentColor: Colors.grey,
          buttonColor: Color.fromARGB(255, 254, 147, 94),
        ),
        title: 'Incident Reporting',
        routes: {
          '/raiseIncident': (BuildContext context) =>
              RaiseIncidentPage(),
          '/login': (BuildContext context) => LoginPage(),
          '/settings': (BuildContext context) => SettingsPage(widget.preferences),
          '/myIncidents': (BuildContext context) =>
              MyIncidentsListPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => LoginPage(),
            );
          }

          final List<String> pathElements =
          settings.name.split('/');

          if (pathElements[0] != '') {
            return null;
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
              _usersModel.authenticatedUser == null
                  ? LoginPage()
                  : RaiseIncidentPage());
        },
        home: _usersModel.authenticatedUser == null
            ? LoginPage()
            : RaiseIncidentPage()),);
  }
}
