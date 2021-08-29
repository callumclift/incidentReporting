import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:incident_reporting_new/widgets/app_bar_gradient.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import '../models/authenticated_user.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../widgets/helpers/image_viewer.dart';
import '../scoped_models/incidents_model.dart';
import '../scoped_models/users_model.dart';
import './map_view_page.dart';

class CompletedIncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedIncidentPageState();
  }
}

class _CompletedIncidentPageState extends State<CompletedIncidentPage> {
  bool refreshIcon = false;
  //GoogleMapController _mapController;
  String _location = '';
  bool _hasPostcode = false;
  double _latitude;
  double _longitude;
  int _customFieldCount = 0;
  IncidentsModel incidentsModel;

  @override
  void initState() {

    incidentsModel = Provider.of<IncidentsModel>(context, listen: false);

    if (incidentsModel.selectedIncident.images == null) {
      incidentsModel.getIncidentImages();
    }

    if (incidentsModel.selectedIncident.customFields != null)
      _customFieldCount = incidentsModel.selectedIncident.customFields.length;

    super.initState();
  }



  Widget _buildPageContent() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 800.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
          margin: EdgeInsets.all(10.0),
          child: incidentsModel.isLoading
              ? RefreshIndicator(
                  color: orangeDesign1,
                  child: _scrollView(targetPadding),
                  onRefresh: incidentsModel.getIncidentImages)
              : _scrollView(targetPadding)),
    );
  }

  String _locationText() {
    print('looking for postcode');
    print(incidentsModel.selectedIncident.postcode);

    if (incidentsModel.selectedIncident.latitude == null &&
        incidentsModel.selectedIncident.postcode == null &&
        incidentsModel.selectedIncident.postcode == null) {
      _location = 'No location recorded';
    } else if (incidentsModel.selectedIncident.postcode != null) {
      _location = incidentsModel.selectedIncident.postcode;
      _hasPostcode = true;
    } else if (incidentsModel.selectedIncident.latitude != null &&
        incidentsModel.selectedIncident.longitude != null) {
      _location = incidentsModel.selectedIncident.latitude.toString() +
          incidentsModel.selectedIncident.longitude.toString();
    }

    return _location;
  }

  Widget _scrollView(double targetPadding) {
    return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Incident Type'),
              initialValue: incidentsModel.selectedIncident.type,
              enabled: false,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Reporter'),
              initialValue: incidentsModel.selectedIncident.anonymous
                  ? 'Anonymous'
                  : incidentsModel.selectedIncident.fullName,
              enabled: false,
            ),
            incidentsModel.selectedIncident.anonymous
                ? Container()
                : TextFormField(
                    decoration: InputDecoration(labelText: 'Reporter Username'),
                    initialValue: incidentsModel.selectedIncident.anonymous
                        ? 'Anonymous'
                        : incidentsModel.selectedIncident.username,
                    enabled: false,
                  ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Date & Time',
                  prefixIcon: Icon(Icons.access_time)),
              initialValue: incidentsModel.selectedIncident.incidentDate,
              enabled: false,
            ),
            GestureDetector(
              onTap: () async{
                print('tapped');
                //_showMap(model)

                if (_location != 'No location recorded') {
                  if (_hasPostcode && _latitude == null && _longitude == null) {

                    Map<String, dynamic> result = await GlobalFunctions.geocodePostcode(incidentsModel.selectedIncident.postcode);
                      if (result['success']) {
                        _latitude = result['latitude'];
                        _longitude = result['longitude'];
                      } else {
                        GlobalFunctions.showToast(result['message']);
                      }

                  } else if(!_hasPostcode && incidentsModel.selectedIncident.latitude != null && incidentsModel.selectedIncident.longitude != null){
                    _latitude = incidentsModel.selectedIncident.latitude;
                    _longitude = incidentsModel.selectedIncident.longitude;

                  }

                  if (_latitude != null && _longitude != null) {
                    Connectivity()
                        .checkConnectivity()
                        .then((ConnectivityResult result) {
                      if (result != ConnectivityResult.none) {

                        //_showMap(model);

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
                    labelText: 'Location', prefixIcon: IconButton(icon: Icon(Icons.location_on, color: incidentsModel.selectedIncident.latitude == null &&
                    incidentsModel.selectedIncident.postcode == null ? Colors.grey : orangeDesign1,), onPressed: incidentsModel.selectedIncident.latitude == null &&
                    incidentsModel.selectedIncident.postcode == null ? null : () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return MapView();
                  }));
                },)),
                child: Text(_locationText()),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Project Name'),
              initialValue: incidentsModel.selectedIncident.projectName,
              enabled: false,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Route'),
              initialValue: incidentsModel.selectedIncident.route,
              enabled: false,
            ),
            InputDecorator(
                decoration: InputDecoration(labelText: 'ELR'),
                child: Text(
                  incidentsModel.selectedIncident.elr,
                  style: TextStyle(fontSize: 16.0),
                )),
            TextFormField(
              decoration: InputDecoration(labelText: 'Mileage'),
              initialValue: incidentsModel.selectedIncident.mileage.toString(),
              enabled: false,
            ),
            _customFieldCount > 0 ? _buildCustomFields() : Container(),
            InputDecorator(
              decoration: InputDecoration(labelText: 'Summary'),
              child: Text(incidentsModel.selectedIncident.summary),
            ),
            SizedBox(
              height: 10.0,
            ),
            Consumer<IncidentsModel>(
                builder: (BuildContext context, model, child) {
                  return _buildImagesSection();
                }),
          ],
        ));
  }

  Widget _buildCustomFields() {
    Widget customFields;

    if (_customFieldCount == 1) {
      customFields = TextFormField(
        decoration: InputDecoration(
            labelText: incidentsModel.selectedIncident.customFields[0]
                ['label']),
        initialValue:
            incidentsModel.selectedIncident.customFields[0]['value'] == null
                ? ''
                : incidentsModel.selectedIncident.customFields[0]['value'],
        enabled: false,
      );
    } else if (_customFieldCount == 2) {
      customFields = Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: incidentsModel.selectedIncident.customFields[0]
                    ['label']),
            initialValue:
                incidentsModel.selectedIncident.customFields[0]['value'] == null
                    ? ''
                    : incidentsModel.selectedIncident.customFields[0]['value'],
            enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: incidentsModel.selectedIncident.customFields[1]
                    ['label']),
            initialValue:
                incidentsModel.selectedIncident.customFields[1]['value'] == null
                    ? ''
                    : incidentsModel.selectedIncident.customFields[1]['value'],
            enabled: false,
          )
        ],
      );
    } else if (_customFieldCount == 3) {
      Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                labelText: incidentsModel.selectedIncident.customFields[0]
                    ['label']),
            initialValue:
                incidentsModel.selectedIncident.customFields[0]['value'] == null
                    ? ''
                    : incidentsModel.selectedIncident.customFields[0]['value'],
            enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: incidentsModel.selectedIncident.customFields[1]
                    ['label']),
            initialValue:
                incidentsModel.selectedIncident.customFields[1]['value'] == null
                    ? ''
                    : incidentsModel.selectedIncident.customFields[1]['value'],
            enabled: false,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: incidentsModel.selectedIncident.customFields[2]
                    ['label']),
            initialValue:
                incidentsModel.selectedIncident.customFields[2]['value'] == null
                    ? ''
                    : incidentsModel.selectedIncident.customFields[2]['value'],
            enabled: false,
          )
        ],
      );
    }

    return customFields;
  }

  Widget _buildImagesSection() {
    if (incidentsModel.isLoading) {
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
    } else if (incidentsModel.selectedIncident.images == null) {
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
    } else if (!incidentsModel.isLoading &&
        incidentsModel.selectedIncident.images.length == 0) {
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
          child: ImageViewer(photos: incidentsModel.selectedIncident.images));
    }
  }

  @override
  Widget build(BuildContext context) {

    final IncidentsModel _incidentsModel = Provider.of<IncidentsModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: AppBarGradient(),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text(_incidentsModel.selectedIncident.type +
                ' - ' +
                _incidentsModel.selectedIncident.incidentDate, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
      ),
      body: _buildPageContent(),
    );
  }
}