import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_view/map_view.dart';
import 'package:image/image.dart' as imagePackage;
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path_provider/path_provider.dart';


import '../models/location_data.dart';
import '../models/incident_type.dart';
import '../widgets/form_inputs/locate_user.dart';
import '../widgets/helpers/app_side_drawer.dart';
import '../widgets/ui_elements/dropdown_formfield.dart';
import '../widgets/helpers/add_images.dart';
import '../shared/global_functions.dart';
import '../shared/global_config.dart';
import '../scoped_models/incidents_model.dart';
import '../scoped_models/users_model.dart';

class RaiseIncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RaiseIncidentPageState();
  }
}

class _RaiseIncidentPageState extends State<RaiseIncidentPage>
    with AfterLayoutMixin<RaiseIncidentPage> {
  GoogleMapController _mapController;
  bool _disableScreen = false;
  IncidentsModel _incidentsModel;
  UsersModel _usersModel;
  Map<String, dynamic> _temporaryIncident = new Map();
  List<dynamic> _temporaryPaths = [];
  IncidentType _currentIncidentType;



  List<IncidentType> _incidentTypes = [];

  final List<String> _incidentDrop = [
    'Incident',
    'Close Call',
    'Near Miss',
    'Workplace Accident'
  ];
  final List<String> _routeDrop = [
    'Select a Route',
    'Anglia',
    'Southeast',
    'London North East',
    'London North West (North)',
    'London North West (South)',
    'East Midlands',
    'Scotland',
    'Wales',
    'Wessex',
    'Western (West)',
    'Western (Thames Valley)'
  ];
  final List<String> _elrDrop = [
    'Select an ELR',
    'Anglia',
    'Southeast',
    'London North East',
  ];

  final List<String> _locationDrop = ['Latitude/Longitude', 'Post Code'];

  String _incidentValue = 'Incident';
  String _locationValue = 'Latitude/Longitude';
  String _routeValue = 'Select a Route';
  String _elrValue = 'Select an ELR';
  String _customLabel1 = '';
  String _customLabel2 = '';
  String _customLabel3 = '';
  String _customPlaceholder1 = '';
  String _customPlaceholder2 = '';
  String _customPlaceholder3 = '';
  bool _isAnonymous = false;
  String _staticMapPostcode;
  String _staticMapLocation;
  int _customFieldCount = 0;
  double _latitude;
  double _longitude;

  final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
  DateTime date;

  TextEditingController _reporterTextController = TextEditingController();
  final TextEditingController _summaryTextController = TextEditingController();
  final TextEditingController _mileageTextController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _dateTimeController1 = TextEditingController();
  final TextEditingController _customField1Controller = TextEditingController();
  final TextEditingController _customField2Controller = TextEditingController();
  final TextEditingController _customField3Controller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _projectNameFocusNode = new FocusNode();
  final FocusNode _postcodeFocusNode = new FocusNode();
  final FocusNode _mileageFocusNode = new FocusNode();
  final FocusNode _summaryFocusNode = new FocusNode();
  final FocusNode _customField1FocusNode = new FocusNode();
  final FocusNode _customField2FocusNode = new FocusNode();
  final FocusNode _customField3FocusNode = new FocusNode();
  Color _projectNameLabelColor = Colors.grey;
  Color _postcodeLabelColor = Colors.grey;
  Color _mileageLabelColor = Colors.grey;
  Color _summaryLabelColor = Colors.grey;
  Color _customField1LabelColor = Colors.grey;
  Color _customField2LabelColor = Colors.grey;
  Color _customField3LabelColor = Colors.grey;

  //this is a map to manage the form data
  final Map<String, dynamic> _formData = {
    'incidentType': 'Incident',
    'reporterFirstName': null,
    'reporterLastName': null,
    'dateTime': null,
    'latitude': null,
    'longitude': null,
    'postcode': null,
    'projectName': null,
    'route': null,
    'elr': null,
    'mileage': null,
    'summary': null,
    'images': null,
    'customField1': null,
    'customField2': null,
    'customField3': null,
    'customLabel1': null,
    'customLabel2': null,
    'customLabel3': null,
    'customPlaceholder1': null,
    'customPlaceholder2': null,
    'customPlaceholder3': null,

  };

  bool _pickInProgress = false;

  static File _imageFile1;
  static File _imageFile2;
  static File _imageFile3;
  static File _imageFile4;
  static File _imageFile5;

  List<File> images = [
    _imageFile1,
    _imageFile2,
    _imageFile3,
    _imageFile4,
    _imageFile5,
  ];


  @override
  void initState() {
    print('inside initState');
    _incidentsModel = ScopedModel.of<IncidentsModel>(context);
    _usersModel = ScopedModel.of<UsersModel>(context);

    if (_incidentsModel.allIncidentTypes != null) {
      _incidentTypes = _incidentsModel.allIncidentTypes;
      for (IncidentType incidentType in _incidentTypes) {
        _incidentDrop.add(incidentType.name);

        IncidentType test = _incidentTypes
            .firstWhere((incidentType) => incidentType.name == 'Test Incident');

        print(test.customPlaceholder1);
      }
    }

    _getTemporaryIncident();

    _getIncidentTypes();

    print('this should print after');
    
    _setupTextListeners(_incidentsModel, _usersModel);

    _populateImageFiles();

    super.initState();
    _setupFocusNodes();
  }

  _populateImageFiles() {
    _incidentsModel
        .getTemporaryIncident(_usersModel.authenticatedUser.userId)
        .then((Map<String, dynamic> incident) {
      if (incident['images'] != null) {
        _temporaryPaths = jsonDecode(incident['images']);

        print('this is where i need to be');
        print(_temporaryPaths);
        print('ok done');

        if (_temporaryPaths != null) {
          print('here is the temporary paths');
          print(_temporaryPaths);

          int index = 0;
          _temporaryPaths.forEach((dynamic path) {
            if (path != null) {
              setState(() {
                images[index] = File(path);
              });
            }

            index++;
          });
        }
      }
    });
  }

  _getTemporaryIncident(){

    _incidentsModel.getTemporaryIncident(_usersModel.authenticatedUser.userId).then((Map<String, dynamic> incident){

      if(incident['type'] != null){
        _incidentValue = incident['type'];
      }
      if(incident['anonymous'] != null && incident['anonymous'] == 'true'){
        _isAnonymous = true;
      } else {
        _isAnonymous = false;
      }
      if(incident['incident_date'] != null){
        _dateTimeController1.text = incident['incident_date'];
      }
      if(incident['location_drop'] != null){
        _locationValue = incident['location_drop'];
      }
      if(incident['latitude'] != null && incident['longitude'] != null){
        _locationController.text = incident['latitude'] + ' ' + incident['longitude'];
        _latitude = double.parse(incident['latitude']);
        _longitude = double.parse(incident['longitude']);
      }
      if(incident['postcode'] != null){
        _postcodeController.text = incident['postcode'];
      }
      if(incident['location_map'] != null){
        _staticMapLocation = incident['location_map'];
      }
      if(incident['postcode_map'] != null){
        _staticMapPostcode = incident['postcode_map'];
      }
      if(incident['project_name'] != null){
        _projectNameController.text = incident['project_name'];
      }
      if(incident['route'] != null){
        _routeValue = incident['route'];
      }
      if(incident['elr'] != null){
        _elrValue = incident['elr'];
      }
      if(incident['mileage'] != null){
        _mileageTextController.text = incident['mileage'];
      }
      if(incident['summary'] != null){
        _summaryTextController.text = incident['summary'];
      }
      if(incident['images'] != null){
          _temporaryPaths = jsonDecode(incident['images']);
      }
      if(incident['custom_fields'] != null){
        List<dynamic> customFields = jsonDecode(incident['custom_fields']);

        _customFieldCount = customFields.length;

        if(_customFieldCount >= 1){

          _customLabel1 = customFields[0]['label'];
          _customPlaceholder1 = customFields[0]['placeholder'];
          _customField1Controller.text = incident['custom_value1'] == null || incident['custom_value1'] == 'null' ? '' : incident['custom_value1'];

        }
        if (_customFieldCount >= 2){

          _customLabel2 = customFields[1]['label'];
          _customPlaceholder2 = customFields[1]['placeholder'];
          _customField2Controller.text = incident['custom_value2'] == null || incident['custom_value2'] == 'null' ? '' : incident['custom_value2'];

        }
        if (_customFieldCount >= 3){

          _customLabel3 = customFields[2]['label'];
          _customPlaceholder3 = customFields[2]['placeholder'];
          _customField3Controller.text = incident['custom_value3'] == null || incident['custom_value3'] == 'null' ? '' : incident['custom_value3'];

        }
      }



    });
  }

  _getIncidentTypes() {
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        GlobalFunctions.showToast('Unable to fetch latest Incident Types');
      } else {
        _incidentsModel
            .getCustomIncidents()
            .then((Map<String, dynamic> result) {
          if (!result['success']) {
            GlobalFunctions.showToast('Unable to fetch latest Incident Types');
          } else {
            if (_incidentsModel.allIncidentTypes != null) {
              _incidentTypes = _incidentsModel.allIncidentTypes;
              for (IncidentType incidentType in _incidentTypes) {

                bool exists = _incidentDrop.contains(incidentType.name);

                if(!exists) _incidentDrop.add(incidentType.name);

              }
            }
          }
        });
      }
    });
  }
  
  _setupTextListeners(IncidentsModel incidentsModel, UsersModel usersModel){
    
    _projectNameController.addListener((){
      incidentsModel.updateTemporaryIncidentField('project_name', _projectNameController.text, usersModel.authenticatedUser.userId);
    });
    _postcodeController.addListener((){
      incidentsModel.updateTemporaryIncidentField('postcode', _postcodeController.text, usersModel.authenticatedUser.userId);
    });
    _summaryTextController.addListener((){
      incidentsModel.updateTemporaryIncidentField('summary', _summaryTextController.text, usersModel.authenticatedUser.userId);
    });
    _mileageTextController.addListener((){
      incidentsModel.updateTemporaryIncidentField('mileage', _mileageTextController.text, usersModel.authenticatedUser.userId);
    });
    _dateTimeController1.addListener((){
      incidentsModel.updateTemporaryIncidentField('incident_date', _dateTimeController1.text, usersModel.authenticatedUser.userId);
    });
    _customField1Controller.addListener((){
      incidentsModel.updateTemporaryIncidentField('custom_value1', _customField1Controller.text, usersModel.authenticatedUser.userId);
    });
    _customField2Controller.addListener((){
      incidentsModel.updateTemporaryIncidentField('custom_value2', _customField2Controller.text, usersModel.authenticatedUser.userId);
    });
    _customField3Controller.addListener((){
      incidentsModel.updateTemporaryIncidentField('custom_value3', _customField3Controller.text, usersModel.authenticatedUser.userId);
    });


  }

  _setupFocusNodes() {

    _projectNameFocusNode.addListener(() {
      if (_projectNameFocusNode.hasFocus) {
        setState(() {
          _projectNameLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _projectNameLabelColor = Colors.grey;
        });
      }
    });

    _postcodeFocusNode.addListener(() {
      if (_postcodeFocusNode.hasFocus) {
        setState(() {
          _postcodeLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _postcodeLabelColor = Colors.grey;
        });
      }
    });

    _mileageFocusNode.addListener(() {
      if (_mileageFocusNode.hasFocus) {
        setState(() {
          _mileageLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _mileageLabelColor = Colors.grey;
        });
      }
    });
    _summaryFocusNode.addListener(() {
      if (_summaryFocusNode.hasFocus) {
        setState(() {
          _summaryLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _summaryLabelColor = Colors.grey;
        });
      }
    });

    _customField1FocusNode.addListener(() {
      if (_customField1FocusNode.hasFocus) {
        setState(() {
          _customField1LabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _customField1LabelColor = Colors.grey;
        });
      }
    });

    _customField2FocusNode.addListener(() {
      if (_customField2FocusNode.hasFocus) {
        setState(() {
          _customField2LabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _customField2LabelColor = Colors.grey;
        });
      }
    });

    _customField3FocusNode.addListener(() {
      if (_customField3FocusNode.hasFocus) {
        setState(() {
          _customField3LabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _customField3LabelColor = Colors.grey;
        });
      }
    });
  }

  Widget _buildIncidentDrop() {
    return DropdownFormField(
      hint: 'Incident Type',
      value: _incidentValue,
      items: _incidentDrop.toList(),
      onChanged: (val) => setState(() {
            _incidentValue = val;
            _formData['incidentType'] = _incidentValue;
            _customField1Controller.text = '';
            _customField2Controller.text = '';
            _customField3Controller.text = '';
            _incidentsModel.updateTemporaryIncidentField('type', val, _usersModel.authenticatedUser.userId);
            _incidentsModel.updateTemporaryIncidentField('custom_value1', null, _usersModel.authenticatedUser.userId);
            _incidentsModel.updateTemporaryIncidentField('custom_value2', null, _usersModel.authenticatedUser.userId);
            _incidentsModel.updateTemporaryIncidentField('custom_value3', null, _usersModel.authenticatedUser.userId);


            if (_incidentTypes.length > 0) {
              List<String> names = [];

              for (IncidentType types in _incidentTypes) {
                names.add(types.name);
              }

              bool exists = names.contains(val);

              if (exists) {
                IncidentType incidentType = _incidentTypes
                    .firstWhere((incidentType) => incidentType.name == val);

                List<Map<String, dynamic>> _temporaryCustomFields = [];

                if (incidentType.customLabel3 != null) {
                  setState(() {
                    _customLabel1 = incidentType.customLabel1;
                    _customLabel2 = incidentType.customLabel2;
                    _customLabel3 = incidentType.customLabel3;
                    _customPlaceholder1 = incidentType.customPlaceholder1;
                    _customPlaceholder2 = incidentType.customPlaceholder2;
                    _customPlaceholder3 = incidentType.customPlaceholder3;
                    _customFieldCount = 3;

                    _temporaryCustomFields.add({
                      'label': incidentType.customLabel1,
                      'placeholder': incidentType.customPlaceholder1
                    });
                    _temporaryCustomFields.add({
                      'label': incidentType.customLabel2,
                      'placeholder': incidentType.customPlaceholder2
                    });
                    _temporaryCustomFields.add({
                      'label': incidentType.customLabel3,
                      'placeholder': incidentType.customPlaceholder3
                    });

                    _incidentsModel.updateTemporaryIncidentField('custom_fields', jsonEncode(_temporaryCustomFields), _usersModel.authenticatedUser.userId);
                  });
                } else if (incidentType.customLabel2 != null) {
                  setState(() {
                    _customLabel1 = incidentType.customLabel1;
                    _customLabel2 = incidentType.customLabel2;
                    _customPlaceholder1 = incidentType.customPlaceholder1;
                    _customPlaceholder2 = incidentType.customPlaceholder2;
                    _customFieldCount = 2;

                    _temporaryCustomFields.add({
                      'label': incidentType.customLabel1,
                      'placeholder': incidentType.customPlaceholder1
                    });
                    _temporaryCustomFields.add({
                      'label': incidentType.customLabel2,
                      'placeholder': incidentType.customPlaceholder2
                    });
                    _incidentsModel.updateTemporaryIncidentField('custom_fields', jsonEncode(_temporaryCustomFields), _usersModel.authenticatedUser.userId);
                  });
                } else if (incidentType.customLabel1 != null) {
                  setState(() {
                    _customLabel1 = incidentType.customLabel1;
                    _customPlaceholder1 = incidentType.customPlaceholder1;
                    _customFieldCount = 1;
                    _temporaryCustomFields.add({
                      'label': incidentType.customLabel1,
                      'placeholder': incidentType.customPlaceholder1
                    });
                    _incidentsModel.updateTemporaryIncidentField('custom_fields', jsonEncode(_temporaryCustomFields), _usersModel.authenticatedUser.userId);
                  });
                }
              } else {
                print('not a custom');
                setState(() {
                  _customFieldCount = 0;
                  _incidentsModel.updateTemporaryIncidentField('custom_fields', null, _usersModel.authenticatedUser.userId);

                });
              }
            }
          }),
      validator: (val) => (val == null || val.isEmpty)
          ? 'Please choose an Incident Type'
          : null,
      initialValue: _incidentDrop[0],
      onSaved: (val) => setState(() {
            _incidentValue = val;
            _formData['incidentType'] = _incidentValue;
          }),
    );
  }

  Widget _buildRouteDrop() {
    return DropdownFormField(
      hint: 'Route',
      value: _routeValue,
      items: _routeDrop.toList(),
      onChanged: (val) => setState(() {
            _routeValue = val;
            _formData['route'] = _routeValue;
            _incidentsModel.updateTemporaryIncidentField('route', val, _usersModel.authenticatedUser.userId);

      }),
      validator: (String message){
        if(_routeValue == 'Select a Route') return 'Please select a Route';
      },
      initialValue: _routeDrop[0],
      onSaved: (val) => setState(() {
            _formData['route'] = _routeValue;
          }),
    );
  }

  Widget _buildElrDrop() {
    return DropdownFormField(
      hint: 'ELR',
      value: _elrValue,
      items: _elrDrop.toList(),
      onChanged: (val) => setState(() {
            _elrValue = val;
            _formData['elr'] = _elrValue;
            _incidentsModel.updateTemporaryIncidentField('elr', val, _usersModel.authenticatedUser.userId);

      }),
      validator: (String message){
        if(_elrValue == 'Select an ELR') return 'Please select an ELR';
      },
      initialValue: _elrDrop[0],
      onSaved: (val) => setState(() {
            _formData['elr'] = _elrValue;

          }),
    );
  }

  Widget _buildReporterField(UsersModel model) {
    if (model.authenticatedUser == null) {
      _reporterTextController.text = '';
    } else if (_isAnonymous) {
      _reporterTextController.text = 'Anonymous';
    } else {
      _reporterTextController.text = model.authenticatedUser.firstName +
          ' ' +
          model.authenticatedUser.lastName;
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Reporter Name'),
      controller: _reporterTextController,
      enabled: false,
      //initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ characters long';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['reporter'] = value;
        });
      },
    );
  }

  Widget _reportAnonymous(UsersModel model) {
    return CheckboxListTile(
        activeColor: orangeDesign1,
        title: Text('Report Anonymously'),
        value: _isAnonymous,
        onChanged: (bool value) => setState(() {
              _isAnonymous = value;
              _incidentsModel.updateTemporaryIncidentField('anonymous', value, _usersModel.authenticatedUser.userId);


        }));
  }

  Widget _dateTimeField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  decoration: InputDecoration(labelText: 'Date & Time'),
                  initialValue: null,
                  controller: _dateTimeController1,
                  validator: (String value) {
                    if (value.trim().length <= 0 && value.isEmpty) {
                      return 'please enter a Date & Time';
                    }
                  },
                  onSaved: (String value) {
                    setState(() {
                      _formData['dateTime'] = value;
                    });
                  },
                ),
              ),
            ),
            _dateTimeController1.text == ''
                ? Container()
                : IconButton(
                    color: Colors.grey,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _dateTimeController1.text = '';
                      });
                    }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: Color.fromARGB(255, 255, 147, 94)),
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1970),
                          lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      showTimePicker(
                              context: context, initialTime: TimeOfDay.now())
                          .then((TimeOfDay time) {
                        if (time != null) {
                          newDate = startOfDay(newDate);
                          newDate = newDate.add(
                              Duration(hours: time.hour, minutes: time.minute));
                          String dateTime = dateFormat.format(newDate);
                          setState(() {
                            _dateTimeController1.text = dateTime;
                            _formData['dateTime'] = dateTime;
                          });
                        }
                      });
                    }
                  });
                })
          ],
        ),
      ],
    );
  }

  Widget _buildLocationDrop() {
    return DropdownFormField(
      hint: 'Location Type',
      value: _locationValue,
      items: _locationDrop.toList(),
      onChanged: (val) => setState(() {
            print(val);
            _locationValue = val;
            _incidentsModel.updateTemporaryIncidentField('location_drop', val, _usersModel.authenticatedUser.userId);

      }),
      validator: (val) => (val == null || val.isEmpty)
          ? 'Please choose a Location Type'
          : null,
      initialValue: _locationDrop[0],
      onSaved: (val) => setState(() {
            _locationValue = val;
          }),
    );
  }

  Widget _buildPostcodeField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
                child: TextFormField(
              focusNode: _postcodeFocusNode,
              decoration: InputDecoration(
                  labelStyle: TextStyle(color: _postcodeLabelColor),
                  labelText: 'Post Code',
                  suffixIcon: _postcodeController.text == ''
                      ? null
                      : IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _postcodeController.clear();
                              _staticMapPostcode = null;
                              _incidentsModel.updateTemporaryIncidentField('postcode', null, _usersModel.authenticatedUser.userId);
                              _incidentsModel.updateTemporaryIncidentField('postcode_map', null, _usersModel.authenticatedUser.userId);

                            });
                          })),
              controller: _postcodeController,
              validator: (String value) {
                print(value);

                if (_locationValue == 'Post Code' && value.isNotEmpty) {
                  bool validPostCode = RegExp(
                          r"^(GIR ?0AA|[A-PR-UWYZ]([0-9]{1,2}|([A-HK-Y][0-9]([0-9ABEHMNPRV-Y])?)|[0-9][A-HJKPS-UW]) ?[0-9][ABD-HJLNP-UW-Z]{2})$")
                      .hasMatch(value.toUpperCase());
                  if (!validPostCode) {
                    return 'Please enter a valid Post Code or leave blank';
                  }
                }
              },
              onSaved: (String value) {
                setState(() {
                  _formData['postcode'] = value;
                });
              },
            )),
            IconButton(
                icon: Icon(
                  Icons.map,
                  color: orangeDesign1,
                ),
                onPressed: () {
                  bool validPostCode = RegExp(
                          r"^(GIR ?0AA|[A-PR-UWYZ]([0-9]{1,2}|([A-HK-Y][0-9]([0-9ABEHMNPRV-Y])?)|[0-9][A-HJKPS-UW]) ?[0-9][ABD-HJLNP-UW-Z]{2})$")
                      .hasMatch(_postcodeController.text.toUpperCase());
                  if (!validPostCode) {
                    GlobalFunctions.showToast('Please enter a valid Post Code');
                  } else {
                    Connectivity()
                        .checkConnectivity()
                        .then((ConnectivityResult connectivityResult) {
                      if (connectivityResult == ConnectivityResult.none) {
                        GlobalFunctions.showToast(
                            'No data connection to fetch map');
                      } else {
                        GlobalFunctions.getStaticMap(context,
                                postcode: _postcodeController.text)
                            .then((Map<String, dynamic> result) {
                          if (!result['success']) {
                            GlobalFunctions.showToast(
                                'Unable to fetch map on device');
                          } else {
                            setState(() {
                              _staticMapPostcode = result['map'];
                              _incidentsModel.updateTemporaryIncidentField('postcode_map', _staticMapPostcode, _usersModel.authenticatedUser.userId);

                            });
                          }
                        });
                      }
                    });
                  }
                })
          ],
        ),
        _staticMapPostcode == null ? Container() : SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
                child: IgnorePointer(
              child: TextFormField(
                enabled: true,
                decoration: InputDecoration(labelText: 'Location'),
                controller: _locationController,
                validator: (String value) {
                  if (value.trim().length <= 0 && value.isEmpty) {
                    return 'please enter a location latitude & longitude';
                  }
                },
                onSaved: (String value) {
                  setState(() {
                    _formData['latitude'] = _latitude;
                    _formData['longitude'] = _longitude;
                  });
                },
              ),
            )),
            _locationController.text == ''
                ? Container()
                : IconButton(
                    color: Colors.grey,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _locationController.text = '';
                        _staticMapLocation = null;
                        _latitude = null;
                        _longitude = null;
                        _formData['latitude'] = null;
                        _formData['longitude'] = null;

                        _incidentsModel.updateTemporaryIncidentField('latitude', null, _usersModel.authenticatedUser.userId);
                        _incidentsModel.updateTemporaryIncidentField('longitude', null, _usersModel.authenticatedUser.userId);
                        _incidentsModel.updateTemporaryIncidentField('location_map', null, _usersModel.authenticatedUser.userId);

                      });
                    }),
            IconButton(
                icon: Icon(
                  Icons.location_on,
                  color: orangeDesign1,
                ),
                onPressed: () {
                  print('inside the right on pressed');

                  GlobalFunctions.getUserLocation().then((Map<String, dynamic> result) {
                    if (!result['success']) {
                      GlobalFunctions.showToast(
                          'Unable to fetch user Location, please use Post Code option');
                    } else {
                      _locationController.text = result['latitude'].toString() + ' ' +
                          result['longitude'].toString();

                      _latitude = result['latitude'];
                      _longitude = result['longitude'];

                      _incidentsModel.updateTemporaryIncidentField('latitude', _latitude, _usersModel.authenticatedUser.userId);
                      _incidentsModel.updateTemporaryIncidentField('longitude', _longitude, _usersModel.authenticatedUser.userId);


                      _formData['latitude'] = result['latitude'];
                      _formData['longitude'] = result['longitude'];

                      Connectivity()
                          .checkConnectivity()
                          .then((ConnectivityResult connectivityResult) {
                        if (connectivityResult == ConnectivityResult.none) {
                          GlobalFunctions.showToast(
                              'No data connection to fetch map');
                        } else {
                          GlobalFunctions.getStaticMap(context,
                                  lat: result['latitude'],
                                  lng: result['longitude'],
                                  geocode: false)
                              .then((Map<String, dynamic> result) {
                            if (!result['success']) {
                              GlobalFunctions.showToast(
                                  'Unable to fetch map on device');
                            } else {
                              setState(() {
                                _staticMapLocation = result['map'];
                                _incidentsModel.updateTemporaryIncidentField('location_map', _staticMapLocation, _usersModel.authenticatedUser.userId);

                              });
                            }
                          });
                        }
                      });
                    }
                  });
                })
          ],
        ),
        _staticMapLocation == null ? Container() : SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildStaticMap() {
    Widget result = Container();

    if (_staticMapPostcode != null && _locationValue == 'Post Code') {
      result = Image.network(_staticMapPostcode);
    } else if (_staticMapLocation != null &&
        _locationValue == 'Latitude/Longitude') {
      result = Image.network(_staticMapLocation);
    } else {
      result = Container();
    }
    return result;
  }

  Widget _buildSummaryText() {
    return TextFormField(
      focusNode: _summaryFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _summaryLabelColor),
          labelText: 'Summary',
          suffixIcon: _summaryTextController.text == ''
              ? null
              : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _summaryTextController.clear();
                    });
                  })),
      maxLines: 4,
      controller: _summaryTextController,
      //initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty || value.length < 10) {
          return 'Summary is required and should be 10+ characters long';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['summary'] = value;
        });
      },
    );
  }

  Widget _buildProjectNameText() {
    return TextFormField(
      focusNode: _projectNameFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _projectNameLabelColor),
          labelText: 'Project Name',
          suffixIcon: _projectNameController.text == ''
              ? null
              : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _projectNameController.clear();
                    });
                  })),
      controller: _projectNameController,
      onSaved: (String value) {
        setState(() {
          _formData['projectName'] = value;
        });
      },
    );
  }

  Widget _buildMileageText() {
    return TextFormField(
      focusNode: _mileageFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _mileageLabelColor),
          labelText: 'Mileage',
          suffixIcon: _mileageTextController.text == ''
              ? null
              : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _mileageTextController.clear();
                    });
                  })),
      controller: _mileageTextController,
      onSaved: (String value) {
        setState(() {
          _formData['mileage'] = value;
        });
      },
    );
  }

  Widget _buildCustomFields() {
    Widget fields;

    if (_customFieldCount == 1) {
      fields = Column(
        children: <Widget>[
          TextFormField(
            focusNode: _customField1FocusNode,
            decoration: InputDecoration(
                helperText:
                    _customPlaceholder1 == null ? '' : _customPlaceholder1,
                labelStyle: TextStyle(color: _customField1LabelColor),
                labelText: _customLabel1 == null ? '' : _customLabel1,
                suffixIcon: _customField1Controller.text == ''
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _customField1Controller.clear();
                          });
                        })),
            controller: _customField1Controller,
            onSaved: (String value) {
              setState(() {
                //need to do this
                _formData['customField1'] = value;
                _formData['customPlaceholder1'] = _customPlaceholder1;
                _formData['customLabel1'] = _customLabel1;
              });
            },
          )
        ],
      );
    } else if (_customFieldCount == 2) {
      fields = Column(
        children: <Widget>[
          TextFormField(
            focusNode: _customField1FocusNode,
            decoration: InputDecoration(
                helperText:
                    _customPlaceholder1 == null ? '' : _customPlaceholder1,
                labelStyle: TextStyle(color: _customField1LabelColor),
                labelText: _customLabel1 == null ? '' : _customLabel1,
                suffixIcon: _customField1Controller.text == ''
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _customField1Controller.clear();
                          });
                        })),
            controller: _customField1Controller,
            onSaved: (String value) {
              setState(() {
                //need to do this
                _formData['customField1'] = value;
                _formData['customPlaceholder1'] = _customPlaceholder1;
                _formData['customLabel1'] = _customLabel1;
              });
            },
          ),
          TextFormField(
            focusNode: _customField2FocusNode,
            decoration: InputDecoration(
                helperText:
                    _customPlaceholder2 == null ? '' : _customPlaceholder2,
                labelStyle: TextStyle(color: _customField2LabelColor),
                labelText: _customLabel2 == null ? '' : _customLabel2,
                suffixIcon: _customField2Controller.text == ''
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _customField2Controller.clear();
                          });
                        })),
            controller: _customField2Controller,
            onSaved: (String value) {
              setState(() {
                //need to do this
                _formData['customField2'] = value;
                _formData['customPlaceholder2'] = _customPlaceholder2;
                _formData['customLabel2'] = _customLabel2;
              });
            },
          )
        ],
      );
    } else if (_customFieldCount == 3) {
      fields = Column(
        children: <Widget>[
          TextFormField(
            focusNode: _customField1FocusNode,
            decoration: InputDecoration(
                helperText:
                    _customPlaceholder1 == null ? '' : _customPlaceholder1,
                labelStyle: TextStyle(color: _customField1LabelColor),
                labelText: _customLabel1 == null ? '' : _customLabel1,
                suffixIcon: _customField1Controller.text == ''
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _customField1Controller.clear();
                          });
                        })),
            controller: _customField1Controller,
            onSaved: (String value) {
              setState(() {
                //need to do this
                _formData['customField1'] = value;
                _formData['customPlaceholder1'] = _customPlaceholder1;
                _formData['customLabel1'] = _customLabel1;
              });
            },
          ),
          TextFormField(
            focusNode: _customField2FocusNode,
            decoration: InputDecoration(
                helperText:
                    _customPlaceholder2 == null ? '' : _customPlaceholder2,
                labelStyle: TextStyle(color: _customField2LabelColor),
                labelText: _customLabel2 == null ? '' : _customLabel2,
                suffixIcon: _customField2Controller.text == ''
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _customField2Controller.clear();
                          });
                        })),
            controller: _customField2Controller,
            onSaved: (String value) {
              setState(() {
                //need to do this
                _formData['customField2'] = value;
                _formData['customPlaceholder2'] = _customPlaceholder2;
                _formData['customLabel2'] = _customLabel2;
              });
            },
          ),
          TextFormField(
            focusNode: _customField3FocusNode,
            decoration: InputDecoration(
                helperText:
                    _customPlaceholder3 == null ? '' : _customPlaceholder3,
                labelStyle: TextStyle(color: _customField3LabelColor),
                labelText: _customLabel3 == null ? '' : _customLabel3,
                suffixIcon: _customField3Controller.text == ''
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _customField3Controller.clear();
                          });
                        })),
            controller: _customField3Controller,
            onSaved: (String value) {
              setState(() {
                //need to do this
                _formData['customField3'] = value;
                _formData['customPlaceholder3'] = _customPlaceholder3;
                _formData['customLabel3'] = _customLabel3;
              });
            },
          )
        ],
      );
    } else {
      fields = Container();
    }

    return fields;
  }

  Widget _buildSubmitButton(
      UsersModel usersModel, IncidentsModel incidentsModel) {
    return Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: RaisedButton(
              textColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              child: Text('Save'),
              onPressed: () => _disableScreen == true
                  ? null
                  : _submitForm(incidentsModel.addIncident,
                      incidentsModel.addIncidentLocally, usersModel),
            )));
  }

  Widget gridColor(BuildContext context, int index) {
    int minusIndex = index - 1;

    if (images[index] == null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (images[index] != null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (index > 0 &&
        images[minusIndex] != null &&
        images[index] == null) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (images[index] != null && index > 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.grey,
        ),
      );
    }
  }

  _pickPhoto(ImageSource source, int index) async {
    if (_pickInProgress) {
      return;
    }
    _pickInProgress = true;
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(source: source, maxWidth: 800.0);

    if (image != null) {
      bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

      if (isAndroid)
        image = await FlutterExifRotation.rotateImage(path: image.path);

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/images' + index.toString() + _usersModel.authenticatedUser.userId.toString();

      if (Directory(dirPath).existsSync()) {
        print('it exists');
        imageCache.clear();
        var dir = new Directory(dirPath);
        dir.deleteSync(recursive: true);
        if (Directory(dirPath).existsSync()) {
          print('still exists');
        } else {
          print('doesnt exist');
        }
      }

      new Directory(dirPath).createSync(recursive: true);
      String path =
          '$dirPath/temporaryIncidentImage' + index.toString() + '.jpg';

      File changedImage = image.copySync(path);

      path = changedImage.path;


      if (images[index] != null) {
        setState(() {
          //this is setting the image locally here
          images[index] = image;
          if(_temporaryPaths.length == 0){
            _temporaryPaths.add(path);
          } else if(_temporaryPaths.length < index +1){
            _temporaryPaths.add(path);
          } else {
            _temporaryPaths[index] = path;
          }

        });
      } else {
        setState(() {
          images[index] = changedImage;
          if (_temporaryPaths.length == 0) {
            _temporaryPaths.add(path);
          } else if (index == 0 && _temporaryPaths.length >= 1) {
            _temporaryPaths[index] = path;
          } else if (index == 1 && _temporaryPaths.length < 2) {
            _temporaryPaths.add(path);
          } else if (index == 1 && _temporaryPaths.length >= 2) {
            _temporaryPaths[index] = path;
          } else if (index == 2 && _temporaryPaths.length < 3) {
            _temporaryPaths.add(path);
          } else if (index == 2 && _temporaryPaths.length >= 3) {
            _temporaryPaths[index] = path;
          } else if (index == 3 && _temporaryPaths.length < 4) {
            _temporaryPaths.add(path);
          } else if (index == 3 && _temporaryPaths.length >= 4) {
            _temporaryPaths[index] = path;
          } else if (index == 4 && _temporaryPaths.length < 5) {
            _temporaryPaths.add(path);
          } else if (index == 4 && _temporaryPaths.length >= 5) {
            _temporaryPaths[index] = path;
          }
        });
      }
      _formData['images'] = images;

      var encodedPaths = jsonEncode(_temporaryPaths);

      _incidentsModel.updateTemporaryIncidentField(
          'images', encodedPaths, _usersModel.authenticatedUser.userId);
    }
    setState(() {
      _disableScreen = false;
    });
    _pickInProgress = false;
  }


  double _buildBottomSheetHeight(File image){
    double _deviceHeight = MediaQuery.of(context).size.height;

    double height;

    if(MediaQuery.of(context).orientation == Orientation.portrait){
      height = image == null? _deviceHeight * 0.15 : _deviceHeight * 0.22;

    } else {
      height = image == null? _deviceHeight * 0.30 : _deviceHeight * 0.44;
    }

    return height;

  }

  void _openImagePicker(BuildContext context, int index) {

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            height: _buildBottomSheetHeight(images[index]),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double sheetHeight = constraints.maxHeight;

                  return Container(
                    height: sheetHeight,
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: sheetHeight * 0.15,
                            child: Text(
                              'Pick an Image',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Container(
                            height: images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                setState(() {
                                  _disableScreen = true;

                                });
                                _pickPhoto(ImageSource.camera, index);
                              },
                              child: Text('Use Camera'),
                            )),
                        Container(
                            height: images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                setState(() {
                                  _disableScreen = true;
                                });
                                _pickPhoto(ImageSource.gallery, index);
                              },
                              child: Text('Use Gallery'),
                            )),
                        images[index] == null
                            ? Container()
                            : Container(
                            height: sheetHeight * 0.283,
                            child: FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                setState(() {
                                  print('this is the start');
                                  print(images);

                                  images[index] = null;
                                  _temporaryPaths[index] = null;
                                  print(images.length);

                                  int maxImageNo = images.length - 1;

                                  //if the last image in the list
                                  if (index == maxImageNo) {
                                    var encodedPaths =
                                    jsonEncode(_temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                        'images',
                                        encodedPaths,
                                        _usersModel
                                            .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  //if the image one in front is not null then replace this index with it
                                  int plusOne = index + 1;
                                  if (images[plusOne] != null) {
                                    images[index] = images[plusOne];
                                    images[plusOne] = null;
                                    _temporaryPaths[index] =
                                    _temporaryPaths[plusOne];
                                    _temporaryPaths[plusOne] = null;
                                  }

                                  //if the image two in front is not null then replace this index with it
                                  int plusTwo = index + 2;
                                  if (plusTwo > maxImageNo) {
                                    var encodedPaths =
                                    jsonEncode(_temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                        'images',
                                        encodedPaths,
                                        _usersModel
                                            .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  if (images[plusTwo] != null) {
                                    images[plusOne] = images[plusTwo];
                                    images[plusTwo] = null;
                                    _temporaryPaths[plusOne] =
                                    _temporaryPaths[plusTwo];
                                    _temporaryPaths[plusTwo] = null;
                                  }

                                  //if the image three in front is not null then replace this index with it
                                  int plusThree = index + 3;
                                  if (plusThree > maxImageNo) {
                                    var encodedPaths =
                                    jsonEncode(_temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                        'images',
                                        encodedPaths,
                                        _usersModel
                                            .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }
                                  if (images[plusThree] != null) {
                                    images[plusTwo] = images[plusThree];
                                    images[plusThree] = null;
                                    _temporaryPaths[plusTwo] =
                                    _temporaryPaths[plusThree];
                                    _temporaryPaths[plusThree] = null;
                                  }

                                  //if the image four in front is not null then replace this index with it
                                  int plusFour = index + 4;
                                  if (plusFour > maxImageNo) {
                                    var encodedPaths =
                                    jsonEncode(_temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                        'images',
                                        encodedPaths,
                                        _usersModel
                                            .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  if (images[plusFour] != null) {
                                    images[plusThree] = images[plusFour];
                                    images[plusFour] = null;
                                    _temporaryPaths[plusThree] =
                                    _temporaryPaths[plusFour];
                                    _temporaryPaths[plusFour] = null;
                                  }

                                  print('this is the end');
                                  print(images);
                                  var encodedPaths =
                                  jsonEncode(_temporaryPaths);
                                  _incidentsModel.updateTemporaryIncidentField(
                                      'images',
                                      encodedPaths,
                                      _usersModel.authenticatedUser.userId);
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Delete Image'),
                            )),
                      ],
                    ),
                  );
                }),
          );
        });
  }




  List<Widget> _buildGridTiles(BoxConstraints constraints, int numOfTiles) {
    List<Container> containers =
    List<Container>.generate(numOfTiles, (int index) {
      return Container(
        padding: EdgeInsets.all(2.0),
        width: constraints.maxWidth / 5,
        height: constraints.maxWidth / 5,
        child: GestureDetector(
          onTap: () {
            int minusIndex = index - 1;
            if (index == 0) {
              _openImagePicker(context, index);
            } else if (index > 0 && images[minusIndex] == null) {
              return;
            } else {
              _openImagePicker(context, index);
            }
          },
          child: gridColor(context, index),
        ),
      );
    });
    return containers;
  }

  Widget _buildPageContent(BuildContext context, IncidentsModel incidentsModel,
      UsersModel usersModel) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
              children: <Widget>[
                _buildIncidentDrop(),
                _buildReporterField(usersModel),
                _reportAnonymous(usersModel),
                _dateTimeField(),
                //_buildDateTimeField(),
                _buildLocationDrop(),
                _locationValue == 'Latitude/Longitude'
                    ? _buildLocationField()
                    : _buildPostcodeField(),
                _buildStaticMap(),
                _buildProjectNameText(),
                _buildRouteDrop(),
                _buildElrDrop(),
                _buildMileageText(),
                _customFieldCount > 0 ? _buildCustomFields() : Container(),
                _buildSummaryText(),
                SizedBox(
                  height: 10.0,
                ),
                LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildGridTiles(constraints, images.length),
                      );
                    }),
                SizedBox(
                  height: 10.0,
                ),
                _buildSubmitButton(usersModel, incidentsModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(Function addIncident, Function addIncidentLocally,
      UsersModel usersModel) {
    //if the form fails the validation then return and dont execute anymore code
    //or is the image is null and we are not in edit mode
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    print('button pressed');

    if (_locationValue == 'Post Code'){
      _formData['latitude'] = null;
      _formData['longitude'] = null;
    } else {
      _formData['postcode'] = null;
    }

    GlobalFunctions.showLoadingDialog(context, 'Saving');

    List<File> images = [];

    _temporaryPaths.forEach((dynamic path){

      File image = File(path);

      images.add(image);
    });


    List<Map<String, dynamic>> customFields = [];

    if(_customLabel1.isNotEmpty || _customLabel1 != ''){

      customFields.add({
        'label': _formData['customLabel1'],
        'placeholder': _formData['customPlaceholder1'],
        'value': _formData['customField1'],
      });

      if(_customLabel2.isNotEmpty || _customLabel2 != ''){

        customFields.add({
          'label': _formData['customLabel2'],
          'placeholder': _formData['customPlaceholder2'],
          'value': _formData['customField2'],
        });

        if(_customLabel3.isNotEmpty || _customLabel3 != ''){

          customFields.add({
            'label': _formData['customLabel3'],
            'placeholder': _formData['customPlaceholder3'],
            'value': _formData['customField3'],
          });
        }

      }
    }

    addIncidentLocally(
            _isAnonymous,
            usersModel.authenticatedUser,
            _formData['incidentType'],
            _formData['dateTime'],
            _formData['latitude'],
            _formData['longitude'],
            _formData['postcode'],
            _formData['projectName'],
            _formData['route'],
            _formData['elr'],
            _mileageTextController.text,
            _formData['summary'],
            images,
            customFields.length == 0 ? null : customFields
    )
        .then((Map<String, dynamic> response) {
      print(response);
      if (response['success']) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'Incident Saved Successfully',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 3,
            gravity: ToastGravity.CENTER,
            backgroundColor: orangeDesign1,
            textColor: Colors.black);
        print('waheyyyyyy');
        //Navigator.pushReplacementNamed(context, '/raiseIncident');

      } else {
        print('booooo');
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: response['message'],
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 3,
            gravity: ToastGravity.CENTER,
            backgroundColor: orangeDesign1,
            textColor: Colors.black);
      }
    });
  }

  void _resetIncident(){

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            title: Text('Notice', style: TextStyle(fontWeight: FontWeight.bold),),
            content: Text('Are you sure you wish to reset this form?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('No', style: TextStyle(color: orangeDesign1),),
              ),
              FlatButton(
                onPressed: () {
                  _incidentsModel.resetTemporaryIncident(_usersModel.authenticatedUser.userId);
                  setState(() {
                    _incidentValue = 'Incident';
                    _isAnonymous = false;
                    _dateTimeController1.text = '';
                    _locationValue = 'Latitude/Longitude';
                    _postcodeController.text = '';
                    _projectNameController.text = '';
                    _routeValue = 'Select a Route';
                    _elrValue = 'Select an ELR';
                    _mileageTextController.text = '';
                    _summaryTextController.text = '';
                    _latitude = null;
                    _longitude = null;
                    _staticMapLocation = null;
                    _staticMapPostcode = null;
                    _locationController.text = '';
                    _temporaryPaths = [];
                    images[0] = null;
                    images[1] = null;
                    images[2] = null;
                    images[3] = null;
                    images[4] = null;
                    _customField1Controller.text = '';
                    _customField2Controller.text = '';
                    _customField3Controller.text = '';
                    _customLabel1 = '';
                    _customLabel2 = '';
                    _customLabel3 = '';
                    _customPlaceholder1 = '';
                    _customPlaceholder2 = '';
                    _customPlaceholder3 = '';
                    _customFieldCount = 0;





                  });

                  Navigator.of(context).pop();
                },
                child: Text('Yes', style: TextStyle(color: orangeDesign1),),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print('[Raise Incident Page] - build page');
    final _usersModel =
        ScopedModel.of<UsersModel>(context, rebuildOnChange: true);
    final IncidentsModel _incidentsModel =
        ScopedModel.of<IncidentsModel>(context, rebuildOnChange: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeDesign1,
        title: Text('Raise Incident'),
        actions: <Widget>[IconButton(icon: Icon(Icons.refresh), onPressed: _resetIncident)],
      ),
      drawer: SideDrawer(),
      body: _buildPageContent(context, _incidentsModel, _usersModel),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      if (prefs.getBool('darkMode') == true) {
        GlobalFunctions.setDarkMode(context);
      }
    });
  }
}
