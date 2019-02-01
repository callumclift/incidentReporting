import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image/image.dart' as imagePackage;

import 'package:path/path.dart' as path;

import '../../models/product.dart';
import '../../scoped_models/incidents_model.dart';
import '../../scoped_models/users_model.dart';

class AddImages extends StatefulWidget {
  final Function setImages;
  final Function disableScreen;
  List<dynamic> temporaryPaths;
  AddImages(this.setImages, this.disableScreen, this.temporaryPaths);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddImagesState();
  }
}

class AddImagesState extends State<AddImages> {
  IncidentsModel _incidentsModel;
  UsersModel _usersModel;

  bool _pickInProgress = false;

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

  @override
  void initState() {
    print('inside initState of images');
    _incidentsModel = ScopedModel.of<IncidentsModel>(context);
    _usersModel = ScopedModel.of<UsersModel>(context);

    _populateImageFiles();

    super.initState();
  }

  _populateImageFiles() {
    _incidentsModel
        .getTemporaryIncident(_usersModel.authenticatedUser.userId)
        .then((Map<String, dynamic> incident) {
      if (incident['images'] != null) {
        widget.temporaryPaths = jsonDecode(incident['images']);

        print('this is where i need to be');
        print(widget.temporaryPaths);
        print('ok done');

        if (widget.temporaryPaths != null) {
          print('here is the temporary paths');
          print(widget.temporaryPaths);

          int index = 0;
          widget.temporaryPaths.forEach((dynamic path) {
            if (path != null) {
              setState(() {
                images[index] = File(path);
              });
            }

            index++;
          });
        }
      }
    });
  }

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
      } else {
        setState(() {
          images[index] = image;
        });
      }
      widget.setImages(images);
      Navigator.pop(context);
    });
  }

  _pickPhoto(ImageSource source, int index) async {
    if (_pickInProgress) {
      return;
    }
    _pickInProgress = true;
    Navigator.pop(context);
    var image = await ImagePicker.pickImage(source: source, maxWidth: 800.0);

    if (image != null) {
      bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

      if (isAndroid)
        image = await FlutterExifRotation.rotateImage(path: image.path);

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/image' + index.toString();

      if (Directory(dirPath).existsSync()) {
        print('it exists');
        imageCache.clear();
        var dir = new Directory(dirPath);
        dir.deleteSync(recursive: true);
        if (Directory(dirPath).existsSync()) {
          print('still exists');
        } else {
          print('doesnt exist');
        }
      }

      new Directory(dirPath).createSync(recursive: true);
      String path =
          '$dirPath/temporaryIncidentImage' + index.toString() + '.jpg';

      File changedImage = image.copySync(path);

      path = changedImage.path;


      if (images[index] != null) {
        setState(() {
          //this is setting the image locally here
          images[index] = image;
          if(widget.temporaryPaths.length == 0){
            widget.temporaryPaths.add(path);
          } else if(widget.temporaryPaths.length < index +1){
            widget.temporaryPaths.add(path);
          } else {
            widget.temporaryPaths[index] = path;
          }

        });
      } else {
        setState(() {
          images[index] = changedImage;
          if (widget.temporaryPaths.length == 0) {
            widget.temporaryPaths.add(path);
          } else if (index == 0 && widget.temporaryPaths.length >= 1) {
            widget.temporaryPaths[index] = path;
          } else if (index == 1 && widget.temporaryPaths.length < 2) {
            widget.temporaryPaths.add(path);
          } else if (index == 1 && widget.temporaryPaths.length >= 2) {
            widget.temporaryPaths[index] = path;
          } else if (index == 2 && widget.temporaryPaths.length < 3) {
            widget.temporaryPaths.add(path);
          } else if (index == 2 && widget.temporaryPaths.length >= 3) {
            widget.temporaryPaths[index] = path;
          } else if (index == 3 && widget.temporaryPaths.length < 4) {
            widget.temporaryPaths.add(path);
          } else if (index == 3 && widget.temporaryPaths.length >= 4) {
            widget.temporaryPaths[index] = path;
          } else if (index == 4 && widget.temporaryPaths.length < 5) {
            widget.temporaryPaths.add(path);
          } else if (index == 4 && widget.temporaryPaths.length >= 5) {
            widget.temporaryPaths[index] = path;
          }
        });
      }
      widget.setImages(images);

      var encodedPaths = jsonEncode(widget.temporaryPaths);

      _incidentsModel.updateTemporaryIncidentField(
          'images', encodedPaths, _usersModel.authenticatedUser.userId);
    }
    widget.disableScreen(false);
    _pickInProgress = false;
  }

  void _openImagePicker(BuildContext context, int index) {
    double _deviceHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            height: images[index] == null
                ? _deviceHeight * 0.15
                : _deviceHeight * 0.22,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              double sheetHeight = constraints.maxHeight;

              return Container(
                height: sheetHeight,
                child: Column(
                  children: <Widget>[
                    Container(
                        height: sheetHeight * 0.15,
                        child: Text(
                          'Pick an Image',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Container(
                        height: images[index] == null
                            ? sheetHeight * 0.425
                            : sheetHeight * 0.283,
                        child: FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            widget.disableScreen(true);
                            _pickPhoto(ImageSource.camera, index);
                          },
                          child: Text('Use Camera'),
                        )),
                    Container(
                        height: images[index] == null
                            ? sheetHeight * 0.425
                            : sheetHeight * 0.283,
                        child: FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            widget.disableScreen(true);
                            _pickPhoto(ImageSource.gallery, index);
                          },
                          child: Text('Use Gallery'),
                        )),
                    images[index] == null
                        ? Container()
                        : Container(
                            height: sheetHeight * 0.283,
                            child: FlatButton(
                              textColor: Theme.of(context).primaryColor,
                              onPressed: () {
                                setState(() {
                                  print('this is the start');
                                  print(images);

                                  images[index] = null;
                                  widget.temporaryPaths[index] = null;
                                  print(images.length);

                                  int maxImageNo = images.length - 1;

                                  //if the last image in the list
                                  if (index == maxImageNo) {
                                    var encodedPaths =
                                        jsonEncode(widget.temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                            'images',
                                            encodedPaths,
                                            _usersModel
                                                .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  //if the image one in front is not null then replace this index with it
                                  int plusOne = index + 1;
                                  if (images[plusOne] != null) {
                                    images[index] = images[plusOne];
                                    images[plusOne] = null;
                                    widget.temporaryPaths[index] =
                                        widget.temporaryPaths[plusOne];
                                    widget.temporaryPaths[plusOne] = null;
                                  }

                                  //if the image two in front is not null then replace this index with it
                                  int plusTwo = index + 2;
                                  if (plusTwo > maxImageNo) {
                                    var encodedPaths =
                                        jsonEncode(widget.temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                            'images',
                                            encodedPaths,
                                            _usersModel
                                                .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  if (images[plusTwo] != null) {
                                    images[plusOne] = images[plusTwo];
                                    images[plusTwo] = null;
                                    widget.temporaryPaths[plusOne] =
                                        widget.temporaryPaths[plusTwo];
                                    widget.temporaryPaths[plusTwo] = null;
                                  }

                                  //if the image three in front is not null then replace this index with it
                                  int plusThree = index + 3;
                                  if (plusThree > maxImageNo) {
                                    var encodedPaths =
                                        jsonEncode(widget.temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                            'images',
                                            encodedPaths,
                                            _usersModel
                                                .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  if (images[plusThree] != null) {
                                    images[plusTwo] = images[plusThree];
                                    images[plusThree] = null;
                                    widget.temporaryPaths[plusTwo] =
                                        widget.temporaryPaths[plusThree];
                                    widget.temporaryPaths[plusThree] = null;
                                  }

                                  //if the image four in front is not null then replace this index with it
                                  int plusFour = index + 4;
                                  if (plusFour > maxImageNo) {
                                    var encodedPaths =
                                        jsonEncode(widget.temporaryPaths);
                                    _incidentsModel
                                        .updateTemporaryIncidentField(
                                            'images',
                                            encodedPaths,
                                            _usersModel
                                                .authenticatedUser.userId);
                                    Navigator.pop(context);
                                    return;
                                  }

                                  if (images[plusFour] != null) {
                                    images[plusThree] = images[plusFour];
                                    images[plusFour] = null;
                                    widget.temporaryPaths[plusThree] =
                                        widget.temporaryPaths[plusFour];
                                    widget.temporaryPaths[plusFour] = null;
                                  }

                                  print('this is the end');
                                  print(images);
                                  var encodedPaths =
                                      jsonEncode(widget.temporaryPaths);
                                  _incidentsModel.updateTemporaryIncidentField(
                                      'images',
                                      encodedPaths,
                                      _usersModel.authenticatedUser.userId);
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Delete Image'),
                            )),
                  ],
                ),
              );
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
