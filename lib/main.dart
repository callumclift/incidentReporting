import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';


import './pages/products_page.dart';
import './pages/raise_incident_page.dart';
import './pages/product_page.dart';
import './pages/product_view.dart';
import './pages/gallery_view.dart';
import './pages/incidents_list_page.dart';
import './pages/side_scroll.dart';
import './pages/terms_conditions_page.dart';
import './pages/change_password_page.dart';
import './pages/new_password_page.dart';
import './pages/users_admin_page.dart';
import './pages/login_page.dart';
import './models/product1.dart';
import './widgets/helpers/custom_route.dart';
import 'shared/global_config.dart';
import 'shared/adaptive_theme.dart';
//import 'package:flutter/rendering.dart';

import './scoped_models/main.dart';

Future<void> main() async {

  final FirebaseApp app = await FirebaseApp.configure(
    name: 'ontrac-incident-reporting',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:213392944471:ios:45d06d2449f920b0',
      gcmSenderID: '213392944471',
      databaseURL: 'https://incident-reporting-a5394.firebaseio.com',
      bundleID: 'com.ontrac.ontracIncidentReporting'
    )
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

  runApp(MyApp(app: app,));
}

class MyApp extends StatefulWidget {
  final FirebaseApp app;
  MyApp({this.app});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {

    final FirebaseDatabase database = FirebaseDatabase(databaseURL: 'https://incident-reporting-a5394.firebaseio.com', app: widget.app);
    database.setPersistenceEnabled(true);
    // TODO: implement initState
    _model.autoLogin();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding main widget build');

    // TODO: implement build
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(debugShowCheckedModeBanner: false,
        theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 3.0, color: Colors.black)),
              labelStyle: TextStyle(color: Colors.grey)),
          //fontFamily: 'Oswald',
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.grey,
          brightness: Brightness.light,
          buttonColor: Colors.deepOrange,
        ),
        title: 'Demo App',
        routes: {
          '/': (BuildContext context) {
            if(!_isAuthenticated){
              return LoginPage();
            } else if(!_model.authenticatedUser.acceptedTerms) {
              return TermsConditionsPage();
            }else if(_model.authenticatedUser.hasTemporaryPassword)
           {
              return NewPasswordPage();
            } else {
              return RaiseIncidentPage();
            }
            },
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? LoginPage() : UsersAdminPage(_model),
          '/gallery': (BuildContext context) =>
              !_isAuthenticated ? LoginPage() : GalleryView(_model),
          '/sidescroll': (BuildContext context) =>
              !_isAuthenticated ? LoginPage() : SideScroll(),
          '/changePassword': (BuildContext context) => ChangePasswordPage(),
          '/incidents': (BuildContext context) =>
          !_isAuthenticated ? LoginPage() : IncidentsListPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => LoginPage(),
            );
          }

          final List<String> pathElements = settings.name.split('/');

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
              builder: (BuildContext context) =>
                  !_isAuthenticated ? LoginPage() : ProductPage(product),
            );
          }
          if (pathElements[1] == 'productview') {
            final String productId = pathElements[2];
            final Product1 product =
                _model.allProducts1.firstWhere((Product1 product) {
              return product.id == productId;
            });
            return CustomRoute<bool>(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? LoginPage() : ProductView(product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  !_isAuthenticated ? LoginPage() : ProductsPage(_model));
        },
        //home: AuthPage()
      ),
    );
  }
}
