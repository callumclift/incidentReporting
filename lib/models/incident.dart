import 'package:flutter/material.dart';
import 'location_data.dart';

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
  final String projectName;
  final String route;
  final String elr;
  final String mileage;
  final String summary;
  final List<String> images;
  final int organisationId;
  final String organisationName;
  final List<String> customFields;
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

//  Map<String, dynamic> toMap(){
//
//    Map<String, dynamic> incidentMap = {
//      'id' : id,
//      'incidentType' : incidentType,
//      'reporterFirstName' : reporterFirstName,
//      'reporterLastName' : reporterLastName,
//      'dateTime' : dateTime,
//      'location' : location,
//      'projectName' : projectName,
//      'route' : route,
//      'elr' : elr,
//      'mileage' : mileage,
//      'summary' : summary,
//      'organisation' : organisation,
//      'reporterEmail' : reporterEmail,
//      'voided' : voided,
//    };
//
////    if(id != null){
////      incidentMap['id'] = id;
////    }
//
//    return incidentMap;
//  }
}
