import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:incident_reporting_new/scoped_models/incidents_model.dart';
import 'package:incident_reporting_new/shared/global_config.dart';
import 'package:incident_reporting_new/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';
import '../shared/global_functions.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  IncidentsModel _incidentsModel;
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(55.3781, 3.4360), zoom: 30);
  bool _loading = false;
  List<Marker> markers = <Marker>[];
  @override
  void initState() {
    _loading = true;
    _incidentsModel = Provider.of<IncidentsModel>(context, listen: false);
    _getCameraPosition();
    // TODO: implement initState
    super.initState();
  }

  _getCameraPosition() async {

    if(_incidentsModel.selectedIncident.latitude == null){
      Map<String, dynamic> result = await GlobalFunctions.geocodePostcode(_incidentsModel.selectedIncident.postcode);
      if(result != null){
        _cameraPosition = CameraPosition(target: LatLng(result['latitude'], result['longitude']), zoom: 14);
        markers.add(Marker(markerId: MarkerId('incidentMarker'),
          position: LatLng(result['latitude'], result['longitude']),
          infoWindow: InfoWindow(title: _incidentsModel.selectedIncident.type),));
      }
    } else {
      _cameraPosition = CameraPosition(target: LatLng(_incidentsModel.selectedIncident.latitude, _incidentsModel.selectedIncident.longitude), zoom: 14);
      markers.add(Marker(markerId: MarkerId('incidentMarker'),
        position: LatLng(_incidentsModel.selectedIncident.latitude, _incidentsModel.selectedIncident.longitude),
        infoWindow: InfoWindow(title: _incidentsModel.selectedIncident.type),));
    }
    _loading = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text(_incidentsModel.selectedIncident.type +
                ' ' + 'Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
      ),
      body: _loading ? Center(child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(orangeDesign1),
      ),) : GoogleMap(
        mapType: MapType.hybrid,
        markers: Set<Marker>.of(markers),
        initialCameraPosition: _cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
