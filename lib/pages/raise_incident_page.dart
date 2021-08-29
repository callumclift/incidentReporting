import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/incident_type.dart';
import '../widgets/ui_elements/dropdown_formfield.dart';
import '../widgets/ui_elements/dropdown_formfield_expanded.dart';
import '../shared/global_functions.dart';
import '../shared/global_config.dart';
import '../scoped_models/incidents_model.dart';
import '../scoped_models/users_model.dart';
import 'package:location/location.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'home_page.dart';


class RaiseIncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RaiseIncidentPageState();
  }
}

class _RaiseIncidentPageState extends State<RaiseIncidentPage> {
  //GoogleMapController _mapController;
  bool _disableScreen = false;
  IncidentsModel _incidentsModel;
  UsersModel _usersModel;
  Map<String, dynamic> _temporaryIncident = new Map();
  List<dynamic> _temporaryPaths = [];
  IncidentType _currentIncidentType;
  Map<String, dynamic> _currentElr;
  bool _showElr = false;
  String _currentMileage = '';
  bool _loadingTemporary = false;
  bool _showImage = false;

  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> _currentElrList = [];

  String _incidentValue = 'Incident';

  List<IncidentType> _incidentTypes = [];

  List<String> _incidentDrop = [
    'Incident',
    'Close Call',
    'Near Miss',
    'Workplace Accident'
  ];

  List<String> _routeDrop = [
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
  List<String> _elrDrop = [
    'Select an ELR',
  ];

  final List<String> _locationDrop = ['Latitude/Longitude', 'Post Code'];

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
    'incidentType': null,
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
    _loadingTemporary = true;
    _incidentsModel = Provider.of<IncidentsModel>(context, listen: false);
    _usersModel = Provider.of<UsersModel>(context, listen: false);

   if (_incidentsModel.allIncidentTypes != null) {
     _incidentTypes = _incidentsModel.allIncidentTypes;
     for (IncidentType incidentType in _incidentTypes) {
       _incidentDrop.add(incidentType.name);

     }
   }
    _getRoutes();
    _getIncidentTypes();
    _setupTextListeners();
    _setupFocusNodes();

    super.initState();

  }

  _getRoutes() async {
    _routes = await _usersModel.getRoutes();
  }

  _getTemporaryIncident() async {

    if (mounted) {

      await _incidentsModel.setupTemporaryRecord();

      bool hasRecord = await _incidentsModel.checkRecordExists();

      if(hasRecord){
        Map<String, dynamic> incident = await _incidentsModel.getTemporaryRecord();

        if (incident['type'] != null) {
          //check to see if that incident type still exists as maybe it has been changed on the server
          bool exists = _incidentDrop.contains(incident['type']);

          if (exists) {
            setState(() {
              _incidentValue = incident['type'];
            });
          } else {
            _incidentValue = 'Incident';
          }
        }

        if (incident['anonymous'] != null && incident['anonymous'] == 1 ||
            incident['anonymous'] == true) {
          setState(() {
            _isAnonymous = true;
          });
        } else {
          _isAnonymous = false;
        }
        if (incident['incident_date'] != null) {
          _dateTimeController1.text = incident['incident_date'];
        }
        if (incident['location_drop'] != null) {
          _locationValue = incident['location_drop'];
        }
        if (incident['latitude'] != null && incident['longitude'] != null) {
          print('look');
          print(incident['latitude']);
          _locationController.text =
              incident['latitude'] + ' ' + incident['longitude'];
          _latitude = double.parse(incident['latitude']);
          _longitude = double.parse(incident['longitude']);
        }
        if (incident['postcode'] != null) {
          _postcodeController.text = incident['postcode'];
        }
        if (incident['location_map'] != null) {
          _staticMapLocation = incident['location_map'];
        }
        if (incident['postcode_map'] != null) {
          _staticMapPostcode = incident['postcode_map'];
        }
        if (incident['project_name'] != null) {
          _projectNameController.text = incident['project_name'];
        }
        if (incident['route'] != null) {
          _routeValue = incident['route'];
          _showElr = false;
          if (incident['route'] != 'Select a Route') {
            Map<String, dynamic> currentRoute = _routes.firstWhere(
                    (route) => route['route_name'] == incident['route']);

            List<Map<String, dynamic>> elrs = await _usersModel.getElrsFromRegion(currentRoute['route_code']);
              for (Map<String, dynamic> elr in elrs) {
                _elrDrop.add(elr['elr'] + ': ' + elr['description']);
              }
              setState(() {
                _showElr = true;
                _currentElrList = elrs;
                _incidentValue = _incidentValue;
              });

              //_elrDrop = _elrDrop;

              if (incident['elr'] != null) {
                _elrValue = incident['elr'];

                if (incident['elr'] == 'Select an ELR' ||
                    incident['elr'] == null ||
                    incident['elr'] == 'null') {
                  _currentElr = null;
                  _currentMileage = '';
                } else {
                  List<String> parts = incident['elr'].split(':');
                  _currentElr = _currentElrList
                      .firstWhere((elr) => elr['elr'] == parts[0]);
                  _currentMileage = _currentElr['start_miles'] +
                      ' miles to ' +
                      _currentElr['end_miles'] +
                      ' miles';
                }
              }
          }
        }
        if (incident['mileage'] != null) {
          _mileageTextController.text = incident['mileage'];
        }
        if (incident['summary'] != null) {
          _summaryTextController.text = incident['summary'];
        }
        if (incident['custom_fields'] != null) {
          List<dynamic> customFields = jsonDecode(incident['custom_fields']);

          if (_incidentValue != 'Incident') {
            _customFieldCount = customFields.length;

            if (_customFieldCount >= 1) {
              _customLabel1 = customFields[0]['label'];
              _customPlaceholder1 = customFields[0]['placeholder'];
              _customField1Controller.text =
              incident['custom_value1'] == null ||
                  incident['custom_value1'] == 'null'
                  ? ''
                  : incident['custom_value1'];
            }
            if (_customFieldCount >= 2) {
              _customLabel2 = customFields[1]['label'];
              _customPlaceholder2 = customFields[1]['placeholder'];
              _customField2Controller.text =
              incident['custom_value2'] == null ||
                  incident['custom_value2'] == 'null'
                  ? ''
                  : incident['custom_value2'];
            }
            if (_customFieldCount >= 3) {
              _customLabel3 = customFields[2]['label'];
              _customPlaceholder3 = customFields[2]['placeholder'];
              _customField3Controller.text =
              incident['custom_value3'] == null ||
                  incident['custom_value3'] == 'null'
                  ? ''
                  : incident['custom_value3'];
            }
          } else {
            _customFieldCount = 0;
            _incidentsModel.updateTemporaryRecord(
                'custom_fields', null);
            _incidentsModel.updateTemporaryRecord(
                'custom_value1', null);
            _incidentsModel.updateTemporaryRecord(
                'custom_value2', null);
            _incidentsModel.updateTemporaryRecord(
                'custom_value3', null);
          }
        }
        if (incident['images'] != null) {
          _temporaryPaths = jsonDecode(incident['images']);

          if (_temporaryPaths != null) {
            int index = 0;
            _temporaryPaths.forEach((dynamic path) {
              if (path != null) {
                print(path);
                setState(() {
                  images[index] = File(path);
                });
              }

              index++;
            });
          }
        }

        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }

      } else {
        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      }

    }
  }


  _getIncidentTypes() async {
    await _incidentsModel.getCustomIncidents();
      if (_incidentsModel.allIncidentTypes != null) {
        _incidentTypes = _incidentsModel.allIncidentTypes;
        for (IncidentType incidentType in _incidentTypes) {
          bool exists = _incidentDrop.contains(incidentType.name);
          if (!exists) _incidentDrop.add(incidentType.name);
        }

        setState(() {
          _incidentDrop = _incidentDrop;
        });
      }
      _getTemporaryIncident();
  }

  _setupTextListeners() {
    _projectNameController.addListener(() {
      _incidentsModel.updateTemporaryRecord('project_name',
          _projectNameController.text);
    });
    _postcodeController.addListener(() {
      _incidentsModel.updateTemporaryRecord('postcode',
          _postcodeController.text);
    });
    _summaryTextController.addListener(() {
      _incidentsModel.updateTemporaryRecord('summary',
          _summaryTextController.text);
    });
    _mileageTextController.addListener(() {
      _incidentsModel.updateTemporaryRecord('mileage',
          _mileageTextController.text);
    });
    _dateTimeController1.addListener(() {
      _incidentsModel.updateTemporaryRecord('incident_date',
          _dateTimeController1.text);
    });
    _customField1Controller.addListener(() {
      _incidentsModel.updateTemporaryRecord('custom_value1',
          _customField1Controller.text);
    });
    _customField2Controller.addListener(() {
      _incidentsModel.updateTemporaryRecord('custom_value2',
          _customField2Controller.text);
    });
    _customField3Controller.addListener(() {
      _incidentsModel.updateTemporaryRecord('custom_value3',
          _customField3Controller.text);
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
      expanded: true,
      hint: 'Incident Type',
      value: _incidentValue,
      items: _incidentDrop.toList(),
      onChanged: (val) => setState(() {
            _incidentValue = val;
            _formData['incidentType'] = _incidentValue;
            _customField1Controller.text = '';
            _customField2Controller.text = '';
            _customField3Controller.text = '';
            _incidentsModel.updateTemporaryRecord(
                'type', val);
            _incidentsModel.updateTemporaryRecord(
                'custom_value1', null);
            _incidentsModel.updateTemporaryRecord(
                'custom_value2', null);
            _incidentsModel.updateTemporaryRecord(
                'custom_value3', null);

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

                    _incidentsModel.updateTemporaryRecord(
                        'custom_fields',
                        jsonEncode(_temporaryCustomFields));
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
                    _incidentsModel.updateTemporaryRecord(
                        'custom_fields',
                        jsonEncode(_temporaryCustomFields));
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
                    _incidentsModel.updateTemporaryRecord(
                        'custom_fields',
                        jsonEncode(_temporaryCustomFields));
                  });
                }
              } else {
                setState(() {
                  _customFieldCount = 0;
                  _incidentsModel.updateTemporaryRecord('custom_fields',
                      null);
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
      expanded: true,
      hint: 'Route',
      value: _routeValue,
      items: _routeDrop.toList(),
      onChanged: (val) => setState(() {
            _showElr = false;
            _currentElrList = [];
            _routeValue = val;
            _formData['route'] = _routeValue;
            _incidentsModel.updateTemporaryRecord(
                'route', val);
            _incidentsModel.updateTemporaryRecord(
                'elr', null);
            _elrDrop = ['Select an ELR'];
            _elrValue = 'Select an ELR';
            _currentMileage = '';

            if (val != 'Select a Route') {
              Map<String, dynamic> currentRoute =
                  _routes.firstWhere((route) => route['route_name'] == val);

              _usersModel.getElrsFromRegion(currentRoute['route_code'])
                  .then((List<Map<String, dynamic>> elrs) {
                for (Map<String, dynamic> elr in elrs) {
                  _elrDrop.add(elr['elr'] + ': ' + elr['description']);
                }
                setState(() {
                  _showElr = true;
                  _currentElrList = elrs;
                });

                //_elrDrop = _elrDrop;
              });
            } else {
              _showElr = false;
              _elrDrop = ['Select an ELR'];
            }
          }),
      validator: (String message) {
        if (_routeValue == 'Select a Route') return 'Please select a Route';
      },
      initialValue: _routeDrop[0],
      onSaved: (val) => setState(() {
            _routeValue = val;
            _formData['route'] = _routeValue;
          }),
    );
  }

  Widget _buildElrDrop() {
    return DropdownFormFieldExpanded(
      expanded: true,
      hint: 'ELR',
      value: _elrValue,
      items: _elrDrop.toList(),
      onChanged: (val) => setState(() {
            _elrValue = val;
            _formData['elr'] = _elrValue;
            _incidentsModel.updateTemporaryRecord(
                'elr', val);
            if (val == 'Select an ELR') {
              _currentElr = null;
              _currentMileage = '';
              _incidentsModel.updateTemporaryRecord(
                  'elr', null);
            } else {
              List<String> parts = val.toString().split(':');
              _currentElr =
                  _currentElrList.firstWhere((elr) => elr['elr'] == parts[0]);
              _currentMileage = _currentElr['start_miles'] +
                  ' miles to ' +
                  _currentElr['end_miles'] +
                  ' miles';
            }
            _incidentsModel.updateTemporaryRecord('mileage_tip',
                _currentMileage);
          }),
      validator: (String message) {
        if (_elrValue == 'Select an ELR') return 'Please select an ELR';
      },
      initialValue: _elrDrop[0],
      onSaved: (val) => setState(() {
            _elrValue = val;
            _formData['elr'] = _elrValue;
          }),
    );
  }

  Widget _buildReporterField() {
    if (user == null) {
      _reporterTextController.text = '';
    } else if (_isAnonymous) {
      _reporterTextController.text = 'Anonymous';
    } else {
      _reporterTextController.text = user.firstName +
          ' ' +
          user.lastName;
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

  Widget _reportAnonymous() {
    return CheckboxListTile(
        activeColor: orangeDesign1,
        title: Text('Report Anonymously'),
        value: _isAnonymous,
        onChanged: (bool value) => setState(() {
              _isAnonymous = value;
              _incidentsModel.updateTemporaryRecord(
                  'anonymous', value);
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
                      return 'Please enter a Date & Time';
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
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: orangeDesign1,
                            ),
                          ),
                          child: child,
                        );
                      },
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1970),
                          lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      showTimePicker(
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light().copyWith(
                                  primary: orangeDesign1,
                                ),
                              ),
                              child: child,
                            );
                          },
                              context: context, initialTime: TimeOfDay.now())
                          .then((TimeOfDay time) {
                        if (time != null) {
                          DateTime today = new DateTime.now();
                          DateTime newDate = new DateTime(today.year, today.month, today.day);
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
      expanded: true,
      hint: 'Location Type',
      value: _locationValue,
      items: _locationDrop.toList(),
      onChanged: (val) => setState(() {
            _locationValue = val;
            _incidentsModel.updateTemporaryRecord(
                'location_drop', val);
          }),
      validator: (val) =>
          (val == null || val.isEmpty) ? 'Please choose a Location Type' : null,
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
                              _incidentsModel.updateTemporaryRecord(
                                  'postcode',
                                  null);
                              _incidentsModel.updateTemporaryRecord(
                                  'postcode_map',
                                  null);
                            });
                          })),
              controller: _postcodeController,
              validator: (String value) {

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
                onPressed: () async {
                  bool validPostCode = RegExp(
                          r"^(GIR ?0AA|[A-PR-UWYZ]([0-9]{1,2}|([A-HK-Y][0-9]([0-9ABEHMNPRV-Y])?)|[0-9][A-HJKPS-UW]) ?[0-9][ABD-HJLNP-UW-Z]{2})$")
                      .hasMatch(_postcodeController.text.toUpperCase());
                  if (!validPostCode) {
                    GlobalFunctions.showToast('Please enter a valid Post Code');
                  } else {


                    Location location = new Location();

                    bool _serviceEnabled;
                    PermissionStatus _permissionGranted;
                    LocationData _locationData;

                    _serviceEnabled = await location.serviceEnabled();
                    if (!_serviceEnabled) {
                      _serviceEnabled = await location.requestService();
                      if (!_serviceEnabled) {
                        return;
                      }
                    }

                    _permissionGranted = await location.hasPermission();
                    if (_permissionGranted == PermissionStatus.denied) {
                      _permissionGranted = await location.requestPermission();
                      if (_permissionGranted != PermissionStatus.granted) {
                        GlobalFunctions.showToast('Please accept location permission');
                        return;
                      }
                    }

                    if(_permissionGranted == PermissionStatus.granted && _serviceEnabled){

                      _locationData = await location.getLocation();

                      if(_locationData.latitude != null && _locationData.longitude != null){

                        _latitude = _locationData.latitude;
                        _longitude = _locationData.longitude;

                        _locationController.text = _latitude.toString() +
                            ' ' +
                            _longitude.toString();


                        _incidentsModel.updateTemporaryRecord('latitude',
                            _latitude.toString());
                        _incidentsModel.updateTemporaryRecord('longitude',
                            _longitude.toString());

                        _formData['latitude'] = _latitude;
                        _formData['longitude'] = _longitude;

                        ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

                        if (connectivityResult == ConnectivityResult.none) {
                          GlobalFunctions.showToast('No data connection to fetch map');
                        } else {
                          _staticMapLocation = await GlobalFunctions.getStaticMap(
                              postcode: _postcodeController.text,
                              geocode: true);
                          setState(() {
                            _staticMapPostcode = _staticMapLocation;
                            _incidentsModel.updateTemporaryRecord(
                                'postcode_map',
                                _staticMapPostcode);
                          });

                        }

                      }
                    }
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
//                validator: (String value) {
//                  if (value.trim().length <= 0 && value.isEmpty) {
//                    return 'please enter a location latitude & longitude';
//                  }
//                },
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

                        _incidentsModel.updateTemporaryRecord('latitude',
                            null);
                        _incidentsModel.updateTemporaryRecord(
                            'longitude',
                            null);
                        _incidentsModel.updateTemporaryRecord(
                            'location_map',
                            null);
                      });
                    }),
            IconButton(
                icon: Icon(
                  Icons.location_on,
                  color: orangeDesign1,
                ),
                onPressed: () async {

                  Location location = new Location();

                  bool _serviceEnabled;
                  PermissionStatus _permissionGranted;
                  LocationData _locationData;

                  _serviceEnabled = await location.serviceEnabled();
                  if (!_serviceEnabled) {
                    _serviceEnabled = await location.requestService();
                    if (!_serviceEnabled) {
                      return;
                    }
                  }

                  _permissionGranted = await location.hasPermission();
                  if (_permissionGranted == PermissionStatus.denied) {
                    _permissionGranted = await location.requestPermission();
                    if (_permissionGranted != PermissionStatus.granted) {
                      GlobalFunctions.showToast('Please accept location permission');
                      return;
                    }
                  }

                  if(_permissionGranted == PermissionStatus.granted && _serviceEnabled){

                    print('hi');

                    try {
                      _locationData = await location.getLocation();
                    } catch(e) {
                      print(e.toString());
                    }



                    if(_locationData.latitude != null && _locationData.longitude != null){

                      _latitude = _locationData.latitude;
                      _longitude = _locationData.longitude;

                      _locationController.text = _latitude.toString() +
                          ' ' +
                          _longitude.toString();


                      _incidentsModel.updateTemporaryRecord('latitude',
                          _latitude.toString());
                      _incidentsModel.updateTemporaryRecord('longitude',
                          _longitude.toString());

                      _formData['latitude'] = _latitude;
                      _formData['longitude'] = _longitude;

                      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

                        if (connectivityResult == ConnectivityResult.none) {
                          GlobalFunctions.showToast('No data connection to fetch map');
                        } else {
                          _staticMapLocation = await GlobalFunctions.getStaticMap(
                              lat: _latitude,
                              lng: _longitude,
                              geocode: false);
                          setState(() {
                            _staticMapLocation = _staticMapLocation;
                            _incidentsModel.updateTemporaryRecord(
                                'location_map',
                                _staticMapLocation);
                          });

                        }


                    }

                  }
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
        if (value.trim().length <= 0 || value.isEmpty) {
          return 'Summary is required';
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
          helperText: _currentMileage == '' ? '' : _currentMileage,
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
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => orangeDesign1),
              ),
              child: Text('Save'),
              onPressed: () => _disableScreen == true
                  ? null
                  : _submitForm(),
            )));
  }


  List<Widget> _buildGridTiles(BoxConstraints constraints, int numOfTiles) {
    List<Container> containers =
    List<Container>.generate(numOfTiles, (int index) {
      return Container(
        padding: EdgeInsets.all(2.0),
        width: constraints.maxWidth / 5,
        height: constraints.maxWidth / 5,
        child: GestureDetector(
          onLongPress: () {
            int minusIndex = index - 1;

            if (index == 0) {
              _showBottomSheet(index);
            } else if (index > 0 && images[minusIndex] == null) {
              return;
            } else {
              _showBottomSheet(index);
            }
          },
          onTap: () {
            int minusIndex = index - 1;


            if (images[index] != null) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    return ImagesDialog(images, index);
                  });
            } else if (index == 0) {
              _showBottomSheet(index);
            } else if (index > 0 && images[minusIndex] == null) {
              return;
            } else {
              _showBottomSheet(index);
            }
          },
          child: gridColor(context, index),
        ),
      );
    });
    return containers;
  }

  Future<Widget> _showBottomSheet(int index) async {
    FocusScope.of(context).requestFocus(new FocusNode());

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(bottom: 10.0),
            height: _buildBottomSheetHeight(images[index]),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double sheetHeight = constraints.maxHeight;

                  return Container(
                    height: sheetHeight,
                    child: Column(
                      children: <Widget>[
                        Container(width: constraints.maxWidth,
                            height: sheetHeight * 0.15,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [orangeGradient, purpleGradient])
                              //colors: [purpleDesign, purpleDesign])
                            ),
                            child: Center(child: Text(
                              'Pick an Image',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),)),
                        InkWell(onTap: () {
                          setState(() {
                            _disableScreen = true;
                          });
                          _pickPhoto(ImageSource.camera, index);
                        },child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: Center(child: Text('Use Camera', style: TextStyle(color: orangeDesign1),),)),),
                        InkWell(onTap: () {
                          setState(() {
                            _disableScreen = true;
                          });
                          _pickPhoto(ImageSource.gallery, index);
                        }, child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: Center(child: Text('Use Gallery', style: TextStyle(color: orangeDesign1),),)),),
                        images[index] == null
                            ? Container()
                            : InkWell(onTap: () {
                          setState(() {
                            images[index] = null;
                            _temporaryPaths[index] = null;

                            int maxImageNo = images.length - 1;

                            //if the last image in the list
                            if (index == maxImageNo) {
                              var encodedPaths =
                              jsonEncode(_temporaryPaths);
                              _incidentsModel.updateTemporaryRecord('images', encodedPaths);
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
                              _incidentsModel.updateTemporaryRecord('images', encodedPaths);
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
                              _incidentsModel.updateTemporaryRecord('images', encodedPaths);
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
                              _incidentsModel.updateTemporaryRecord('images', encodedPaths);


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

                            var encodedPaths =
                            jsonEncode(_temporaryPaths);
                            _incidentsModel.updateTemporaryRecord('images', encodedPaths);

                            Navigator.pop(context);
                          });
                        }, child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: sheetHeight * 0.283,
                            child: Center(child: Text('Delete Image', style: TextStyle(color: orangeDesign1),),)),),
                      ],
                    ),
                  );
                }),
          );
        });
  }


  _pickPhoto(ImageSource source, int index) async {
    if (_pickInProgress) {
      return;
    }
    _pickInProgress = true;
    Navigator.pop(context);


    if(source == ImageSource.camera){
      if(Platform.isAndroid){
        await _usersModel.updateCameraCrashTable({'has_crashed': true, 'image_index': index});
        final Directory tempPictures = await getExternalStorageDirectory();
        final String testPath = '${tempPictures.path}/Pictures';

        if (Directory(testPath).existsSync()) {


          List<FileSystemEntity> list = Directory(testPath).listSync(recursive: false)
              .toList();

          for (FileSystemEntity file in list) {
            file.deleteSync(recursive: false);
          }
        }
      }



    }

    final ImagePicker _picker = ImagePicker();


    XFile image = await _picker.pickImage(source: source, imageQuality: 50);

    if (image != null) {

      setState(() {

        images[index] = null;

      });
      await _usersModel.addImagePath(image);
      final Directory extDir = await getApplicationDocumentsDirectory();

      final String dirPath = '${extDir.path}/images/temporaryImages';
      final String filePath = '${extDir.path}/images/temporaryImages/image${index.toString()}.jpg';

      if (!Directory(dirPath).existsSync()) {
        new Directory(dirPath).createSync(recursive: true);
      }

      if(File(filePath).existsSync()){
        File oldImage = File(filePath);
        oldImage.deleteSync(recursive: true);
        imageCache.clear();
      }

      String path = '$dirPath/image${index.toString()}.jpg';

      File changedImage = await FlutterImageCompress.compressAndGetFile(File(image.path).absolute.path, path, quality: 50, keepExif: false);

      path = changedImage.path;


      if (images[index] != null) {

        setState(() {
          //this is setting the image locally here
          images[index] = changedImage;
          if (_temporaryPaths.length == 0) {
            _temporaryPaths.add(path);
          } else if (_temporaryPaths.length < index + 1) {
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

      var encodedPaths = jsonEncode(_temporaryPaths);
      _incidentsModel.updateTemporaryRecord('images', encodedPaths);

    } else {
      if(Platform.isAndroid){
        await _usersModel.updateCameraCrashTable({'has_crashed': false, 'image_index': 0});
      }
    }
    // }
    setState(() {
      _disableScreen = false;
      _pickInProgress = false;
    });
  }


  Widget gridColor(BuildContext context, int index) {
    int minusIndex = index - 1;

    if (images[index] == null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black),
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
            border: Border.all(width: 1.0, color: Colors.black),
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


  double _buildBottomSheetHeight(File image) {
    double _deviceHeight = MediaQuery.of(context).size.height;

    double height;

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      height = image == null ? _deviceHeight * 0.3 : _deviceHeight * 0.37;
    } else {
      height = image == null ? _deviceHeight * 0.4 : _deviceHeight * 0.56;
    }

    return height;
  }


  Widget _buildPageContent(BuildContext context, IncidentsModel incidentsModel,
      UsersModel usersModel) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 800.0 ? 500.0 : deviceWidth * 0.95;
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
                _buildReporterField(),
                _reportAnonymous(),
                _dateTimeField(),
                _buildLocationDrop(),
                _locationValue == 'Latitude/Longitude'
                    ? _buildLocationField()
                    : _buildPostcodeField(),
                _buildStaticMap(),
                _buildProjectNameText(),
                _buildRouteDrop(),
                _showElr == true ? _buildElrDrop() : Container(),
                _buildMileageText(),
                _customFieldCount > 0 ? _buildCustomFields() : Container(),
                _buildSummaryText(),
                SizedBox(height: 10,),
                Text('Supporting Images', style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
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

  void _submitForm() async {
    //if the form fails the validation then return and dont execute anymore code
    //or is the image is null and we are not in edit mode
    if (!_formKey.currentState.validate()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              title: Text(
                'Notice',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                  'Please ensure all required fields are completed (highlighted in red)'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(color: orangeDesign1),
                  ),
                ),
              ],
            );
          });

      return;
    }
    _formKey.currentState.save();

    if (_locationValue == 'Post Code') {
      _formData['latitude'] = null;
      _formData['longitude'] = null;
    } else {
      _formData['postcode'] = null;
    }

    GlobalFunctions.showLoadingDialog(context, 'Saving');

    List<File> images = [];

    _temporaryPaths.forEach((dynamic path) {
      if (path != null) {
        File image = File(path);

        images.add(image);
      }
    });

    List<Map<String, dynamic>> customFields = [];

    if (_customLabel1.isNotEmpty || _customLabel1 != '') {
      customFields.add({
        'label': _customLabel1,
        'placeholder': _customPlaceholder1,
        'value': _customField1Controller.text,
      });

      if (_customLabel2.isNotEmpty || _customLabel2 != '') {
        customFields.add({
          'label': _customLabel2,
          'placeholder': _customPlaceholder2,
          'value': _customField2Controller.text,
        });

        if (_customLabel3.isNotEmpty || _customLabel3 != '') {
          customFields.add({
            'label': _customLabel3,
            'placeholder': _customPlaceholder3,
            'value': _customField3Controller.text,
          });
        }
      }
    }

    bool success = await _incidentsModel.saveIncident(
            anonymous: _isAnonymous,
            authenticatedUser: user,
            type: _incidentValue,
            incidentDate: _dateTimeController1.text,
            latitude: _locationValue == 'Post Code' ? null : _latitude,
            longitude: _locationValue == 'Post Code' ? null : _longitude,
            postcode:
                _locationValue == 'Post Code' ? _postcodeController.text : null,
            projectName: _projectNameController.text,
            route: _routeValue,
            elr: _elrValue,
            mileage: _mileageTextController.text,
            summary: _summaryTextController.text,
            images: images,
            customFields: customFields.length == 0 ? null : customFields,
            context: context);


      Navigator.pop(context);

      if(success){
        FocusScope.of(context).requestFocus(new FocusNode());
        await context.read<IncidentsModel>().resetTemporaryRecord(user.userId);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => HomePage(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }

  }

  @override
  Widget build(BuildContext context) {
    return _loadingTemporary
        ? Center(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(orangeDesign1),
      ),
    )
        : _buildPageContent(context, _incidentsModel, _usersModel);
  }

}

class ImagesDialog extends StatefulWidget {
  final List<File> images;
  final int currentIndex;

  ImagesDialog(this.images, this.currentIndex);
  @override
  _ImagesDialogState createState() => new _ImagesDialogState();
}

class _ImagesDialogState extends State<ImagesDialog> {

  File currentImage;
  int imagesLength;
  int imageIndex;

  @override
  void initState() {
    imageIndex = widget.currentIndex;
    currentImage = widget.images[imageIndex];
    imagesLength = _getImagesLength();
    // TODO: implement initState
    super.initState();
  }

  int _getImagesLength(){

    int count = 0;

    for(File image in widget.images){
      if(image == null) continue;
      count ++;
    }

    return count;

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(contentPadding: EdgeInsets.all(0),content: Stack(children: <Widget>[
      PinchZoomImage(
        image: Image.file(currentImage),
        zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
        hideStatusBarWhileZooming: true,
        onZoomStart: () {
          print('Zoom started');
        },
        onZoomEnd: () {
          print('Zoom finished');
        },
      ),
      imageIndex == 0 ? Positioned.fill(child: Align(alignment: Alignment.centerLeft ,child: Container(),)) :
      Positioned.fill(child: Align(alignment: Alignment.centerLeft ,child: Container(child: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: (){
          imageIndex --;
          setState(() {
            currentImage = widget.images[imageIndex];
          });
        }, color: orangeDesign1,),margin: EdgeInsets.only(left: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),),
      imageIndex == (imagesLength -1) ? Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(),)) :
      Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(child: IconButton(icon: Icon(Icons.arrow_forward),
        onPressed: (){
          imageIndex ++;
          setState(() {
            currentImage = widget.images[imageIndex];
          });
        }, color: orangeDesign1,),margin: EdgeInsets.only(right: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),)

    ],));
  }
}
