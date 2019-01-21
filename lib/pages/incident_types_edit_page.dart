import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/incident_type.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../scoped_models/incidents_model.dart';

class IncidentTypesEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _IncidentTypesEditPageState();
  }
}

class _IncidentTypesEditPageState extends State<IncidentTypesEditPage> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _custom1TextController = TextEditingController();
  final TextEditingController _custom2TextController = TextEditingController();
  final TextEditingController _custom3TextController = TextEditingController();
  final TextEditingController _emailFieldController = TextEditingController();

  //this is a map to manage the form data
  final Map<String, dynamic> _formData = {
    'name': null,
    'custom1': null,
    'custom2': null,
    'custom3': null
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildNameField(IncidentType incidentType) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (incidentType == null && _nameTextController.text.trim() == '') {
      _nameTextController.text = '';
    } else if (incidentType != null && _nameTextController.text.trim() == '') {
      _nameTextController.text = incidentType.name;
    } else if (incidentType != null && _nameTextController.text.trim() != '') {
      _nameTextController.text = _nameTextController.text;
    } else if (incidentType == null && _nameTextController.text.trim() != '') {
      _nameTextController.text = _nameTextController.text;
    } else {
      _nameTextController.text = '';
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      controller: _nameTextController,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty) {
          return 'Please Name for this Incident Type';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['name'] = value;
        });
      },
    );
  }

  Widget _buildCustom1Field(IncidentType incidentType) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (incidentType == null && _custom1TextController.text.trim() == '') {
      _custom1TextController.text = '';
    } else if (incidentType != null && _custom1TextController.text.trim() == '') {
      _custom1TextController.text = incidentType.custom1;
    } else if (incidentType != null && _custom1TextController.text.trim() != '') {
      _custom1TextController.text = _custom1TextController.text;
    } else if (incidentType == null && _custom1TextController.text.trim() != '') {
      _custom1TextController.text = _custom1TextController.text;
    } else {
      _custom1TextController.text = '';
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Custom Field 1'),
      controller: _custom1TextController,
      onSaved: (String value) {
        setState(() {
          _formData['custom1'] = value;
        });
      },
    );
  }

  Widget _buildCustom2Field(IncidentType incidentType) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (incidentType == null && _custom2TextController.text.trim() == '') {
      _custom2TextController.text = '';
    } else if (incidentType != null && _custom2TextController.text.trim() == '') {
      _custom2TextController.text = incidentType.custom2;
    } else if (incidentType != null && _custom2TextController.text.trim() != '') {
      _custom2TextController.text = _custom2TextController.text;
    } else if (incidentType == null && _custom2TextController.text.trim() != '') {
      _custom2TextController.text = _custom2TextController.text;
    } else {
      _custom2TextController.text = '';
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Custom Field 2'),
      enabled: _custom1TextController.text == '' ? false : true,
      controller: _custom2TextController,
      onSaved: (String value) {
        setState(() {
          _formData['custom2'] = value;
        });
      },
    );
  }

  Widget _buildCustom3Field(IncidentType incidentType) {
    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (incidentType == null && _custom3TextController.text.trim() == '') {
      _custom3TextController.text = '';
    } else if (incidentType != null && _custom3TextController.text.trim() == '') {
      _custom3TextController.text = incidentType.custom3;
    } else if (incidentType != null && _custom3TextController.text.trim() != '') {
      _custom3TextController.text = _custom3TextController.text;
    } else if (incidentType == null && _custom3TextController.text.trim() != '') {
      _custom3TextController.text = _custom3TextController.text;
    } else {
      _custom3TextController.text = '';
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Custom Field 3'),
      enabled: _custom1TextController.text == '' || _custom2TextController.text == ''  ? false : true,
      controller: _custom3TextController,
      onSaved: (String value) {
        setState(() {
          _formData['custom3'] = value;
        });
      },
    );
  }

//  Widget _buildEmailTextField(User user) {
//    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
//    if (user == null && _emailFieldController.text.trim() == '') {
//      _emailFieldController.text = '';
//    } else if (user != null && _emailFieldController.text.trim() == '') {
//      _emailFieldController.text = user.email;
//    } else if (user != null && _emailFieldController.text.trim() != '') {
//      _emailFieldController.text = _emailFieldController.text;
//    } else if (user == null && _emailFieldController.text.trim() != '') {
//      _emailFieldController.text = _emailFieldController.text;
//    } else {
//      _emailFieldController.text = '';
//    }
//    return TextFormField(
//      controller: _emailFieldController,
//      decoration: InputDecoration(
//        labelText: 'Email',
//      ),
//      keyboardType: TextInputType.emailAddress,
//      validator: (String value) {
//        if (value.isEmpty && value.trim().length <= 0 ||
//            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
//                .hasMatch(value)) {
//          return 'Please enter a valid email';
//        }
//      },
//      onSaved: (String value) {
//        _formData['email'] = value;
//      },
//    );
//  }

  Widget _buildSubmitButton(IncidentsModel _incidentsModel) {

      return _incidentsModel.isLoading
          ? Center(
              child: AdaptiveProgressIndicator(),
            )
          : Center(
              child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: RaisedButton(
                //color: Colors.deepOrange,
                textColor: Theme.of(context).brightness == Brightness.dark? Colors.black : Colors.white,
                child: _incidentsModel.selectedIncidentType == null ? Text('Save') : Text('Edit'),
                onPressed: () {
                 // _saveUser(user, model.addUser, model.editUser, model.selectUser, model.selectedUserIndex)
                  print('hi');

                },
              ),
            ));
  }

  void _saveIncidentType(IncidentsModel incidentsModel) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    if (incidentsModel.selectedIncidentType != null) {
      incidentsModel.editIncidentType(
        user,
        _formData['firstName'],
        _formData['surname'],
        _formData['email'],
        _formData['organisation'],
        _formData['role'],
      ).then((Map<String, dynamic> response) {
        print(response);
        if (response['success']) {
          Navigator.of(context).pushReplacementNamed('/incidentTypes');
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(response['message']),
                  content: Text('Press OK to continue'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () { Navigator.of(context).pop();
                      setSelectedUser(null);
                      },
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
    } else {
      addIncidentType(
        _formData['firstName'],
        _formData['surname'],
        _formData['email'],
        _formData['organisation'],
        _formData['role'],
      ).then((Map<String, dynamic> response) {
        print(response);
        if (response['success']) {
          setSelectedUser(null);
          Navigator.of(context).pushReplacementNamed('/incidentTypes');
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
  }

  Widget _buildPageContent(BuildContext context, IncidentsModel _incidentsModel) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    print('building page content');

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
              _buildNameField(_incidentsModel.selectedIncidentType),
              _buildCustom1Field(_incidentsModel.selectedIncidentType),
              _buildCustom2Field(_incidentsModel.selectedIncidentType),
              _buildCustom3Field(_incidentsModel.selectedIncidentType),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(_incidentsModel),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');

    final IncidentsModel _incidentsModel =
    ScopedModel.of<IncidentsModel>(context, rebuildOnChange: true);
    // TODO: implement build

        final Widget pageContent =
            _buildPageContent(context, _incidentsModel);
        return _incidentsModel.selectedIncidentType == null
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Incident Type'),
                ),
                body: pageContent,
              );
     ;
  }
}
