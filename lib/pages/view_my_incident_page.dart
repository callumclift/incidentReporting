import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart' as map;
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

import '../models/incident.dart';
import '../models/location_data.dart';
import '../models/authenticated_user.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../widgets/helpers/image_viewer.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/form_inputs/locate_user.dart';
import '../scoped_models/incidents_model.dart';
import '../scoped_models/users_model.dart';

class ViewMyIncidentPage extends StatefulWidget {
  final IncidentsModel model;

  ViewMyIncidentPage(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewMyIncidentPageState();
  }
}

class _ViewMyIncidentPageState extends State<ViewMyIncidentPage> {
  bool refreshIcon = false;
  //GoogleMapController _mapController;
  String _location = '';
  bool _hasPostcode = false;
  double _latitude;
  double _longitude;
  int _customFieldCount = 0;
  AuthenticatedUser _authenticatedUser;

  @override
  void initState() {
    _authenticatedUser = ScopedModel.of<UsersModel>(context).authenticatedUser;

    if (widget.model.selectedMyIncident.images == null) {
      _getIncidentImages();
    }

    if (widget.model.selectedMyIncident.customFields != null)
      _customFieldCount = widget.model.selectedMyIncident.customFields.length;

    super.initState();
  }

  Future<void> _getIncidentImages() async {
    widget.model
        .getIncidentImages(_authenticatedUser)
        .then((Map<String, dynamic> map) {
      refreshIcon = false;

      if (!map['success']) {
        print('its in map not success');

        if (map['message'] == 'No data connection, please try again later') {
          refreshIcon = true;

          Fluttertoast.showToast(
              msg: 'No Data Connection',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIos: 3,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: orangeDesign1,
              textColor: Colors.black);
        }
      } else if (map['success'] &&
          map['message'] == 'There are no images attached to this incident') {
        print('this is where it should be');

      }
    });
  }

//  void _showMap(IncidentsModel model) {
//    final List<Marker> markers = <Marker>[
//      Marker('position', 'Incident', model.selectedMyIncident.latitude,
//          model.selectedMyIncident.longitude)
//    ];
//    final CameraPosition cameraPosition = CameraPosition(
//        Location(model.selectedMyIncident.latitude, model.selectedMyIncident.longitude), 14.0);
//    final MapView mapView = MapView();
//    mapView.show(
//      MapOptions(
//          title: 'Map of Incident',
//          mapViewType: MapViewType.normal,
//          initialCameraPosition: cameraPosition),
//      toolbarActions: [ToolbarAction('Close', 1)],
//    );
//    mapView.onToolbarAction.listen((int id) {
//      if (id == 1) {
//        mapView.dismiss();
//      }
//    });
//    mapView.onMapReady.listen((_) {
//      mapView.setMarkers(markers);
//    });
//  }

  Widget _buildPageContent(BuildContext context, IncidentsModel model) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 800.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    print('building page content');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
          margin: EdgeInsets.all(10.0),
          child: widget.model.selectedMyIncident.images == null
              ? RefreshIndicator(
                  color: orangeDesign1,
                  child: _scrollView(model, targetPadding),
                  onRefresh: _getIncidentImages)
              : _scrollView(model, targetPadding)),
    );
  }

  String _locationText() {
    print('looking for postcode');
    print(widget.model.selectedMyIncident.postcode);

    if (widget.model.selectedMyIncident.latitude == null &&
        widget.model.selectedMyIncident.postcode == null &&
        widget.model.selectedMyIncident.postcode == null) {
      _location = 'No location recorded';
    } else if (widget.model.selectedMyIncident.postcode != null) {
      _location = widget.model.selectedMyIncident.postcode;
      _hasPostcode = true;
    } else if (widget.model.selectedMyIncident.latitude != null &&
        widget.model.selectedMyIncident.longitude != null) {
      _location = widget.model.selectedMyIncident.latitude.toString() +
          widget.model.selectedMyIncident.longitude.toString();
    }

    return _location;
  }

  Widget _scrollView(IncidentsModel model, double targetPadding) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Incident Type'),
              initialValue: model.selectedMyIncident.type,
              enabled: false,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Reporter'),
              initialValue: model.selectedMyIncident.anonymous
                  ? 'Anonymous'
                  : model.selectedMyIncident.fullName,
              enabled: false,
            ),
            model.selectedMyIncident.anonymous
                ? Container()
                : TextFormField(
                    decoration: InputDecoration(labelText: 'Reporter Username'),
                    initialValue: model.selectedMyIncident.anonymous
                        ? 'Anonymous'
                        : model.selectedMyIncident.username,
                    enabled: false,
                  ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Date & Time',
                  prefixIcon: Icon(Icons.access_time)),
              initialValue: model.selectedMyIncident.incidentDate,
              enabled: false,
            ),
            GestureDetector(
              onTap: () async{
                print('tapped');
                //_showMap(model)

                if (_location != 'No location recorded') {
                  if (_hasPostcode && _latitude == null && _longitude == null) {

                    Map<String, dynamic> result = await GlobalFunctions.geocodePostcode(model.selectedMyIncident.postcode);
                      if (result['success']) {
                        _latitude = result['latitude'];
                        _longitude = result['longitude'];
                      } else {
                        GlobalFunctions.showToast(result['message']);
                      }

                  } else if(!_hasPostcode && model.selectedMyIncident.latitude != null && model.selectedMyIncident.longitude != null){
                    _latitude = model.selectedMyIncident.latitude;
                    _longitude = model.selectedMyIncident.longitude;

                  }

                  if (_latitude != null && _longitude != null) {
                    Connectivity()
                        .checkConnectivity()
                        .then((ConnectivityResult result) {
                      if (result != ConnectivityResult.none) {

                        _showMap(model);

                      } else {
                        GlobalFunctions.showToast(
                            'No data connection to load Map');
                      }
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                    labelText: 'Location', prefixIcon: Icon(Icons.location_on)),
                child: Text(_locationText()),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Project Name'),
              initialValue: model.selectedMyIncident.projectName,
              enabled: false,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Route'),
              initialValue: model.selectedMyIncident.route,
              enabled: false,
            ),
            InputDecorator(
                decoration: InputDecoration(labelText: 'ELR'),
                child: Text(
                  model.selectedMyIncident.elr,
                  style: TextStyle(fontSize: 16.0),
                )),
            TextFormField(
              decoration: InputDecoration(labelText: 'Mileage'),
              initialValue: model.selectedMyIncident.mileage.toString(),
              enabled: false,
            ),
            _customFieldCount > 0 ? _buildCustomFields() : Container(),
            InputDecorator(
              decoration: InputDecoration(labelText: 'Summary'),
              child: Text(model.selectedMyIncident.summary),
            ),
            SizedBox(
              height: 10.0,
            ),
            _buildImagesSection(model),
          ],
        ));
  }

  void _showMap(IncidentsModel model) {
    final List<map.Marker> markers = <map.Marker>[
      map.Marker('position', model.selectedMyIncident.type + ' ' + '(' + model.selectedMyIncident.incidentDate + ')',  _latitude,
          _longitude)
    ];
    final map.CameraPosition cameraPosition = map.CameraPosition(
        map.Location(_latitude, _longitude), 14.0);
    final map.MapView mapView = map.MapView();
    mapView.show(
      map.MapOptions(showCompassButton: true,
          title: 'Map of Incident',
          mapViewType: map.MapViewType.normal,
          initialCameraPosition: cameraPosition),
      toolbarActions: [map.ToolbarAction('Close', 1)],
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

  Widget _buildCustomFields() {
    Widget customFields;

    if (_customFieldCount == 1) {
      customFields = TextFormField(
        decoration: InputDecoration(
            labelText: widget.model.selectedMyIncident.customFields[0]
                ['label']),
        initialValue:
            widget.model.selectedMyIncident.customFields[0]['value'] == null
                ? ''
                : widget.model.selectedMyIncident.customFields[0]['value'],
        enabled: false,
      );
    } else if (_customFieldCount == 2) {
      customFields = Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: widget.model.selectedMyIncident.customFields[0]
                    ['label']),
            initialValue:
                widget.model.selectedMyIncident.customFields[0]['value'] == null
                    ? ''
                    : widget.model.selectedMyIncident.customFields[0]['value'],
            enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: widget.model.selectedMyIncident.customFields[1]
                    ['label']),
            initialValue:
                widget.model.selectedMyIncident.customFields[1]['value'] == null
                    ? ''
                    : widget.model.selectedMyIncident.customFields[1]['value'],
            enabled: false,
          )
        ],
      );
    } else if (_customFieldCount == 3) {
      Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: widget.model.selectedMyIncident.customFields[0]
                    ['label']),
            initialValue:
                widget.model.selectedMyIncident.customFields[0]['value'] == null
                    ? ''
                    : widget.model.selectedMyIncident.customFields[0]['value'],
            enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: widget.model.selectedMyIncident.customFields[1]
                    ['label']),
            initialValue:
                widget.model.selectedMyIncident.customFields[1]['value'] == null
                    ? ''
                    : widget.model.selectedMyIncident.customFields[1]['value'],
            enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: widget.model.selectedMyIncident.customFields[2]
                    ['label']),
            initialValue:
                widget.model.selectedMyIncident.customFields[2]['value'] == null
                    ? ''
                    : widget.model.selectedMyIncident.customFields[2]['value'],
            enabled: false,
          )
        ],
      );
    }

    return customFields;
  }

  Widget _buildImagesSection(IncidentsModel model) {
    if (model.isLoading) {
      return Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(orangeDesign1),
          ),
          SizedBox(height: 10.0),
          Text('Loading Images')
        ],
      );
    } else if (model.selectedMyIncident.images == null) {
      return Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Text('Unable to Load Images, pull down to refresh'),
          refreshIcon == true
              ? Icon(
                  Icons.warning,
                  color: orangeDesign1,
                  size: 40.0,
                )
              : Container(),
        ],
      );
    } else if (!model.isLoading &&
        model.selectedMyIncident.images.length == 0) {
      return Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Text('There are no images attached to this incident'),
          refreshIcon == true
              ? Icon(
                  Icons.warning,
                  color: orangeDesign1,
                  size: 40.0,
                )
              : Container(),
        ],
      );
    } else {
      return Container(
          child: ImageViewer(photos: model.selectedMyIncident.images));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build

    final IncidentsModel _incidentsModel =
        ScopedModel.of<IncidentsModel>(context, rebuildOnChange: true);

    print('here is the selected incident');
    print(_incidentsModel.selectedMyIncident);

    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double appBarWidth = constraints.maxWidth;

          return Container(
            alignment: Alignment.center,
            width: appBarWidth * 0.9,
            child: Text(_incidentsModel.selectedMyIncident.type +
                ' - ' +
                _incidentsModel.selectedMyIncident.incidentDate),
          );
        }),
      ),
      body: _buildPageContent(context, _incidentsModel),
    );
  }
}