import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:location/location.dart' as geoloc;
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import '../../models/location_data.dart';
import '../../models/product.dart';
import '../../shared/global_config.dart';

class LocateUser extends StatefulWidget {
  final Function setLocation;


  LocateUser(this.setLocation);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocateUserState();
  }
}

class _LocateUserState extends State<LocateUser> {

  Uri _staticMapUri;
  LocationData _locationData;
  final FocusNode _locationInputFocusNode = FocusNode();
  final TextEditingController _locationInputController = TextEditingController();

  @override
  void initState() {
    _locationInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    _locationInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    print('ok its going to geocode');
    if (geocode) {

      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {'address': address, 'key': browserApi},
      );
      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coords = decodedResponse['results'][0]['geometry']['location'];
      _locationData = LocationData(
          address: formattedAddress,
          latitude: coords['lat'],
          longitude: coords['lng']);
    } else {
      _locationData =
          LocationData(address: address, latitude: lat, longitude: lng);
    }

    //prevent memory leaks
    if (mounted) {

      final StaticMapProvider staticMapViewProvider =
          StaticMapProvider(browserApi);
      final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', _locationData.latitude,
            _locationData.longitude)
      ],
          center: Location(_locationData.latitude, _locationData.longitude),
          width: 500,
          height: 300,
          maptype: StaticMapViewType.roadmap);
      widget.setLocation(_locationData);
      setState(() {
        //_locationInputController.text = _locationData.latitude.toString() + " " + _locationData.longitude.toString();
        _staticMapUri = staticMapUri;
      });
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    print('its inside get address');

    String platformType;
    if(Platform.isIOS)
      platformType = 'ios';
    else if(Platform.isAndroid)
      platformType = 'android';

    print(platformType);

    final Uri uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '${lat.toString()},${lng.toString()}',
        'key': apiKey[platformType]
      },
    );

    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    print('formatted address:');
    print(formattedAddress);
    return formattedAddress;
  }

  //get the users location using the location package
  void _getUserLocation() async {
    final geoloc.Location location = geoloc.Location();
    try {
      final Map<String, double> currentLocation = await location.getLocation();
      String message = 'Unable to load Map';

      if(currentLocation == null){
        message = 'Unable to fetch current Location';
        widget.setLocation(_locationData);
        _locationInputController.text = _locationData.latitude.toString() + " " + _locationData.longitude.toString();
      }

      _locationData = LocationData(
          address: null,
          latitude: currentLocation['latitude'],
          longitude: currentLocation['longitude']);

      setState(() {
        widget.setLocation(_locationData);
        _locationInputController.text = _locationData.latitude.toString() + " " + _locationData.longitude.toString();
      });

      print(currentLocation['latitude']);
      final address = await _getAddress(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );
      _getStaticMap(
        address,
        geocode: false,
        lat: currentLocation['latitude'],
        lng: currentLocation['longitude'],
      );
    } catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unable to load Map'),
              content: Text('Location will still be recorded'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                )
              ],
            );
          });
    }
  }

  void _updateLocation() {
    if (!_locationInputFocusNode.hasFocus) {
      _getStaticMap(_locationInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('this is the controller: ' + _locationInputController.text);
    return Column(
      children: <Widget>[
        Row(children: <Widget>[
          Flexible(child: IgnorePointer(child: TextFormField(enabled: true,
            decoration: InputDecoration(labelText: 'Location'),
            controller: _locationInputController,
            validator: (String value) {
              if (value.trim().length <= 0 && value.isEmpty) {
                return 'please enter a location latitude & longitude';
              }
            },
            onSaved: (String value) {
              setState(() {
                widget.setLocation(_locationData);
              });
            },


          ),)),

          IconButton(icon: Icon(Icons.location_on, color: orangeDesign1,), onPressed: _getUserLocation)
        ],),

        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString())
      ],
    );
  }
}
