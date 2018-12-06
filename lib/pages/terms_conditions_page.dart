import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/main.dart';

class TermsConditionsPage extends StatelessWidget {

  _acceptTerms(MainModel model, BuildContext context) async{

    await model.acceptTerms().then((bool value) {
      if(value) {
        print('its got to where it needs to be');
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('An error occured'),
                content: Text('Something went wrong'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('ok'),
                  ),
                ],
              );
            });

    }});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          return Scaffold(
        appBar: AppBar(title: Text('Terms & Conditions'),),
        body: Container(margin: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Text('this is a placeholder for the terms and conditions'),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(onPressed: () => _acceptTerms(model, context), child: Text('Accept'),),
                  SizedBox(width: 10.0,),
                  RaisedButton(onPressed: null, child: Text('Reject'),)
                ],
              )
            ],
          ),
        ),
      );});
    }
  }

