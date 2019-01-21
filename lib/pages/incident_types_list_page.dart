import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import './incident_types_edit_page.dart';
import '../models/incident_type.dart';

import '../scoped_models/incidents_model.dart';

class IncidentTypesListPage extends StatefulWidget {
  final IncidentsModel incidentsModel;

  IncidentTypesListPage(this.incidentsModel);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IncidentTypesListPageState();
  }
}

class _IncidentTypesListPageState extends State<IncidentTypesListPage> {
  @override
  initState() {
    //widget.usersModel.fetchUsers('Super Admin', clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(IncidentsModel incidentsModel, int index, BuildContext context, IncidentType incidentTypeData) {


    String edit = 'View/Edit';
    String delete = 'Delete';



    final List<String> _userOptions = [edit, delete];

    return PopupMenuButton(
        onSelected: (String value) {
          if (value == 'Delete') {

          } else if (value == 'View/Edit') {
            incidentsModel.selectIncidentType(incidentsModel.allIncidentTypes[index].id);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return IncidentTypesEditPage(
                  );
                })).then((_){
              incidentsModel.selectIncidentType(null);
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



  @override
  Widget build(BuildContext context) {

    final _incidentsModel =
    ScopedModel.of<IncidentsModel>(context, rebuildOnChange: true);
    // TODO: implement build

        List<IncidentType> incidentTypes = _incidentsModel.allIncidentTypes;
        return _incidentsModel.isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.insert_drive_file),
                      title: Text(incidentTypes[index].name),
                      subtitle: Text('Custom Fields: ' + incidentTypes[index].custom1 + ', ' + incidentTypes[index].custom2 + ', ' + incidentTypes[index].custom3),
                      trailing: _buildEditButton(_incidentsModel, index, context, incidentTypes[index]),
                    ),
                    Divider(),
                  ],
                );
          },
          itemCount: incidentTypes.length,
        );

  }
}
