import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import '../models/location_data.dart';
import '../widgets/form_inputs/locate_user.dart';
import '../widgets/helpers/app_side_drawer.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/ui_elements/dropdown_formfield.dart';
import '../widgets/helpers/add_images.dart';

import '../scoped_models/main.dart';

class RaiseIncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RaiseIncidentPageState();
  }
}

class _RaiseIncidentPageState extends State<RaiseIncidentPage> {


  final List<String> _incidentDrop = ['Incident', 'Close Call', 'Near Miss', 'Workplace Accident'];
  final List<String> _routeDrop = ['Select a Route', 'Anglia', 'Southeast', 'London North East', 'London North West (North)',
  'London North West (South)', 'East Midlands', 'Scotland', 'Wales', 'Wessex', 'Western (West)', 'Western (Thames Valley)'];
  final List<String> _elrDrop = ['Select an ELR', 'Anglia', 'Southeast', 'London North East',];


  String _incidentValue = 'Incident';
  String _routeValue = 'Select a Route';
  String _elrValue = 'Select an ELR';

  final dateFormat = DateFormat("d/M/yyyy 'at' h:mma");
  DateTime date;


  final TextEditingController _reporterTextController = TextEditingController();
  final TextEditingController _summaryTextController = TextEditingController();
  final TextEditingController _mileageTextController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //this is a map to manage the form data
  final Map<String, dynamic> _formData = {
    'incidentType': 'Incident',
    'reporter': null,
    'dateTime': null,
    'location': null,
    'projectName': null,
    'route': null,
    'elr': null,
    'mileage': null,
    'summary': null,
    'images': null,
  };


  void _setLocation(LocationData locationData) {
    _formData['location'] = locationData;
  }

  void _setImages(List<File> images) {
    _formData['images'] = images;
  }

  Widget _buildIncidentDrop() {
    return DropdownFormField(
      hint: 'Incident Type',
      value: _incidentValue,
      items: _incidentDrop.toList(),
      onChanged: (val) => setState(() {
        _incidentValue = val;
        _formData['incidentType'] = _incidentValue;
      }),
      validator: (val) =>
      (val == null || val.isEmpty) ? 'Please choose an Incident Type' : null,
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
      }),
      validator: (val) =>
      (val == null || val.isEmpty || val == 'Select a Route') ? 'Please select a Route' : null,
      initialValue: _routeDrop[0],
      onSaved: (val) => setState(() {
        _routeValue = val;
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
      }),
      validator: (val) =>
      (val == null || val.isEmpty || val == 'Select an ELR') ? 'Please select an ELR' : null,
      initialValue: _elrDrop[0],
      onSaved: (val) => setState(() {
        _elrValue = val;
        _formData['elr'] = _elrValue;
      }),
    );
  }

  Widget _buildReporterField(MainModel model) {

    _reporterTextController.text = model.authenticatedUser.firstName + ' ' + model.authenticatedUser.surname;

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

  Widget _buildDateTimeField() {

    return DateTimePickerFormField(
      format: dateFormat,
      decoration: InputDecoration(prefixIcon: Icon(Icons.access_time),labelText: 'Date & Time'),
      onChanged: (dt) => setState(() {
        date = dt;
        String dateString = dateFormat.format(dt);
        print('this is the date string');
        print(dateString);
      }),
      controller: _dateTimeController,
      onSaved: (dt) => setState(() {
        date = dt;
        String dateString = dateFormat.format(dt);
        print('this is the date string');
        print(dateString);
        _formData['dateTime'] = dateString;
      }),
      validator: (DateTime dateTime){
        if(date == null){
          return 'please enter a Date & Time';
        }
      },
    );
  }

  Widget _buildSummaryText() {

    return TextFormField(
      decoration: InputDecoration(labelText: 'Summary', suffixIcon: _summaryTextController.text == ''? null: IconButton(icon: Icon(Icons.clear), onPressed: () {
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
      decoration: InputDecoration(labelText: 'Project Name', suffixIcon: _projectNameController.text == ''? null: IconButton(icon: Icon(Icons.clear), onPressed: () {
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
      decoration: InputDecoration(labelText: 'Mileage'),
      keyboardType: TextInputType.number,
      controller: _mileageTextController,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
          return 'Mileage is required and should be a number';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['mileage'] =
              double.parse(value.replaceFirst(RegExp(r','), '.'));
        });
      },
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(
              child: AdaptiveProgressIndicator(),
            )
          : Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.5,
          child: RaisedButton(
              textColor: Colors.white,
              child: Text('Save'),
              onPressed: () => _submitForm(model.addIncident),
            )));
    });
  }

  Widget _buildPageContent(BuildContext context, MainModel model) {
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
            child: Column(children: <Widget>[
              _buildIncidentDrop(),
              _buildReporterField(model),
              _buildDateTimeField(),
              LocateUser(_setLocation),
              _buildProjectNameText(),
              _buildRouteDrop(),
              _buildElrDrop(),
              _buildMileageText(),
              _buildSummaryText(),
              SizedBox(
                height: 10.0,
              ),
              AddImages(_setImages),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],)

            ,
          ),
        ),
      ),
    );
  }

  void _submitForm(Function addIncident) {
    //if the form fails the validation then return and dont execute anymore code
    //or is the image is null and we are not in edit mode
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    addIncident(
      _formData['incidentType'],
      _formData['reporter'],
      _formData['dateTime'],
      _formData['location'],
      _formData['projectName'],
      _formData['route'],
      _formData['elr'],
      double.parse(_mileageTextController.text.replaceFirst(RegExp(r','), '.')),
      _formData['summary'],
      _formData['images'],
    ).then((Map<String, dynamic> response) {
      print(response);
      if (response['success']) {
        Navigator.of(context).pushReplacementNamed('/');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(response['message']),
                content: Text('Press OK to continue'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(response['message']),
                content: Text('Please try again'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
            return Scaffold(
                appBar: AppBar(
                  title: Text('Raise Incident'),

                ),
                drawer: SideDrawer(),
                body: _buildPageContent(context, model),
              );
      },
    );
  }
}
