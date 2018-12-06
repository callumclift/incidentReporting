import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';

import '../models/incident.dart';
import '../models/location_data.dart';
import '../widgets/helpers/image_viewer.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/form_inputs/locate_user.dart';
import '../scoped_models/main.dart';

class ViewIncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewIncidentPageState();
  }
}

class _ViewIncidentPageState extends State<ViewIncidentPage> {





  Widget _buildPageContent(BuildContext context, Incident incident) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    void _showMap() {
      final List<Marker> markers = <Marker>[
        Marker('position', 'Incident', incident.location.latitude,
            incident.location.longitude)
      ];
      final CameraPosition cameraPosition = CameraPosition(
          Location(incident.location.latitude, incident.location.longitude), 14.0);
      final MapView mapView = MapView();
      mapView.show(
        MapOptions(
            title: 'Map of Incident',
            mapViewType: MapViewType.normal,
            initialCameraPosition: cameraPosition),
        toolbarActions: [ToolbarAction('Close', 1)],
      );
      mapView.onToolbarAction.listen((int id) {
        if (id == 1) {
          mapView.dismiss();
        }
      });
      mapView.onMapReady.listen((_) {
        mapView.setMarkers(markers);
      });
    }

    print('building page content');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),

          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Incident Type'),
                initialValue: incident.incidentType,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Reporter'),
                initialValue: incident.reporter,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Reporter Email'),
                initialValue: incident.reporterEmail,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date & Time', prefixIcon: Icon(Icons.access_time)),
                initialValue: incident.dateTime,
                enabled: false,
              ),
              GestureDetector(
                onTap: _showMap,
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on)),
                  child: Text(incident.location.latitude.toString() + incident.location.longitude.toString()),

                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Project Name'),
                initialValue: incident.projectName,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Route'),
                initialValue: incident.route,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'ELR'),
                initialValue: incident.elr,
                enabled: false,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mileage'),
                initialValue: incident.mileage.toString(),
                enabled: false,
              ),
          InputDecorator(
            decoration: InputDecoration(labelText: 'Summary'),
            child: Text(incident.summary),

          ),
              Container(child: ImageViewer(photos: incident.images)),
              SizedBox(
                height: 10.0,
              ),

            ],
          )),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          appBar: AppBar(
            title: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {

                  double appBarWidth = constraints.maxWidth;

                  return Container(alignment: Alignment.center ,width: appBarWidth * 0.9, child: Text(model.selectedIncident.incidentType + ' - ' + model.selectedIncident.dateTime),);

                }),
          ),
          body: _buildPageContent(context, model.selectedIncident),
        );
      },
    );
  }
}
