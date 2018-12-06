import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product product;

  ImageInput(this.setImage, this.product);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;
  File _imageFile1;


  void _getImage(BuildContext context, ImageSource source) {
    //fetch an image using the image picker class
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {

      if (_imageFile != null){
        setState(() {
          //this is setting the image locally here
          _imageFile1 = image;
        });
        //now we can use the image in the surrounding form too
        widget.setImage(image);
      } else {
        setState(() {
          _imageFile = image;
        });

      }
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context) {
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
                    _getImage(context, ImageSource.camera);
                  },
                  child: Text('Use Camera'),
                ),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
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
    final Color _buttonColour = Theme.of(context).primaryColor;

    Widget previewImage = Text('Please pick an image.');
    Widget previewImage1 = Text('Please pick a second image.');



    if(_imageFile != null){
      previewImage = Image.file(
        _imageFile,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      );
    } else if(widget.product != null){
      previewImage = Image.network(widget.product.image, fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,);

    }

    if(_imageFile1 != null){
      previewImage1 = Image.file(
        _imageFile1,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      );
    }

    // TODO: implement build
    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(color: _buttonColour, width: 2.0),
          onPressed: () {
            _openImagePicker(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: _buttonColour,
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                'Add Image',
                style: TextStyle(color: _buttonColour),
              )
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        previewImage,
        SizedBox(
          height: 10.0,
        ),
        previewImage1,
      ],
    );
  }
}
