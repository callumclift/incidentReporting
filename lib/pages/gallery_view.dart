import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';
import '../widgets/helpers/app_side_drawer.dart';


class GalleryView extends StatefulWidget {

  final MainModel model;

  GalleryView(this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GalleryViewState();
  }
}

class GalleryViewState extends State<GalleryView> {


  List<Widget> _buildGridTiles(MainModel model) {
    print('this is all the products:');
    print(model.allProducts1[0].imagePaths.length.toString());

    List<Container> containers =
        List<Container>.generate(2, (int index) {
      final imageName = 'assets/testimages/testimage${index + 1}.jpg';
      return Container(
        child: Image.asset(imageName, fit: BoxFit.cover,),
      );
    });
    return containers;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery View'),
      ),
      drawer: SideDrawer(),
      body: ScopedModelDescendant<MainModel>(
    builder: (BuildContext context, Widget child, MainModel model) {
      return GridView.extent(
        maxCrossAxisExtent: 150.0,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        children: _buildGridTiles(model),
        padding: EdgeInsets.all(5.0),
      );}
    )

);}

}
