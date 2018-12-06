import 'package:flutter/material.dart';

class AuthenticatedUser {
  final String id;
  final String email;
  final String token;
  final String authenticationId;
  final String firstName;
  final String surname;
  final String organisation;
  final String role;
  final bool hasTemporaryPassword;
  bool acceptedTerms;
  final bool suspended;

  AuthenticatedUser(
      {@required this.id,
      @required this.email,
      @required this.token,
      @required this.authenticationId,
      @required this.firstName,
      @required this.surname,
      @required this.organisation,
      @required this.role,
      @required this.hasTemporaryPassword,
      @required this.acceptedTerms,
      @required this.suspended});
}
