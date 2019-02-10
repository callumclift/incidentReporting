import 'package:flutter/material.dart';

class AuthenticatedUser {
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final bool suspended;
  final int organisationId;
  final String organisationName;
  final String session;
  final bool deleted;
  final bool isClientAdmin;
  final bool isSuperAdmin;
  final String termsAccepted;
  final bool forcePasswordReset;
  bool darkMode;

  AuthenticatedUser(
      {@required this.userId,
      @required this.firstName,
      @required this.lastName,
      @required this.username,
      @required this.password,
      @required this.suspended,
      @required this.organisationId,
      @required this.organisationName,
      @required this.session,
      @required this.deleted,
      @required this.isClientAdmin,
      @required this.isSuperAdmin,
      @required this.termsAccepted,
      @required this.forcePasswordReset,
      this.darkMode});
}
