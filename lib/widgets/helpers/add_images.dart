import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';

class AddImages extends StatefulWidget {
  final Function setImages;
  AddImages(this.setImages);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddImagesState();
  }
}

class AddImagesState extends State<AddImages> {
  static File _imageFile1;
  static File _imageFile2;
  static File _imageFile3;
  static File _imageFile4;
  static File _imageFile5;

  List<File> images = [
    _imageFile1,
    _imageFile2,
    _imageFile3,
    _imageFile4,
    _imageFile5,
  ];

  List<Widget> _buildGridTiles(BoxConstraints constraints, int numOfTiles) {
    List<Container> containers =
        List<Container>.generate(numOfTiles, (int index) {
      return Container(
        padding: EdgeInsets.all(2.0),
        width: constraints.maxWidth / 5,
        height: constraints.maxWidth / 5,
        child: GestureDetector(
          onTap: () {
            int minusIndex = index - 1;
            if (index == 0) {
              _openImagePicker(context, index);
            } else if (index > 0 && images[minusIndex] == null) {
              return;
            } else {
              _openImagePicker(context, index);
            }
          },
          child: gridColor(context, index),
        ),
      );
    });
    return containers;
  }

  Widget gridColor(BuildContext context, int index) {
    int minusIndex = index - 1;

    if (images[index] == null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (images[index] != null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (index > 0 &&
        images[minusIndex] != null &&
        images[index] == null) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (images[index] != null && index > 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.grey,
        ),
      );
    }
  }

  void _getImage(BuildContext context, ImageSource source, int index) {
    //fetch an image using the image picker class
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      if (images[index] != null) {
        setState(() {
          //this is setting the image locally here
          images[index] = image;
        });
        //now we can use the image in the surrounding form too
        //widget.setImage(image);
      } else {
        setState(() {
          images[index] = image;
        });
      }
      widget.setImages(images);
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context, int index) {

    double _deviceHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            height: images[index] == null? _deviceHeight * 0.15 : _deviceHeight * 0.22,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {

                  double sheetHeight = constraints.maxHeight;

                  return Container(height: sheetHeight, child: Column(
                    children: <Widget>[
                      Container(height: sheetHeight * 0.15,child: Text(
                        'Pick an Image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Container(height: images[index] == null? sheetHeight * 0.425: sheetHeight * 0.283, child: FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          _getImage(context, ImageSource.camera, index);
                        },
                        child: Text('Use Camera'),
                      )),
                      Container(height: images[index] == null? sheetHeight * 0.425: sheetHeight * 0.283, child: FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          _getImage(context, ImageSource.gallery, index);
                        },
                        child: Text('Use Gallery'),
                      )),
                      images[index] == null? Container() :
                      Container(height: sheetHeight * 0.283, child: FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {

                          setState(() {
                            print('this is the start');
                            print(images);


                            images[index] = null;
                            print(images.length);

                            int maxImageNo = images.length - 1;

                            //if the last image in the list
                            if(index == maxImageNo){
                              Navigator.pop(context);
                              return;
                            }

                            //if the image one in front is not null then replace this index with it
                            int plusOne = index + 1;
                            if(images[plusOne] != null){
                              images[index] = images[plusOne];
                              images[plusOne] = null;
                            }

                            //if the image two in front is not null then replace this index with it
                            int plusTwo = index + 2;
                            if(plusTwo > maxImageNo){
                              Navigator.pop(context);
                              return;
                            }

                            if(images[plusTwo] != null){
                              images[plusOne] = images[plusTwo];
                              images[plusTwo] = null;
                            }

                            //if the image three in front is not null then replace this index with it
                            int plusThree = index + 3;
                            if(plusThree > maxImageNo){
                              Navigator.pop(context);
                              return;
                            }

                            if(images[plusThree] != null){
                              images[plusTwo] = images[plusThree];
                              images[plusThree] = null;
                            }

                            //if the image four in front is not null then replace this index with it
                            int plusFour = index + 4;
                            if(plusFour > maxImageNo){
                              Navigator.pop(context);
                              return;
                            }

                            if(images[plusFour] != null){
                              images[plusThree] = images[plusFour];
                              images[plusFour] = null;
                            }


                            print('this is the end');
                            print(images);
                            Navigator.pop(context);
                          });

                        },
                        child: Text('Delete Image'),
                      )),
                    ],
                  ),);
                }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildGridTiles(constraints, images.length),
      );
    });
  }
}
