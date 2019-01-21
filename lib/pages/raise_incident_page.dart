import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_data.dart';
import '../widgets/form_inputs/locate_user.dart';
import '../widgets/helpers/app_side_drawer.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
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

class _RaiseIncidentPageState extends State<RaiseIncidentPage> with AfterLayoutMixin<RaiseIncidentPage> {
  bool disableScreen = false;

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

  String _incidentValue = 'Incident';
  String _routeValue = 'Select a Route';
  String _elrValue = 'Select an ELR';
  bool _isAnonymous = false;

  final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
  DateTime date;

  TextEditingController _reporterTextController = TextEditingController();
  final TextEditingController _summaryTextController = TextEditingController();
  final TextEditingController _mileageTextController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _dateTimeController1 = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _projectNameFocusNode = new FocusNode();
  final FocusNode _mileageFocusNode = new FocusNode();
  final FocusNode _summaryFocusNode = new FocusNode();
  Color _projectNameLabelColor = Colors.grey;
  Color _mileageLabelColor = Colors.grey;
  Color _summaryLabelColor = Colors.grey;

  //this is a map to manage the form data
  final Map<String, dynamic> _formData = {
    'incidentType': 'Incident',
    'reporterFirstName': null,
    'reporterLastName': null,
    'dateTime': null,
    'location': null,
    'projectName': null,
    'route': null,
    'elr': null,
    'mileage': null,
    'summary': null,
    'images': null,
  };

  @override
  void initState() {
    super.initState();
    setupFocusNodes();
  }

  setupFocusNodes(){

    _projectNameFocusNode.addListener((){
      if(_projectNameFocusNode.hasFocus){
        setState(() {
          _projectNameLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _projectNameLabelColor = Colors.grey;

        });
      }
    });

    _mileageFocusNode.addListener((){
      if(_mileageFocusNode.hasFocus){
        setState(() {
          _mileageLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _mileageLabelColor = Colors.grey;

        });
      }
    });
    _summaryFocusNode.addListener((){
      if(_summaryFocusNode.hasFocus){
        setState(() {
          _summaryLabelColor = orangeDesign1;
        });
      } else {
        setState(() {
          _summaryLabelColor = Colors.grey;

        });
      }
    });

  }



  void _setLocation(LocationData locationData) {
    _formData['location'] = locationData;
  }

  void _setImages(List<File> images) {
    _formData['images'] = images;
  }

  void _disableScreen(bool disabled) {
   disableScreen = disabled;
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
          }),
      validator: (val) =>
          (val == null || val.isEmpty || val == 'Select a Route')
              ? 'Please select a Route'
              : null,
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
      validator: (val) => (val == null || val.isEmpty || val == 'Select an ELR')
          ? 'Please select an ELR'
          : null,
      initialValue: _elrDrop[0],
      onSaved: (val) => setState(() {
            _elrValue = val;
            _formData['elr'] = _elrValue;
          }),
    );
  }

  Widget _buildReporterField(UsersModel model) {

    if(model.authenticatedUser == null){
      _reporterTextController.text = '';
    } else if(_isAnonymous){
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
    return CheckboxListTile(activeColor: orangeDesign1,
        title: Text('Report Anonymously'),
        value: _isAnonymous,
        onChanged: (bool value) => setState(() {
          _isAnonymous = value;
            }));
  }

  Widget _dateTimeField(){
    return Column(
      children: <Widget>[
        Row(children: <Widget>[
          Flexible(child: IgnorePointer(child: TextFormField(enabled: true,
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


          ),),),

          IconButton(icon: Icon(Icons.access_time, color: Color.fromARGB(255, 255, 147, 94)), onPressed: (){
            showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1970), lastDate: DateTime(2100)).then((DateTime newDate){
              if(newDate != null){
                showTimePicker(context: context, initialTime: TimeOfDay.now()).then((TimeOfDay time){
                  if(time != null){
                    newDate = startOfDay(newDate);
                    newDate = newDate.add(Duration(hours: time.hour, minutes: time.minute));
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
        ],),

      ],
    );

  }

  Widget _buildDateTimeField() {
    return DateTimePickerFormField(
      format: dateFormat,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.access_time), labelText: 'Date & Time'),
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
      validator: (DateTime dateTime) {
        if (date == null) {
          return 'please enter a Date & Time';
        }
      },
    );
  }

  Widget _buildSummaryText() {
    return TextFormField(focusNode: _summaryFocusNode,
      decoration: InputDecoration(labelStyle: TextStyle(color: _summaryLabelColor),
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
    return TextFormField(focusNode: _projectNameFocusNode,
      decoration: InputDecoration(labelStyle: TextStyle(color: _projectNameLabelColor),
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
    return TextFormField(focusNode: _mileageFocusNode,
      decoration: InputDecoration(labelStyle: TextStyle(color: _mileageLabelColor), labelText: 'Mileage'),
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

  Widget _buildSubmitButton(
      UsersModel usersModel, IncidentsModel incidentsModel) {
    return incidentsModel.isLoading
        ? Center(
            child: AdaptiveProgressIndicator(),
          )
        : Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RaisedButton(
                  textColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                  child: Text('Save'),
                  onPressed: () => disableScreen == true ? null : _submitForm(incidentsModel.addIncident,
                      incidentsModel.addIncidentLocally, usersModel),
                )));
    ;
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
                LocateUser(_setLocation),
                _buildProjectNameText(),
                _buildRouteDrop(),
                _buildElrDrop(),
                _buildMileageText(),
                _buildSummaryText(),
                SizedBox(
                  height: 10.0,
                ),
                AddImages(_setImages, _disableScreen),
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

    addIncidentLocally(
            _isAnonymous,
            usersModel.authenticatedUser,
            _formData['incidentType'],
            _formData['dateTime'],
            _formData['location'],
            _formData['projectName'],
            _formData['route'],
            _formData['elr'],
            _mileageTextController.text,
            _formData['summary'],
            _formData['images'])
        .then((Map<String, dynamic> response) {
      print(response);
      if (response['success']) {
        print('waheyyyyyy');
      } else {
        print('booooo');
      }
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
      appBar: AppBar(backgroundColor: orangeDesign1,
        title: Text('Raise Incident'),
      ),
      drawer: SideDrawer(),
      body: _buildPageContent(context, _incidentsModel, _usersModel),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.

    SharedPreferences.getInstance().then((SharedPreferences prefs){
      if(prefs.getBool('darkMode') == true){
        GlobalFunctions.setDarkMode(context);
    }});



  }
}
