import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../scoped_models/users_model.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';

class SettingsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {

  UsersModel _usersModel;

  @override
  void initState() {
    _usersModel = Provider.of<UsersModel>(context, listen: false);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =
    deviceWidth > 800.0 ? 750 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
      child: Column(
        children: <Widget>[
          ListTile(leading: Text('Resync ELRs', style: TextStyle(fontSize: 16.0),), trailing: IconButton(icon: Icon(Icons.refresh), color: orangeDesign1, onPressed: () async {

            GlobalFunctions.showLoadingDialog(context, 'Fetching ELR data');
            Map<String, dynamic> result = await _usersModel.getElrs();
            if(result['success']){
              Navigator.of(context).pop();
              GlobalFunctions.showToast('ELR data is now up to date');
            } else {
              Navigator.of(context).pop();
              GlobalFunctions.showToast(result['message']);
            }
          }),),
          ListTile(leading: Text('Logout', style: TextStyle(fontSize: 16.0),), trailing: IconButton(icon: Icon(Icons.logout), color: orangeDesign1, onPressed: () {
            _usersModel.logout();
          }),)
        ],
      ),
    );
  }
}
