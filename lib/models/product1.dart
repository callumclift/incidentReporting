import 'package:flutter/material.dart';
import 'location_data.dart';

class Product1 {
  final String id;
  final String title;
  final String description;
  final List <String> images;
  final List<String> imagePaths;
  final double price;
  final bool isFavourite;
  final String userEmail;
  final String userId;
  final LocationData location;

  Product1(
      {@required this.id,
        @required this.title,
        @required this.description,
        @required this.images,
        @required this.imagePaths,
        @required this.price,
        @required this.location,
        @required this.userEmail,
        @required this.userId,
        this.isFavourite = false});
}
