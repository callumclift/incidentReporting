import 'package:flutter/material.dart';
import 'package:incident_reporting_new/pages/incidents_list_page.dart';
import 'package:incident_reporting_new/pages/raise_incident_page.dart';
import 'package:incident_reporting_new/pages/settings_page.dart';
import 'package:incident_reporting_new/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';
import '../scoped_models/incidents_model.dart';
import '../shared/global_config.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;
  IncidentsModel _incidentsModel;

  @override
  void initState() {
    _incidentsModel = Provider.of(context, listen: false);
    // TODO: implement initState
    super.initState();
  }

  final tabs = [
    RaiseIncidentPage(),
    IncidentsListPage(),
    SettingsPage()
  ];

  final titles = [
    'Raise Incident',
    'View Incidents',
    'Settings'
  ];

  void _resetIncident() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [orangeGradient, purpleGradient]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Center(child: Text("Reset Incident", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),),
            ),
            content: Text('Are you sure you wish to reset this form?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  Navigator.of(context).pop();
                },
                child: Text(
                  'No',
                  style: TextStyle(color: orangeDesign1, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  await context.read<IncidentsModel>().resetTemporaryRecord(user.userId);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) => HomePage(),
                      transitionDuration: Duration(seconds: 0),
                    ),
                  );
                },
                child: Text(
                  'Yes',
                  style: TextStyle(color: orangeDesign1, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text(titles[_currentIndex], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
        actions: [_currentIndex == 0 ? IconButton(icon: Icon(Icons.refresh), onPressed: _resetIncident,) : Container()],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Raise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),

        ],
        onTap: (index) =>
            setState(() {
              _currentIndex = index;
            })
        ,

      ),
    );
  }
}
