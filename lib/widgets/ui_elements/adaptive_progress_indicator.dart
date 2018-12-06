import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class AdaptiveProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Theme.of(context).platform == TargetPlatform.iOS ? CupertinoActivityIndicator(): CircularProgressIndicator();
  }
}