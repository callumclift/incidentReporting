import 'package:flutter/material.dart';

class IncidentType {
  final int id;
  final String name;
  final String custom1;
  final String custom2;
  final String custom3;
  final String organisation;

  IncidentType(
      {@required this.name, @required this.id, @required this.custom1, @required this.custom2, @required this.custom3, @required this.organisation});
}
