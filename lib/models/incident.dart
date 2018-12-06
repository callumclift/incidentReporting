import 'package:flutter/material.dart';
import 'location_data.dart';

class Incident {
  final String id;
  final String incidentType;
  final String reporter;
  final String dateTime;
  final LocationData location;
  final String projectName;
  final String route;
  final String elr;
  final double mileage;
  final String summary;
  final List<String> imagePaths;
  final List<String> images;
  final String organisation;
  final String reporterEmail;
  final bool voided;

  Incident(
      {@required this.id,
      @required this.incidentType,
      @required this.reporter,
      @required this.dateTime,
      @required this.location,
      @required this.projectName,
      @required this.route,
      @required this.elr,
      @required this.mileage,
      @required this.summary,
      @required this.imagePaths,
      @required this.images,
      @required this.organisation,
      @required this.reporterEmail,
      @required this.voided});
}
