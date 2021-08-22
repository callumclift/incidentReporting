import 'package:flutter/material.dart';
import 'package:ontrac_incident_reporting/shared/global_config.dart';

class NavigationBar extends StatefulWidget {


  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {

  int _currentIndex = 0;

  final tabs = [
    Center(child: Text('1'),),
    Center(child: Text('2'),),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
            label: 'Raise',
        ),

      ],
      onTap: (index) =>
        setState(() {
          _currentIndex = index;
        })
      ,

    );
  }
}
