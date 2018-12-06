import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/product1.dart';
import '../models/location_data.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/form_inputs/image.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/products/add_images.dart';

import '../scoped_models/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {

  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController = TextEditingController();
  final TextEditingController _priceTextController = TextEditingController();
  //this is a map to manage the form data
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    //'image': 'assets/food.jpg'
    'images': null,
    'location': null
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _priceFocusNode = FocusNode();

  //declare as private so people know its only for use in this class
  Widget _buildTitleText(Product product) {

    //these are the checks for the value due to the offscreen bug as we can no longer use initial value
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (product == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }


    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Title'),
      controller: _titleTextController,
      //initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty || value.length < 5) {
          return 'Title is required and should be 5+ characters long';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['title'] = value;
        });
      },
    );
  }

  Widget _buildDescriptionText(Product product) {
    if (product == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (product != null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = product.description;
    }

    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Description'),
      maxLines: 4,
      controller: _descriptionTextController,
      //initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty || value.length < 10) {
          return 'Description is required and should be 10+ characters long';
        }
      },
      onSaved: (String value) {
        setState(() {
          _formData['description'] = value;
        });
      },
    );
  }

  Widget _buildPriceText(Product product) {

    if (product == null && _priceTextController.text.trim() == '') {
      _priceTextController.text = '';
    } else if (product != null && _priceTextController.text.trim() == '') {
      _priceTextController.text = product.price.toString();
    }

    return TextFormField(
      focusNode: _priceFocusNode,
      decoration: InputDecoration(labelText: 'Product Price'),
      keyboardType: TextInputType.number,
      controller: _priceTextController,
      //initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.trim().length <= 0 && value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number';
        }
      },
//      onSaved: (String value) {
//        setState(() {
//          _formData['price'] =
//              double.parse(value.replaceFirst(RegExp(r','), '.'));
//        });
//      },
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(
              child: AdaptiveProgressIndicator(),
            )
          : RaisedButton(
              textColor: Colors.white,
              child: Text('Save'),
              onPressed: () => _submitForm(
                    model.addProduct1,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex,
                  ),
            );
    });
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleText(product),
              _buildDescriptionText(product),
              _buildPriceText(product),
              SizedBox(
                height: 10.0,
              ),
              LocationInput(_setLocation, product),
              SizedBox(
                height: 10.0,
              ),
              AddImages(_setImages, product),
              SizedBox(
                height: 10.0,
              ),
//              ImageInput(_setImages, product),
//              SizedBox(
//                height: 10.0,
//              ),
              _buildSubmitButton(),
//          GestureDetector(
//                  onTap: _submitForm,
//                  child: Container(
//                    width: 100.0,
//                    color: Colors.green,
//                    padding: EdgeInsets.all(5.0),
//                    child: Text('Submit', textAlign: TextAlign.center,),
//                  ),
//                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setLocation(LocationData locationData) {
    _formData['location'] = locationData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _setImages(List<File> images) {
    _formData['images'] = images;
  }

  void _submitForm(
    Function addProduct1,
    Function updateProduct,
    Function setSelectedProduct,
    int selectedProductIndex,
  ) {
    //if the form fails the validation then return and dont execute anymore code
    //or is the image is null and we are not in edit mode
    if (!_formKey.currentState.validate() || (_formData['images'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formKey.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct1(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['images'],
        double.parse(_priceTextController.text.replaceFirst(RegExp(r','), '.')),
        _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong'),
                  content: Text('Please try again'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                );
              });
        }
      });
    } else {
      updateProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        double.parse(_priceTextController.text.replaceFirst(RegExp(r','), '.')),
        _formData['location'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/')
            .then((_) => setSelectedProduct(null));
      });
    }

//    if (_formKey.currentState.validate()) {
//      _formKey.currentState.save();
//    } else {
//      return;
//    }
    //you can declare the map like this or you can pass it directly into add product
//    final Map<String, dynamic> product = {
//      'title': _titleText,
//      'image': 'assets/food.jpg',
//      'description': _descriptionText,
//      'price': _priceValue
//    };
    //this is where we pass in the key value pairs so we pass in the form data
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Create Page] - build page');
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: pageContent,
              );
      },
    );
  }
}
