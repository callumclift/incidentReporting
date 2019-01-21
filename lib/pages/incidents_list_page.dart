import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:cloud_functions/cloud_functions.dart';

import './product_edit_page.dart';
import './view_incident_page.dart';
import './users_edit_page.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/incident.dart';
import '../widgets/helpers/app_side_drawer.dart';

import '../scoped_models/main.dart';
import '../scoped_models/incidents_model.dart';

class IncidentsListPage extends StatefulWidget {
  final IncidentsModel model;

  IncidentsListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IncidentsListPageState();
  }
}

class _IncidentsListPageState extends State<IncidentsListPage> {

  @override
  initState() {
    widget.model.fetchIncidents('Super Admin', clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(IncidentsModel model, int index, BuildContext context, Incident incidentData) {


    String view = 'View';
    String voidIncident = '';


    if (incidentData.voided) {
      voidIncident = 'Unvoid';
    } else {
      voidIncident = 'Void';
    }

    final List<String> _userOptions = [view, voidIncident];

    return PopupMenuButton(
        onSelected: (String value) {
          if (value == 'Delete') {

          } else if (value == 'Void' || value == 'Unvoid') {
            model
                .voidUnvoidIncident(incidentData.id, incidentData.voided)
                .then((Map<String, dynamic> response) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(response['message']),
                      content: Text('Press OK to continue'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    );
                  });
            });
          } else if (value == 'View') {
            model.selectIncident(model.allIncidents[index].id);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return ViewIncidentPage(
                  );
                })).then((_){
              model.selectIncident(null);
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
        List<Incident> incidents = model.allIncidents;
        return Scaffold(appBar: AppBar(title: Text('Incidents'),), drawer: SideDrawer(), body: model.isLoading ? Center(child: CircularProgressIndicator()): ListView.builder(
        itemBuilder: (BuildContext context, int index) {
        return Column(
        children: <Widget>[
        ListTile(
        leading: Icon(Icons.warning),
        title: Text(incidents[index].incidentType),
        subtitle: Text(incidents[index].dateTime),
        trailing: _buildEditButton(model, index, context, incidents[index]),
        ),
        Divider(),
        ],
        );
        },
        itemCount: incidents.length,
        ));
      },
    );
  }
}
