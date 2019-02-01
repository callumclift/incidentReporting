import 'package:flutter/material.dart';

class IncidentType {
  final int id;
  final int localId;
  final int userId;
  final String username;
  final int organisationId;
  final String organisationName;
  final String name;
  final String customLabel1;
  final String customLabel2;
  final String customLabel3;
  final String customPlaceholder1;
  final String customPlaceholder2;
  final String customPlaceholder3;

  IncidentType(
      {@required this.name, @required this.id, this.localId, @required this.organisationId, @required this.organisationName, @required this.userId, @required this.username, this.customLabel1, this.customLabel2, this.customLabel3,
      this.customPlaceholder1, this.customPlaceholder2, this.customPlaceholder3});
}
