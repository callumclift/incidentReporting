import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:random_string/random_string.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:encrypt/encrypt.dart';

import '../models/product.dart';
import '../models/product1.dart';
import '../models/incident.dart';
import '../models/user.dart';
import '../models/authenticated_user.dart';
import '../models/auth.dart';
import '../models/location_data.dart';
import '../utils/database_helper.dart';
import '../shared/global_config.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  List<User> _users = [];
  List<Product1> _products1 = [];
  List<Incident> _incidents = [];
  List<Incident> _myIncidents = [];
  String _selProductId;
  String _selIncidentKey;
  String _selMyIncidentId;
  String _selUserKey;
  AuthenticatedUser _authenticatedUser;
  bool _isLoading = false;
}

mixin ProductsModel on ConnectedProductsModel {

  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<User> get allUsers {
  return List.from(_users);
  }

  List<Incident> get allIncidents {
  return List.from(_incidents);
  }

  List<Incident> get allMyIncidents {
    return List.from(_myIncidents);
  }

  List<Product1> get allProducts1 {
    return List.from(_products1);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return _products.where((Product product) => product.isFavourite).toList();
    }
    return List.from(_products);
  }

  List<Product1> get displayedProducts1 {
    if (_showFavourites) {
      return _products1.where((Product1 product) => product.isFavourite).toList();
    }
    return List.from(_products1);
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  int get selectedUserIndex {
    return _users.indexWhere((User user) {
      return user.id == _selUserKey;
    });
  }

  int get selectedIncidentIndex {
    return _incidents.indexWhere((Incident incident) {
      return incident.id == _selIncidentKey;
    });
  }

  int get selectedMyIncidentIndex {
    return _myIncidents.indexWhere((Incident incident) {
      return incident.id == _selMyIncidentId;
    });
  }

  String get selectedProductId {
    return _selProductId;
  }

  String get selectedUserKey {
    return _selUserKey;
  }

  String get selectedIncidentKey {
    return _selIncidentKey;
  }

  String get selectedMyIncidentId {
    return _selMyIncidentId;
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  User get selectedUser {
    if (_selUserKey == null) {
      return null;
    }
    return _users.firstWhere((User user) {
      return user.id == _selUserKey;
    });
  }

  Incident get selectedIncident {
    if (_selIncidentKey == null) {
      return null;
    }
    return _incidents.firstWhere((Incident incident) {
      return incident.id == _selIncidentKey;
    });
  }

  Incident get selectedMyIncident {
    if (_selMyIncidentId == null) {
      return null;
    }
    return _myIncidents.firstWhere((Incident incident) {
      return incident.id == _selMyIncidentId;
    });
  }

  Product1 get selectedProduct1 {
    if (_selProductId == null) {
      return null;
    }
    return _products1.firstWhere((Product1 product) {
      return product.id == _selProductId;
    });
  }

  Future<Null> fetchProducts({onlyForUser: false, clearExisting = false}) {

    _isLoading = true;

    if (clearExisting) {
      _products = [];
    }

    return http
        .get(
            'https://flutter-products-5ac44.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['imageUrl'],
            imagePath: productData['imagePath'],
            price: productData['price'],
            location: LocationData(
              address: productData['loc_address'],
              latitude: productData['loc_lat'],
              longitude: productData['loc_lng'],
            ),
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavourite: productData['wishListUsers'] == null
                ? false
                : (productData['wishListUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedProductList.add(product);
      });

      //when fetching products check here to see which get display - lockdown editing for creators only
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

Future<Null> fetchMyIncidents() async{

  _isLoading = true;
  notifyListeners();

  final List<Incident> fetchedIncidentList = [];

  try {

    DatabaseHelper databaseHelper = DatabaseHelper();

    List<Map<String, dynamic>> test = await databaseHelper.getIncidentMapList();


    List<Map<String, dynamic>> incidentsList = await databaseHelper.getIncidentMapList();

    if (incidentsList.length == 0){
      print('there are no incidents');
    } else {
      print('we have some incidents');
    }

    print('this is the size of the incident list locally');
    print(incidentsList.length);

    incidentsList.forEach((Map<String, dynamic> incidentMap) {
      print('the start of the for each');

      final Incident incident = Incident.myIncident(
          incidentId: incidentMap['id'],
          incidentType: incidentMap['incidentType'],
          reporterFirstName: incidentMap['reporterFirstName'],
          reporterLastName: incidentMap['reporterLastName'],
          dateTime: incidentMap['dateTime'],
          location: LocationData(longitude: incidentMap['locLng'], latitude: incidentMap['locLat']),
          projectName: incidentMap['projectName'],
          route: incidentMap['route'],
          elr: incidentMap['elr'],
          mileage: incidentMap['mileage'],
          summary: incidentMap['summary'],
          organisation: incidentMap['organisation'],
          reporterEmail: incidentMap['reporterEmail'],
      );
      print('ok about to add');
      fetchedIncidentList.add(incident);

      //Incident incident = Incident(id: null, incidentType: null, reporter: null, dateTime: null, location: null, projectName: null, route: null, elr: null, mileage: null, summary: null, imagePaths: null, images: null, organisation: null, reporterEmail: null, voided: null)
    });

    //return incidentsList;

  } catch (error) {
    print(error);
  }

  _myIncidents = fetchedIncidentList;
  _isLoading = false;
  notifyListeners();

}

Future<Null> fetchIncidents(String role, {onlyForUser: false, clearExisting = false}) async{

  _isLoading = true;

  if (clearExisting) {
    _users = [];
  }

  final List<Incident> fetchedIncidentList = [];

  Map<String, dynamic> incidentData = {};


  try {

//    _onEntryAdded(Event event){
//
//      print('its gets hererewefwef');
//
//      incidentData = new Map.from(event.snapshot.value);
//
//      final Incident incident = Incident(
//          id: 'gghghg',
//          incidentType: incidentData['incidentType'],
//          reporter: incidentData['reporter'],
//          dateTime: incidentData['dateTime'],
//          location: incidentData['location'],
//          projectName: incidentData['projectName'],
//          route: incidentData['route'],
//          elr: incidentData['elr'],
//          mileage: incidentData['mileage'],
//          summary: incidentData['suspended']);
//      fetchedIncidentList.add(incident);
//
//    }

    print('its getting into the try');

    DataSnapshot snapshot;

    snapshot = await FirebaseDatabase.instance
        .reference().child('incidents').orderByChild('dateTime')
        .once();



//    FirebaseDatabase.instance
//        .reference().child('incidents').onChildAdded.listen(_onEntryAdded);







    incidentData = new Map.from(snapshot.value);


    incidentData.forEach((String incidentKey, dynamic incidentData) {
      print(incidentKey);
      print(incidentData);


      List<String> images = [];
      List<String> imagePaths = [];



      for (var value in incidentData['imageUrls']) {
        print('inside the for looppp');
        images.add(value);
      }

      for (var value in incidentData['imagePaths']) {
        print('inside the for looppp');
        imagePaths.add(value);
      }



      final Incident incident = Incident(
          id: incidentKey,
          incidentType: incidentData['incidentType'],
          reporterFirstName: incidentData['reporterFirstName'],
          reporterLastName: incidentData['reporterLastName'],
          dateTime: incidentData['dateTime'],
          location: LocationData(longitude: incidentData['loc_lng'], latitude: incidentData['loc_lat']),
          projectName: incidentData['projectName'],
          route: incidentData['route'],
          elr: incidentData['elr'],
          mileage: incidentData['mileage'],
          summary: incidentData['summary'],
          imagePaths: imagePaths,
          images: images,
          organisation: incidentData['organisation'],
          reporterEmail: incidentData['reporterEmail'],
          voided: incidentData['voided']
      );
      print('ok about to add');
      fetchedIncidentList.add(incident);
    });

    fetchedIncidentList.sort((Incident a, Incident b) => a.dateTime.compareTo(b.dateTime));

    print('its sorted the list');



    fetchedIncidentList.forEach((Incident incident){

      print(incident.dateTime);

    });

    _incidents = fetchedIncidentList;
    _isLoading = false;
    notifyListeners();
    _selIncidentKey = null;

  } catch(e){
    _isLoading = false;
    notifyListeners();
    return;
  }
}

Future<Null> fetchUsers(String role, {onlyForUser: false, clearExisting = false}) async{

  _isLoading = true;

  if (clearExisting) {
    _users = [];
  }

  final List<User> fetchedUserList = [];

  Map<String, dynamic> userData = {};


  try {

    DataSnapshot snapshot;

    snapshot = await FirebaseDatabase.instance
        .reference().child('users').orderByChild('firstName')
        .once();

    userData = new Map.from(snapshot.value);

    userData.forEach((String userKey, dynamic userData) {
      final User user = User(
          id: userKey,
          authenticationId: userData['authenticationId'],
          email: userData['email'],
          firstName: userData['firstName'],
          surname: userData['surname'],
          organisation: userData['organisation'],
          role: userData['role'],
          hasTemporaryPassword: userData['hasTemporaryPassword'],
          acceptedTerms: userData['acceptedTerms'],
          suspended: userData['suspended']);
      fetchedUserList.add(user);
    });

    fetchedUserList.sort((User a, User b) => a.firstName.compareTo(b.firstName));

    fetchedUserList.forEach((User user){

      print(user.firstName);

    });

    _users = fetchedUserList;
    _isLoading = false;
    notifyListeners();
    _selProductId = null;

  } catch(e){
    _isLoading = false;
    notifyListeners();
    return;
  }
}

  Future<Null> fetchProducts1({onlyForUser: false, clearExisting = false}) {




    _isLoading = true;
    print('it gets in fetch products');

    if (clearExisting) {
      _products1 = [];
    }

    print('it gets in fetch products 1');
    return http
        .get(
        'https://flutter-products-5ac44.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
          print('then it gets here');
      final List<Product1> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      print('this is the response body');
      print(response.body);
          productListData.forEach((String productId, dynamic productData) {
            print(productData);
          });

      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        print('hi');
        print(productData['title']);

       List<String> images = [];
        List<String> imagePaths = [];



        for (var value in productData['imageUrls']) {
          print('inside the for looppp');
          images.add(value);
        }

        for (var value in productData['imagePaths']) {
          print('inside the for looppp');
          imagePaths.add(value);
        }



        print('it gets into the for each');
        final Product1 product = Product1(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            images: images,
            imagePaths: imagePaths,
            price: productData['price'],
            location: LocationData(
              address: productData['loc_address'],
              latitude: productData['loc_lat'],
              longitude: productData['loc_lng'],
            ),
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavourite: productData['wishListUsers'] == null
                ? false
                : (productData['wishListUsers'] as Map<String, dynamic>)
                .containsKey(_authenticatedUser.id));
        print('it gets to the bottom of the for each');
        fetchedProductList.add(product);
        print('this is the fetched product list:');
        print(fetchedProductList.length.toString());

      });

      //when fetching products check here to see which get display - lockdown editing for creators only
      print('this is the fetched product list:');
      print(fetchedProductList.length.toString());
      _products1 = onlyForUser
          ? fetchedProductList.where((Product1 product) {
        return product.userId == _authenticatedUser.id;
      }).toList()
          : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      _selProductId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }



  //this gets called from within add and update product
  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-incident-reporting-a5394.cloudfunctions.net/storeImage'));

    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }

    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final http.StreamedResponse streamedResponse =
          await imageUploadRequest.send();
      final http.Response response =
          await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> uploadImages(List<File> images,
      {String imagePath}) async {
    List<Map<String, dynamic>> uploadedImages = [];

    print('these are the images');
    print(images);

    for (File image in images) {
      if (image == null) {
        continue;
      }

      print('it got inside the for each ofr the images');
      print(image);
      print('image path');
      print(image.path);

      final mimeTypeData = lookupMimeType(image.path).split('/');
      final imageUploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://us-central1-incident-reporting-a5394.cloudfunctions.net/storeImage'));

      final file = await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );
      imageUploadRequest.files.add(file);
      if (imagePath != null) {
        imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
      }

      imageUploadRequest.headers['Authorization'] =
          'Bearer ${_authenticatedUser.token}';

      try {
        print('it got inside the try');
        final http.StreamedResponse streamedResponse =
            await imageUploadRequest.send();
        final http.Response response =
            await http.Response.fromStream(streamedResponse);
        if (response.statusCode != 200 && response.statusCode != 201) {
          print(json.decode(response.body));
          return null;
        }
        final responseData = json.decode(response.body);
        print('this is the response data');
        print(responseData);
        uploadedImages.add(responseData);
        print('this is the uploaded images inside the loop');
        print(uploadedImages);
      } catch (error) {
        print(error);
        return null;
      }
    }

    print('this the uploaded images after the for each');
    print(uploadedImages);

    return uploadedImages;
  }

  Future<bool> addProduct(String title, String description, File image,
      double price, LocationData locationData) async {
    _isLoading = true;
    notifyListeners();
    //we need to await this as we return a future here
    final uploadData = await uploadImage(image);

    //because we return null in all error cases
    if (uploadData == null) {
      print('Upload Failed');
      //and we will return false here because we failed
      return false;
    }

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'loc_lat': locationData.latitude,
      'loc_lng': locationData.longitude,
      'loc_address': locationData.address
    };

    try {
      final http.Response response = await http.post(
          'https://flutter-products-5ac44.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: uploadData['imageUrl'],
          imagePath: uploadData['imagePath'],
          price: price,
          location: locationData,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id,
          isFavourite: false);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      print('its hereeeeeeeeee');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct1(String title, String description, List<File> images,
      double price, LocationData locationData) async {
    _isLoading = true;
    notifyListeners();
    //we need to await this as we return a future here

    List<Map<String, dynamic>> uploadData = await uploadImages(images);

    print('upload data inside add product');
    print(uploadData);

    //because we return null in all error cases

    uploadData.forEach((upload) {
      if (upload == null) {
        print('Upload Failed');
        //and we will return false here because we failed
        return false;
      }
    });

    List<String> imagePaths = [];
    List<String> imageUrls = [];

    uploadData.forEach((upload) {
      imagePaths.add(upload['imagePath']);
      imageUrls.add(upload['imageUrl']);
    });

    print('the image paths inside the addproduct1');
    print(imagePaths);

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imagePaths': imagePaths,
      'imageUrls': imageUrls,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'loc_lat': locationData.latitude,
      'loc_lng': locationData.longitude,
      'loc_address': locationData.address
    };

    try {
      final http.Response response = await http.post(
          'https://flutter-products-5ac44.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product1 newProduct = Product1(
          id: responseData['name'],
          title: title,
          description: description,
          images: imageUrls,
          imagePaths: imagePaths,
          price: price,
          location: locationData,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id,
          isFavourite: false);
      _products1.add(newProduct);
      print('check to see if added to products 1 list');
      print(_products1);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      print('its hereeeeeeeeee');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

Future<Map<String, dynamic>> addIncidentLocally(String incidentType, String reporter, String dateTime, LocationData locationData,
    String projectName, String route, String elr, double mileage, String summary, List<File> images) async {

  _isLoading = true;
  notifyListeners();

  String message = 'Something went wrong!';
  bool hasError = true;

  List<String> base64Images = [];

  for (File image in images) {
    if (image == null) {
      continue;
    }
    List<int> imageBytes =image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    base64Images.add(base64Image);
  }

  var encodedImages = jsonEncode(base64Images);

  try {

    DatabaseHelper databaseHelper = DatabaseHelper();

    int count = await databaseHelper.getCount();
    int id;

    if (count == 0) {
      id = 1;
    } else {
      id = count + 1;
    }






    Map<String, dynamic> incidentData = {
      'incidentId': id,
      'userId': _authenticatedUser.id,
      'incidentType': incidentType,
      'reporterName': reporter,
      'dateTime': dateTime,
      'locLat': locationData.latitude,
      'locLng': locationData.longitude,
      'projectName': projectName,
      'route': route,
      'elr': elr,
      'mileage': mileage,
      'summary': summary,
      'organisationId': _authenticatedUser.organisationId,
      'organisationName': _authenticatedUser.organisationName,
      'reporterEmail': _authenticatedUser.email,
      'voided': 0,
      'images' : encodedImages
    };

    int result = await databaseHelper.addIncident(incidentData);

    if (result != 0){
      print('Incident has successfully been added to local database');
      hasError = false;
      message = 'Incident has been successfully uploaded';
    }

  } catch (error) {
    print(error);
  }

  _isLoading = false;
  notifyListeners();
  return {'success': !hasError, 'message': message};

}

  Future<Map<String, dynamic>> addIncident(String incidentType, String reporter, String dateTime, LocationData locationData,
  String projectName, String route, String elr, double mileage, String summary, List<File> images) async {


    _isLoading = true;
    notifyListeners();

    String message = 'Something went wrong!';
    bool hasError = true;

    try {
      print('ok its in the try');
    List<Map<String, dynamic>> uploadData = await uploadImages(images);

    print('upload data inside add product');
    print(uploadData);

    //because we return null in all error cases

    uploadData.forEach((upload) {
      if (upload == null) {
        print('Upload Failed');
      }
    });

    List<String> imagePaths = [];
    List<String> imageUrls = [];

    uploadData.forEach((upload) {
      imagePaths.add(upload['imagePath']);
      imageUrls.add(upload['imageUrl']);
    });

    print('the image paths inside the addproduct1');
    print(imagePaths);

    final Map<String, dynamic> incidentData = {
      'incidentType': incidentType,
      'reporter': reporter,
      'dateTime': dateTime,
      'loc_lat': locationData.latitude,
      'loc_lng': locationData.longitude,
      'projectName': projectName,
      'route': route,
      'elr': elr,
      'mileage': mileage,
      'summary': summary,
      'imagePaths': imagePaths,
      'imageUrls': imageUrls,
      'organisation': _authenticatedUser.organisationName,
      'reporterEmail': _authenticatedUser.email,
      'voided': false
    };


      final http.Response response = await http.post(
          'https://incident-reporting-a5394.firebaseio.com/incidents.json?auth=${_authenticatedUser
              .token}',
          body: json.encode(incidentData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        hasError = false;
        message = 'Incident has been successfully uploaded';
      }

    } catch (error) {
      print(error);
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};


  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final String deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();

    return http
        .delete(
            'https://flutter-products-a5394.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
    //before this is able to execute we need to be able selectProduct
    //so that index has a valid value, then after set the index to null
  }

  // NEWLY ADDED => Add the "toggledProduct" as an argument to the method
  void toggleProductFavoriteStatus(Product toggledProduct) async {
    final bool isCurrentlyFavorite = toggledProduct.isFavourite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    // NEWLY ADDED => Get the index of the product passed into the method
    final int toggledProductIndex = _products.indexWhere((Product product) {
      return product.id == toggledProduct.id;
    });
    final Product updatedProduct = Product(
        id: toggledProduct.id,
        title: toggledProduct.title,
        description: toggledProduct.description,
        price: toggledProduct.price,
        image: toggledProduct.image,
        imagePath: toggledProduct.imagePath,
        location: toggledProduct.location,
        userEmail: toggledProduct.userEmail,
        userId: toggledProduct.userId,
        isFavourite: newFavoriteStatus);
    _products[toggledProductIndex] =
        updatedProduct; // Use the "toggledProductIndex" derived earlier in the method
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://flutter-products-5ac44.firebaseio.com/products/${toggledProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-products-5ac44.firebaseio.com/products/${toggledProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
          id: toggledProduct.id,
          title: toggledProduct.title,
          description: toggledProduct.description,
          price: toggledProduct.price,
          image: toggledProduct.image,
          imagePath: toggledProduct.imagePath,
          location: toggledProduct.location,
          userEmail: toggledProduct.userEmail,
          userId: toggledProduct.userId,
          isFavourite: !newFavoriteStatus);
      _products[toggledProductIndex] = updatedProduct;
      notifyListeners();
    }
    // _selProductId = null; => This has to be removed/ commented out!
  }

  void toggleProductFavoriteStatus1(Product1 toggledProduct) async {
    final bool isCurrentlyFavorite = toggledProduct.isFavourite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    // NEWLY ADDED => Get the index of the product passed into the method
    final int toggledProductIndex = _products.indexWhere((Product product) {
      return product.id == toggledProduct.id;
    });
    final Product1 updatedProduct = Product1(
        id: toggledProduct.id,
        title: toggledProduct.title,
        description: toggledProduct.description,
        price: toggledProduct.price,
        images: toggledProduct.images,
        imagePaths: toggledProduct.imagePaths,
        location: toggledProduct.location,
        userEmail: toggledProduct.userEmail,
        userId: toggledProduct.userId,
        isFavourite: newFavoriteStatus);
    _products1[toggledProductIndex] =
        updatedProduct; // Use the "toggledProductIndex" derived earlier in the method
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://flutter-products-5ac44.firebaseio.com/products/${toggledProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-products-5ac44.firebaseio.com/products/${toggledProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product1 updatedProduct = Product1(
          id: toggledProduct.id,
          title: toggledProduct.title,
          description: toggledProduct.description,
          price: toggledProduct.price,
          images: toggledProduct.images,
          imagePaths: toggledProduct.imagePaths,
          location: toggledProduct.location,
          userEmail: toggledProduct.userEmail,
          userId: toggledProduct.userId,
          isFavourite: !newFavoriteStatus);
      _products1[toggledProductIndex] = updatedProduct;
      notifyListeners();
    }
    // _selProductId = null; => This has to be removed/ commented out!
  }

  Future<bool> updateProduct(String title, String description, File image,
      double price, LocationData locationData) async {
    _isLoading = true;
    notifyListeners();

    String imageUrl = selectedProduct.image;
    String imagePath = selectedProduct.imagePath;

    if (image != null) {
      final uploadData = await uploadImage(image);

      //because we return null in all error cases
      if (uploadData == null) {
        print('Upload Failed');
        //and we will return false here because we failed
        return false;
      }

      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'loc_address': locationData.address,
      'loc_lat': locationData.latitude,
      'loc_lng': locationData.longitude,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      //'isFavourite': selectedProduct.isFavourite
    };

    try {
      await http.put(
          'https://flutter-products-5ac44.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));

      _isLoading = false;
      final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: imageUrl,
        imagePath: imagePath,
        price: price,
        location: locationData,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        //isFavourite: selectedProduct.isFavourite,
      );
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //This ensures, that existing pages are only immediately updated (=> re-rendered) when a product is selected, not when it's unselected.
  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void selectUser(String userKey) {
    _selUserKey = userKey;
    if (userKey != null) {
      notifyListeners();
    }
  }

  void selectIncident(String incidentKey) {
    _selIncidentKey = incidentKey;
    if (incidentKey != null) {
      notifyListeners();
    }
  }

  void selectMyIncident(String incidentId) {
    _selMyIncidentId = incidentId;
    if (incidentId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;

  AuthenticatedUser get authenticatedUser {
    return _authenticatedUser;
  }

  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

Future<Map<String, dynamic>> addUser(String firstName, String surname, String email, String organisation, String role) async {
  _isLoading = true;
  notifyListeners();

  if(firstName.length == 1){
    firstName = firstName.toUpperCase();
  } else {
    firstName = '${firstName[0].toUpperCase()}${firstName.substring(1)}';
  }

  if(surname.length == 1){
    surname = surname.toUpperCase();
  } else {
    surname = '${surname[0].toUpperCase()}${surname.substring(1)}';
  }

  final String temporaryPassword = randomAlphaNumeric(10);

  final Map<String, dynamic> authData = {
    'email': email,
    'password': temporaryPassword,
    'returnSecureToken': false
  };

  String message = 'Something went wrong!';
  bool hasError = true;

  http.Response response;

  try {
        response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'},
        );


    Map<String, dynamic> responseData = json.decode(response.body);




    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'authentication succeeded';

      final Map<String, dynamic> userData = {
        'authenticationId': responseData['localId'],
        'firstName': firstName,
        'surname': surname,
        'organisation': organisation,
        'role': role,
        'email': email,
        'hasTemporaryPassword' : true,
        'acceptedTerms' : false,
        'suspended' : false
      };


        final http.Response response = await http.post(
            'https://incident-reporting-a5394.firebaseio.com/users.json?auth=${_authenticatedUser
                .token}',
            body: json.encode(userData));

        if (response.statusCode != 200 && response.statusCode != 201) {

          await http.post(
            'https://www.googleapis.com/identitytoolkit/v3/relyingparty/deleteAccount?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
            body: json.encode({'idToken' : responseData['localId']}),
            headers: {'Content-Type': 'application/json'},
          );
          _isLoading = false;
          notifyListeners();
          hasError = true;
          message = 'something went wrong';
        }

        final User newUser = User(
            authenticationId: responseData['id'],
            id: responseData['name'],
            firstName: firstName,
            surname: surname,
            email: email,
            organisation: organisation,
            role: role,
            hasTemporaryPassword: true,
          acceptedTerms: false,
          suspended: false
        );
        _users.add(newUser);
        await signUpEmail(temporaryPassword, email, firstName);
        hasError = false;
        message = 'user added successfully';

    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email not found';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Incorrect password';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }
  } catch(e){
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};

  }

  print('this is the selected user key');

  print(_selUserKey);


  _isLoading = false;
  notifyListeners();
  return {'success': !hasError, 'message': message};

}

Future<Map<String, dynamic>> deleteUser(String userId) async {
    
    await CloudFunctions.instance.call(functionName: 'deleteUser', parameters: {'uid' : userId});

  String message = 'Something went wrong!';
  bool hasError = true;
  print('this is the user id');
  print(userId);

  final Map<String, dynamic> authData = {
    'idToken': userId
  };
  
  


  http.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/deleteAccount?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
    body: json.encode(authData),
    headers: {'Content-Type': 'application/json'},
  ).then((http.Response response) {

    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    if (responseData == null) {
      _isLoading = false;
      notifyListeners();
    return {'success': hasError, 'message': message};

    } else if (responseData['kind'] != null || responseData['error'] != ''){
      _isLoading = false;
      message = 'User has been deleted';
      notifyListeners();
      return {'success': !hasError, 'message': message};

    }


  }).catchError((error) {
    _isLoading = false;
    notifyListeners();
    return {'success': hasError, 'message': message};

  });
  _isLoading = false;
  notifyListeners();
  hasError = true;
  message = 'something went wrong';
    return {};


}

Future<Map<String, dynamic>> newPassword(String newPassword) async {
  _isLoading = true;
  notifyListeners();

  String idToken = _authenticatedUser.token;

  print(idToken);



  final Map<String, dynamic> authData = {
    'idToken': idToken,
    'password': newPassword,
    'returnSecureToken': true
  };

  String message = 'Something went wrong!';
  bool hasError = true;

  http.Response response;

  try {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/setAccountInfo?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );


    Map<String, dynamic> responseData = json.decode(response.body);

    print(responseData);




    if (responseData.containsKey('passwordHash')) {
      hasError = false;
      message = 'your password has been changed';

      _authenticatedUser = AuthenticatedUser(
          id: _authenticatedUser.id,
          email: _authenticatedUser.email,
          token: responseData['idToken'],
          suspended: _authenticatedUser.suspended,
          acceptedTerms: _authenticatedUser.acceptedTerms,
          hasTemporaryPassword: false,
          organisationId: 1,
          organisationName: _authenticatedUser.organisationName,
          surname: _authenticatedUser.surname,
          firstName: _authenticatedUser.firstName,
          role: _authenticatedUser.role,
          authenticationId: _authenticatedUser.authenticationId);





      setAuthTimeout(int.parse(responseData['expiresIn']));
      //_userSubject.add(true);

      final DateTime now = DateTime.now();
      print('this is the time currently now' + now.toIso8601String());

      final DateTime expiryTime =
      now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      print('this is the expiry time at the point of logging in' +
          expiryTime.toIso8601String());

      final SharedPreferences prefs = await SharedPreferences
          .getInstance();
      prefs.setString('id', _authenticatedUser.id);
      prefs.setString('email', _authenticatedUser.email);
      prefs.setString('token', _authenticatedUser.token);
      prefs.setBool('suspended', _authenticatedUser.suspended);
      prefs.setBool('acceptedTerms', _authenticatedUser.acceptedTerms);
      prefs.setBool('hasTemporaryPassword', _authenticatedUser.hasTemporaryPassword);
      prefs.setString('organisation', _authenticatedUser.organisationName);
      prefs.setString('surname', _authenticatedUser.firstName);
      prefs.setString('firstName', _authenticatedUser.surname);
      prefs.setString('role', _authenticatedUser.role);
      prefs.setString('authenticationId', _authenticatedUser.authenticationId);
      prefs.setString('expiryTime', expiryTime.toIso8601String());



    } else if (responseData['error']['message'] == 'CREDENTIAL_TOO_OLD_LOGIN_AGAIN') {
      message = 'Your session has expired please login again with your temporary password';
    }
  } catch(e){

    print(e);

  }

  print('this is the selected user key');

  print(_selUserKey);


  _isLoading = false;
  notifyListeners();

  final Map<String, dynamic> updateData = {
    'authenticationId': _authenticatedUser.authenticationId,
    'firstName': _authenticatedUser.firstName,
    'surname': _authenticatedUser.surname,
    'organisation': _authenticatedUser.organisationName,
    'role': _authenticatedUser.role,
    'email': _authenticatedUser.email,
    'hasTemporaryPassword' : false,
    'acceptedTerms' : _authenticatedUser.acceptedTerms,
    'suspended' : _authenticatedUser.suspended
  };
  try {
    await FirebaseDatabase.instance.reference().child('users').child(_authenticatedUser.id).update(updateData);
  } catch(e) {
    print(e);
  }
  return {'success': !hasError, 'message': message};

}

Future<bool> acceptTerms() async {
  _isLoading = true;
  notifyListeners();

  bool successful = false;

  final Map<String, dynamic> updateData = {
    'authenticationId': _authenticatedUser.authenticationId,
    'firstName': _authenticatedUser.firstName,
    'surname': _authenticatedUser.surname,
    'organisation': _authenticatedUser.organisationName,
    'role': _authenticatedUser.role,
    'email': _authenticatedUser.email,
    'hasTemporaryPassword' : _authenticatedUser.hasTemporaryPassword,
    'acceptedTerms' : true,
    'suspended' : _authenticatedUser.suspended
  };

  try {
    await FirebaseDatabase.instance.reference().child('users').child(_authenticatedUser.id).update(updateData);
    successful = true;
    _authenticatedUser.acceptedTerms = true;
    final SharedPreferences prefs = await SharedPreferences
        .getInstance();
    prefs.setBool('acceptedTerms', true);

  } catch(e) {
    successful = false;
    print(e);
  }


  _isLoading = false;
  notifyListeners();
  return successful;

}

Future<Map<String, dynamic>>suspendResumeUser(String userKey, bool suspended) async {

    bool hasError = true;
    String message = 'Something went wrong';

  try {
    await FirebaseDatabase.instance.reference().child('users').child(userKey).update({'suspended': !suspended});
  } catch(e) {
    print(e);
    return {'success' : hasError, 'message' : message};
  }

  if(!suspended == true) {
    message = 'User has been suspended';
  } else {
    message = 'User has been resumed';
  }

  return {'success' : !hasError, 'message' : message};
}

Future<Map<String, dynamic>>voidUnvoidIncident(String incidentKey, bool voided) async {

  bool hasError = true;
  String message = 'Something went wrong';

  try {
    await FirebaseDatabase.instance.reference().child('incidents').child(incidentKey).update({'voided': !voided});
  } catch(e) {
    print(e);
    return {'success' : hasError, 'message' : message};
  }

  if(!voided == true) {
    message = 'Incident has been voided';
  } else {
    message = 'Incident has been unvoided';
  }

  return {'success' : !hasError, 'message' : message};
}

Future<Map<String, dynamic>>editUser(User user, String firstName, String surname, String email, String organisation, String role) async {

  _isLoading = true;
  notifyListeners();

  bool hasError = true;
  String message = 'Something went wrong';

  final Map<String, dynamic> updateData = {
    'authenticationId': user.authenticationId,
    'firstName': firstName,
    'surname': surname,
    'organisation': organisation,
    'role': role,
    'email': email,
    'hasTemporaryPassword' : user.hasTemporaryPassword,
    'acceptedTerms' : user.acceptedTerms,
    'suspended' : user.suspended
  };

  print('its got here before the fail');


  try {
    await FirebaseDatabase.instance.reference().child('users').child(user.id).update(updateData);
    message = 'User has been edited';
    hasError = false;
  } catch(e) {
    print(e);
  }



  _isLoading = false;
  notifyListeners();
  return {'success' : !hasError, 'message' : message};
}

  Future signUpEmail(String temporaryPassword String email, String firstName) async {


    final smtpServer = hotmail('callum.clift@on-trac.co.uk', 'jhjhjhj');

    final message = new Message()
    ..from = new Address('callum.clift@on-trac.co.uk', 'Accounts')
    ..recipients.add(email)
    ..subject = 'You have been registered as a user on Callums app'
    ..text = 'This is the plain text.\nThis is line 2 of the text part.'
    ..html = "<p>Dear "+ firstName +",</p>\n<p>You have been registered as a user on Callums app.</p>\n"
"<p>Please login using your email and temporary password below, please be sure to change the temporary password after you have logged in for the first time</p>\n"
"<p>Temporary password: "+ temporaryPassword +"</p>";

    await send(message, smtpServer);

  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},);

        Map<String, dynamic> responseData = json.decode(response.body);

        bool hasError = true;
        String message = 'Something went wrong!';

        Map<String, dynamic> userData;
        if (responseData.containsKey('idToken')) {
          message = 'authentication succeeded';

          DataSnapshot snapshot;

          snapshot = await FirebaseDatabase.instance
              .reference().child('users').orderByChild('email')
              .equalTo(email)
              .once();

          print('this is the snapshot');
          print(snapshot);


          userData = new Map.from(snapshot.value);

          userData.forEach((String key, dynamic value) {
            print(key);
            print(value['firstName']);
            _authenticatedUser = AuthenticatedUser(
                id: key,
                email: email,
                token: responseData['idToken'],
                suspended: value['suspended'],
                acceptedTerms: value['acceptedTerms'],
                hasTemporaryPassword: value['hasTemporaryPassword'],
                organisationId: 1,
                organisationName: value['organisation'],
                surname: value['surname'],
                firstName: value['firstName'],
                role: value['role'],
                authenticationId: value['authenticationId']);

            print('should not print this till after snapshot');
          });
          //this will trigger the listener in the main.dart for isAuthenticated
          if (_authenticatedUser.suspended == true) {
            print('at least it got here');
            message = 'your account has been suspended please contact your system admin';
          } else {
            hasError = false;
            setAuthTimeout(int.parse(responseData['expiresIn']));
            _userSubject.add(true);

            final DateTime now = DateTime.now();
            print('this is the time currently now' + now.toIso8601String());

            final DateTime expiryTime =
            now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
            print('this is the expiry time at the point of logging in' +
                expiryTime.toIso8601String());

            final SharedPreferences prefs = await SharedPreferences
                .getInstance();
            prefs.setString('id', _authenticatedUser.id);
            prefs.setString('email', _authenticatedUser.email);
            prefs.setString('token', _authenticatedUser.token);
            prefs.setBool('suspended', _authenticatedUser.suspended);
            prefs.setBool('acceptedTerms', _authenticatedUser.acceptedTerms);
            prefs.setBool('hasTemporaryPassword', _authenticatedUser.hasTemporaryPassword);
            prefs.setString('organisation', _authenticatedUser.organisationName);
            prefs.setString('surname', _authenticatedUser.surname);
            prefs.setString('firstName', _authenticatedUser.firstName);
            prefs.setString('role', _authenticatedUser.role);
            prefs.setString('authenticationId', _authenticatedUser.authenticationId);
            prefs.setString('expiryTime', expiryTime.toIso8601String());
          }
        }

         else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
          message = 'Email not found';
          //_authenticatedUser = User(id: '1234', email: email, password: password);
          //print('this is the email:' + currentUser.email);


        } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
          message = 'Incorrect password';

        }

    _isLoading = false;
    notifyListeners();
    print('ok so its here aswekk');
    print(message);
    return {'success': !hasError, 'message': message};
//_authenticatedUser = User(id: '1234', email: email, password: password);
//print('this is the email:' + currentUser.email);









}

  void autoLogin() async {
    print('entring auto login');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String token = await prefs.get('token');
    final String expiryTimeString = prefs.get('expiryTime');

    if (token != null) {
      final DateTime now = DateTime.now();
      print('this is the current time: ' + now.toIso8601String());
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      print('this is the expiry time: ' + parsedExpiryTime.toIso8601String());

      if (parsedExpiryTime.isBefore(now)) {
        print('yes its passed its expiry timeeeee');
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      print('no it has not passed its expiry timeeeee');
      final String id = await prefs.get('id');
      final String email = await prefs.get('email');
      final bool suspended = await prefs.get('suspended');
      final bool acceptedTerms = await prefs.get('acceptedTerms');
      final bool hasTemporaryPassword = await prefs.get('hasTemporaryPassword');
      final String organisation = await prefs.get('organisation');
      final String surname = await prefs.get('surname');
      final String firstName = await prefs.get('firstName');
      final String role = await prefs.get('role');
      final String authenticationId = await prefs.get('authenticationId');


      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      setAuthTimeout(tokenLifespan);
      print('this is the new lifespan:' + tokenLifespan.toString());

      _authenticatedUser = _authenticatedUser = AuthenticatedUser(
          id: id,
          email: email,
          token: token,
          suspended: suspended,
          acceptedTerms: acceptedTerms,
          hasTemporaryPassword: hasTemporaryPassword,
          organisationId: 1,
          organisationName: organisation,
          surname: surname,
          firstName: firstName,
          role: role,
          authenticationId: authenticationId);
      _userSubject.add(true);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;

    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
      //else signUp
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    Map<String, dynamic> responseData = json.decode(response.body);

    bool hasError = true;
    String message = 'Something went wrong!';

    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'authentication succeeded';
      _authenticatedUser = AuthenticatedUser(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      //this will trigger the listener in the main.dart for isAuthenticated
      _userSubject.add(true);

      final DateTime now = DateTime.now();
      print('this is the time currently now' + now.toIso8601String());

      final DateTime expiryTime =
      now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      print('this is the expiry time at the point of logging in' +
          expiryTime.toIso8601String());

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email not found';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Incorrect password';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
    //_authenticatedUser = User(id: '1234', email: email, password: password);
    //print('this is the email:' + currentUser.email);
  }

  void autoAuthenticate() async {
    print('entering auto authenticate');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String token = await prefs.get('token');
    final String expiryTimeString = prefs.get('expiryTime');

    if (token != null) {
      final DateTime now = DateTime.now();
      print('this is the current time: ' + now.toIso8601String());
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      print('this is the expiry time: ' + parsedExpiryTime.toIso8601String());

      if (parsedExpiryTime.isBefore(now)) {
        print('yes its passed its expiry timeeeee');
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      print('no it has not passed its expiry timeeeee');
      final String userEmail = await prefs.get('userEmail');
      final String userId = await prefs.get('userId');

      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      setAuthTimeout(tokenLifespan);
      print('this is the new lifespan:' + tokenLifespan.toString());

      _authenticatedUser = AuthenticatedUser(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      notifyListeners();
    }
  }

  void logout() async {
    print('logout happened');
    print('ive set auth user to null');
    _authTimer.cancel();
    _userSubject.add(false);
    _selProductId = null;
    _authenticatedUser = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    //prefs.remove('expiryTime');
  }

  void setAuthTimeout(int time) {
    print('this is the timer left in seconds: ' + time.toString());
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilitiesModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
