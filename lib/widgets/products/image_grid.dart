import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ImageGrid extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ImageGridState();
  }
}

class ImageGridState extends State<ImageGrid> {
  static File _imageFile1;
  static File _imageFile2;
  static File _imageFile3;
  static File _imageFile4;
  static File _imageFile5;
  static File _imageFile6;

  List<File> images = [
    _imageFile1,
    _imageFile2,
    _imageFile3,
    _imageFile4,
    _imageFile5,
    _imageFile6,
  ];

  List<Widget> _buildGridTiles(int numOfTiles) {
    List<Container> containers =
        List<Container>.generate(numOfTiles, (int index) {
      return Container(
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
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            height: 150.0,
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an Image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _getImage(context, ImageSource.camera, index);
                  },
                  child: Text('Use Camera'),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _getImage(context, ImageSource.gallery, index);
                  },
                  child: Text('Use Gallery'),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.extent(
      shrinkWrap: true,
      maxCrossAxisExtent: 70.0,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: _buildGridTiles(6),
      padding: EdgeInsets.all(5.0),
    );
  }
}
