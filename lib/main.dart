import 'dart:async';
import 'package:flutter/material.dart';
import 'package:incident_reporting_new/constants/route_paths.dart' as routes;
import 'package:incident_reporting_new/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';
import './pages/login_page.dart';
import 'shared/global_config.dart';
import './scoped_models/incidents_model.dart';
import './scoped_models/users_model.dart';
import './locator.dart';
import './services/navigation_service.dart';
import 'package:bot_toast/bot_toast.dart';
import './router.dart' as router;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  setupLocator();
  setPathUrlStrategy();
  runApp(MyApp());
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

  @override
  void initState() {
    _usersModel.autoLogin();
    super.initState();
  }

  @override
  void dispose() {
    _usersModel.logout();
    super.dispose();
  }

  Widget chooseHomePage(){
    Widget returnedRoute;
    if(user == null){
      returnedRoute = LoginPage();
    } else
    {
      returnedRoute = HomePage();
    }
    return returnedRoute;
  }

  @override
  Widget build(BuildContext context) {
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
          builder: BotToastInit(),
          navigatorObservers: [
            BotToastNavigatorObserver(),
          ],
          onGenerateRoute: router.generateRoute,
          initialRoute: routes.HomePageRoute,
          navigatorKey: locator<NavigationService>().navigatorKey,
          home: Consumer<UsersModel>(
              builder: (BuildContext context, model, child) {
                return model.isLoading? Container(
                  decoration: BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [orangeGradient, purpleGradient])
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),) : chooseHomePage();
              })),);
  }
}
