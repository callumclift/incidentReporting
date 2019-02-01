import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './view_my_incident_page.dart';
import '../models/incident.dart';
import '../widgets/helpers/app_side_drawer.dart';
import '../scoped_models/incidents_model.dart';
import '../shared/global_config.dart';

class MyIncidentsListPage extends StatefulWidget {
  final IncidentsModel model;

  MyIncidentsListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyIncidentsListPageState();
  }
}

class _MyIncidentsListPageState extends State<MyIncidentsListPage> {
  @override
  initState() {
    getIncidents();
    //widget.model.fetchMyIncidents();
    super.initState();
  }

  getIncidents() async {
    widget.model.getIncidents().then((Map<String, dynamic> success) {
      if (success['success'] != true ) {

        Fluttertoast.showToast(
            msg: success['message'],
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 2,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: orangeDesign1,
            textColor: Colors.black);

        print('uh ohhhhhh');
        print(success['message']);
      }
    });
  }

  Widget _buildPageContent(IncidentsModel model, List<Incident> incidents) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    if (model.isLoading) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(orangeDesign1)),
            SizedBox(height: 20.0),
            Text('Fetching Incidents')
          ]));
    } else if (incidents.length == 0) {
      return RefreshIndicator(
          color: orangeDesign1,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Incidents Available pull down to refesh',
                      textAlign: TextAlign.center,
                    ),
                    Icon(
                      Icons.warning,
                      size: 40.0,
                      color: orangeDesign1,
                    )
                  ],
                ))
          ]),
          onRefresh: () => getIncidents());
    } else {
      return RefreshIndicator(
        color: orangeDesign1,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: orangeDesign1,
                    size: 30.0,
                  ),
                  title: Text(incidents[index].type),
                  subtitle: Text(incidents[index].incidentDate),
                  trailing:
                      _buildEditButton(model, index, context, incidents[index]),
                ),
                Divider(),
              ],
            );
          },
          itemCount: incidents.length,
        ),
        onRefresh: () => getIncidents(),
      );
    }
  }

  Widget _buildEditButton(IncidentsModel model, int index, BuildContext context,
      Incident incidentData) {
    String view = 'View';

    final List<String> _userOptions = [view];

    return PopupMenuButton(
        onSelected: (String value) {
          if (value == 'Delete') {
          } else if (value == 'View') {
            print('index is:' + index.toString());
            model.selectMyIncident(model.allMyIncidents[index].incidentId);
            print('here is the selected incident');
            print(model.selectedMyIncident.incidentId);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return ViewMyIncidentPage(model);
            })).then((_) {
              model.selectMyIncident(null);
            });
          }
        },
        icon: Icon(Icons.more_horiz),
        itemBuilder: (BuildContext context) {
          return _userOptions.map((String option) {
            return PopupMenuItem<String>(value: option, child: Text(option));
          }).toList();
        });
  }

//  String _buildListSubtitle(String role, bool isVoid){
//    String subtitle;
//    isVoid ? subtitle = role + ' - (Suspended)': subtitle = role;
//    return subtitle;
//  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<IncidentsModel>(
      builder: (BuildContext context, Widget child, IncidentsModel model) {
        List<Incident> incidents = model.allMyIncidents;
        return Scaffold(
            appBar: AppBar(
              title: Text('Incidents'),
            ),
            drawer: SideDrawer(),
            body: _buildPageContent(model, incidents));
      },
    );
  }
}
