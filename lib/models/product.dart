import 'package:flutter/material.dart';
import 'location_data.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final String image;
  final String imagePath;
  final double price;
  final bool isFavourite;
  final String userEmail;
  final String userId;
  final LocationData location;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.image,
        @required this.imagePath,
      @required this.price,
      @required this.location,
      @required this.userEmail,
      @required this.userId,
      this.isFavourite = false});
}
