import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/helpers/app_side_drawer.dart';

class TestMaps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TestMapsState();
  }
}

class _TestMapsState extends State<TestMaps> {
  GoogleMapController mapController;

  final LatLng _center = LatLng(40.7128, -74.0060);

  void _onMapCreated(GoogleMapController controller) {
    //not sure if i actually need to set the state

      mapController = controller;
      mapController.addMarker(MarkerOptions(
          draggable: false,
          position: LatLng(40.7128, -74.0060),
          infoWindowText: InfoWindowText('My Marker', 'Marker text')

      ));


  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Test Maps'),
        ),
        drawer: SideDrawer(),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          options: GoogleMapOptions(
              cameraPosition:
              CameraPosition(target: _center, zoom: 10.0)),
        ),);
  }
}
