import 'package:flutter/material.dart';
import '../shared/global_config.dart';

class AppBarGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [orangeGradient, purpleGradient])
        //colors: [purpleDesign, purpleDesign])
      ),
    );
  }
}