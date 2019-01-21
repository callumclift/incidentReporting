import 'package:flutter/material.dart';
import './incident_types_edit_page.dart';

import 'package:scoped_model/scoped_model.dart';
import './incident_types_list_page.dart';
import '../scoped_models/incidents_model.dart';

import '../widgets/helpers/app_side_drawer.dart';

class IncidentTypesPage extends StatelessWidget {

  final IncidentsModel _incidentsModel;

  IncidentTypesPage(this._incidentsModel);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: SideDrawer(),
          appBar: AppBar(
            title: Text('Manage Incident Types'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Incident Types',
                ),
                Tab(
                  icon: Icon(Icons.create),
                  text: 'Add Incident Type',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              IncidentTypesListPage(_incidentsModel),
              IncidentTypesEditPage(),
            ],
          ),
        ));
  }
}
