import 'dart:typed_data';
import 'package:flutter/material.dart';

class Incident {
  int id;
  int incidentId;
  final int userId;
  final String type;
  final String fullName;
  final String username;
  final String email;
  final String incidentDate;
  final String created;
  final double latitude;
  final double longitude;
  final String postcode;
  final String projectName;
  final String route;
  final String elr;
  final String mileage;
  final String summary;
  List<Uint8List> images;
  final int organisationId;
  final String organisationName;
  final List<Map<String, dynamic>> customFields;
  final bool anonymous;

  Incident({
    @required this.id,
    this.incidentId,
    @required this.userId,
    @required this.type,
    this.fullName,
    this.username,
    this.email,
    @required this.incidentDate,
    this.created,
    this.latitude,
    this.longitude,
    this.postcode,
    this.projectName,
    this.route,
    this.elr,
    this.mileage,
    @required this.summary,
    this.images,
    @required this.organisationId,
    @required this.organisationName,
    this.customFields,
    this.anonymous,
  });
}
