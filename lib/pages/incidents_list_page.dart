import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ontrac_incident_reporting/models/incident.dart';
import 'package:ontrac_incident_reporting/pages/completed_incident_page.dart';
import '../scoped_models/incidents_model.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import 'package:provider/provider.dart';

class IncidentsListPage extends StatefulWidget {


  IncidentsListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IncidentsListPageState();
  }
}

class _IncidentsListPageState extends State<IncidentsListPage> {

  IncidentsModel incidentsModel;


  @override
  initState() {
    incidentsModel = context.read<IncidentsModel>();
    incidentsModel.getIncidents();
    super.initState();
  }



  void _viewIncident(int index){
    incidentsModel.selectIncident(incidentsModel.allIncidents[index].incidentId);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedIncidentPage();
    })).then((_) {
      incidentsModel.selectIncident(null);
    });
  }



  Widget _buildListTile(int index) {
    return Column(
        children: <Widget>[
          InkWell(onTap: () => _viewIncident(index),
            child: ListTile(
              leading: Icon(Icons.library_books_sharp, color: orangeDesign1,),
              title: Text(incidentsModel.allIncidents[index].type, style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('Date: ', incidentsModel.allIncidents[index].incidentDate, context),
              ],),
            ),),
          Divider(),
        ],
      );
  }

  Widget _buildPageContent() {

    final double deviceHeight = MediaQuery.of(context).size.height;

    if (incidentsModel.isLoading) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      orangeDesign1),
                ),
                SizedBox(height: 20.0),
                Text('Fetching Incidents')
              ]));
    } else if (incidentsModel.allIncidents.length == 0) {
      return RefreshIndicator(
          color: orangeDesign1,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Incidents available pull down to refresh',
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
          onRefresh: () => incidentsModel.getIncidents());
    } else {
      return RefreshIndicator(
        color: orangeDesign1,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index);
          },
          itemCount: incidentsModel.allIncidents.length,
        ),
        onRefresh: () => incidentsModel.getIncidents(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<IncidentsModel>(
      builder: (context, model, child) {
        return _buildPageContent();
      },
    );
  }
}
