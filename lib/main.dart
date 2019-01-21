import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import './pages/products_page.dart';
import './pages/add_users_page.dart';
import './pages/raise_incident_page.dart';
import './pages/product_page.dart';
import './pages/product_view.dart';
import './pages/incident_types_page.dart';
import './pages/gallery_view.dart';
import './pages/settings_page.dart';
import './pages/incidents_list_page.dart';
import './pages/my_incidents_list_page.dart';
import './pages/side_scroll.dart';
import './pages/terms_conditions_page.dart';
import './pages/change_password_page.dart';
import './pages/new_password_page.dart';
import './pages/users_admin_page.dart';
import './pages/login_page.dart';
import './pages/test_maps.dart';
import './models/product1.dart';
import './widgets/helpers/custom_route.dart';
import 'shared/global_config.dart';
import 'shared/adaptive_theme.dart';
import 'shared/global_functions.dart';
//import 'package:flutter/rendering.dart';

import './scoped_models/main.dart';
import './scoped_models/incidents_model.dart';
import './scoped_models/users_model.dart';

Future<void> main() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  final FirebaseApp app = await FirebaseApp.configure(
    name: 'ontrac-incident-reporting',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:213392944471:ios:45d06d2449f920b0',
            gcmSenderID: '213392944471',
            databaseURL: 'https://incident-reporting-a5394.firebaseio.com',
            bundleID: 'com.ontrac.ontracIncidentReporting')
        : const FirebaseOptions(
            googleAppID: '1:213392944471:android:02b68124198f0316',
            apiKey: 'AIzaSyA63_QQy8HsLSud6pJaXnJdKbTHz3e4vj8',
            databaseURL: 'https://incident-reporting-a5394.firebaseio.com',
          ),
  );
  //debugPaintSizeEnabled = true;
  //debugPaintBaselinesEnabled = true;
  //debugPaintPointersEnabled = true;

  MapView.setApiKey(apiKey);

  runApp(MyApp(
    app: app,
    preferences: preferences,
  ));
}

class MyApp extends StatefulWidget {
  final FirebaseApp app;
  final SharedPreferences preferences;
  MyApp({this.app, this.preferences});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  final IncidentsModel _incidentsModel = IncidentsModel();
  final UsersModel _usersModel = UsersModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _usersModel.autoLogin(widget.preferences);
    print('here is auth user:');
    print(_usersModel.authenticatedUser);

    final FirebaseDatabase database = FirebaseDatabase(
        databaseURL: 'https://incident-reporting-a5394.firebaseio.com',
        app: widget.app);
    database.setPersistenceEnabled(true);
    // TODO: implement initState
    //_usersModel.autoLogin();
//    _usersModel.userSubject.listen((bool isAuthenticated) {
//      setState(() {
//        _isAuthenticated = isAuthenticated;
//      });
//    });
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
    return ScopedModel<IncidentsModel>(
      model: _incidentsModel,
      child: ScopedModel<UsersModel>(
          model: _usersModel,
          child: DynamicTheme(
              defaultBrightness: Brightness.light,
              data: (brightness) => new ThemeData(fontFamily: 'OpenSans',
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
                  brightness: brightness),
              themedWidgetBuilder: (context, theme) {
                return new MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: theme,
                    title: 'Demo App',
                    routes: {
                      '/raiseIncident': (BuildContext context) =>
                          RaiseIncidentPage(),
                      '/login': (BuildContext context) => LoginPage(),
                      '/usersAdmin': (BuildContext context) => AddUsersPage(),
                      '/incidentTypes': (BuildContext context) => IncidentTypesPage(_incidentsModel),
                      '/admin': (BuildContext context) =>
                          UsersAdminPage(_usersModel),
//          '/gallery': (BuildContext context) =>
//          !_isAuthenticated ? LoginPage() : GalleryView(_incidentsModel),
//          '/sidescroll': (BuildContext context) =>
//          !_isAuthenticated ? LoginPage() : SideScroll(),
                      '/settings': (BuildContext context) => SettingsPage(widget.preferences),
                      '/changePassword': (BuildContext context) =>
                          ChangePasswordPage(),
                      '/incidents': (BuildContext context) =>
                          IncidentsListPage(_incidentsModel),
                      '/myIncidents': (BuildContext context) =>
                          MyIncidentsListPage(_incidentsModel),
                      '/testMaps': (BuildContext context) => TestMaps(),
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
                      if (pathElements[1] == 'product') {
                        final String productId = pathElements[2];
                        final Product1 product =
                            _model.allProducts1.firstWhere((Product1 product) {
                          return product.id == productId;
                        });
                        return CustomRoute<bool>(
                          builder: (BuildContext context) => !_isAuthenticated
                              ? LoginPage()
                              : ProductPage(product),
                        );
                      }
                      if (pathElements[1] == 'productview') {
                        final String productId = pathElements[2];
                        final Product1 product =
                            _model.allProducts1.firstWhere((Product1 product) {
                          return product.id == productId;
                        });
                        return CustomRoute<bool>(
                          builder: (BuildContext context) => !_isAuthenticated
                              ? LoginPage()
                              : ProductView(product),
                        );
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
                        : RaiseIncidentPage());
              })),
    );
  }
}
