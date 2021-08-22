import 'package:flutter/material.dart';
import 'package:ontrac_incident_reporting/pages/incidents_list_page.dart';
import 'package:ontrac_incident_reporting/pages/raise_incident_page.dart';
import 'package:ontrac_incident_reporting/pages/settings_page.dart';
import 'package:ontrac_incident_reporting/widgets/app_bar_gradient.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text(titles[_currentIndex], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
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
