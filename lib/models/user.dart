import 'package:flutter/material.dart';

class User {
  final String id;
  final String authenticationId;
  final String email;
  final String firstName;
  final String surname;
  final String organisation;
  final String role;
  final bool hasTemporaryPassword;
  final bool acceptedTerms;
  final bool suspended;

  User(
      {@required this.id,
        @required this.authenticationId,
      @required this.email,
      @required this.firstName,
      @required this.surname,
      @required this.organisation,
      @required this.role,
      @required this.hasTemporaryPassword,
      @required this.acceptedTerms,
      @required this.suspended});
}
