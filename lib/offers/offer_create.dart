import 'dart:async';
import 'dart:io';

import 'package:partnerum/orders/get_city_name.dart';
import 'package:partnerum/orders/get_metro_name.dart';
import 'package:partnerum/profile/edit_user_name.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:partnerum/tools/app_data.dart';
import 'package:partnerum/tools/app_tools.dart';
import 'package:partnerum/tools/firebase_methods.dart';



const kGoogleApiKey = "AIzaSyDtFvx7jVOFOyAxnD4yXBr0fZWMa3yW8gk";

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);


class OfferCreatePage extends StatefulWidget {

  final FirebaseUser user;

  OfferCreatePage({this.user});

  @override
  _OfferCreatePageState createState() => _OfferCreatePageState();
}

class _OfferCreatePageState extends State<OfferCreatePage> {

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  Map<int, File> imagesMap = new Map();

  final TextEditingController _offerCityNameController = new TextEditingController();
  final TextEditingController _offerMetroStationController = new TextEditingController();
  final TextEditingController _offerAddressNameController = new TextEditingController();
  final TextEditingController _offerStartPriceController = new TextEditingController();
  final TextEditingController _offerEndPriceController = new TextEditingController();
  final TextEditingController _offerInfoController = new TextEditingController();

  final dio = new Dio();
  String query = '';
  List<dynamic> metroStantionList = <dynamic>[];
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final addressScaffoldKey = GlobalKey<ScaffoldState>();
  Prediction p;
  int _startPrice;
  int _endPrice;
  Stream<DocumentSnapshot> _streamUser;
  List<File> imageList;
  List stations = [];
  String _distanceTime = '5';
  int _timeValue = 0;


  String _roomsCount = '1';
  int _roomsValue = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamUser = Firestore.instance
        .collection('users')
        .document(widget.user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: _streamUser,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return new Container(
            color: Colors.white,
            alignment: FractionalOffset.center,
            child: new Center(
              child: new Text('Ошибка: ${snapshot.error}'),
            ),
          );
        if (!snapshot.hasData)
          return new Container(
            color: Colors.white,
            alignment: FractionalOffset.center,
            child: new Center(
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoActivityIndicator()
                  : new CircularProgressIndicator(),
            ),
          );

        final document = snapshot.data;

        return new Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Новая квартира'),
            centerTitle: false,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),

            textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                )
            ),
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: new Form(
              key: _formKey,
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildAddBtn(),
                    new Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: MultiImagePickerList(
                        imageList: imageList,
                        removeNewImage: (index) {
                          removeImage(index);
                        },
                      ),
                    ),
                    _buildCity(),
                    _buildMetro(),
                    _buildDistance(),
                    _buildAddress(),
                    _buildPrice(),
                    _buildRooms(),
                    _buildInfo(),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: new FlatButton(
              child: new Text('ДОБАВИТЬ КВАРТИРУ', style: new TextStyle(color: Colors.white),),
              onPressed: () {
                addNewOffers(document);
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildInfo() {
    return new ListTile(
      leading: Icon(Partnerum.info, color: Colors.black,),
      title: new TextFormField(
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        maxLines: 3,
        decoration: new InputDecoration(
          hintText: 'Укажите дополнительную информацию',
          labelText: 'Дополнительная информация',
        ),
        controller: _offerInfoController,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildAddBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: new Container(
          height: 40,
          decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
              )
          ),
          child: new MaterialButton(
              onPressed: () => pickImage(),
              child: new Text("Добавить фото", style: new TextStyle(color: Colors.black),)
          ),
        ),
      ),
    );
  }

  pickImage() async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      //imagesMap[imagesMap.length] = file;
      List<File> imageFile = new List();
      imageFile.add(file);
      //imageList = new List.from(imageFile);
      if (imageList == null) {
        imageList = new List.from(imageFile, growable: true);
      } else {
        for (int s = 0; s < imageFile.length; s++) {
          imageList.add(file);
        }
      }
      setState(() {});
    }
  }

  removeImage(int index) async {
    //imagesMap.remove(index);
    imageList.removeAt(index);
    setState(() {});
  }

  Widget _buildRooms() {
    return new ExpansionTile(
      leading: new Icon(Partnerum.guest, color: Colors.black,),
      title: new Text('Количество комнат - $_roomsCount', style: new TextStyle(fontSize: 16, color: Colors.black), ),
      trailing: new Icon(Icons.arrow_drop_down, color: Colors.black,),
      children: <Widget>[
        new Center(
          child: SizedBox(
            height: 80.0,
            child: new ListView(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 0,
                      groupValue: _roomsValue,
                      onChanged: _handleGuestsCountValueChange,
                    ),
                    new Text('1'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 1,
                      groupValue: _roomsValue,
                      onChanged: _handleGuestsCountValueChange,
                    ),
                    new Text('2'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 2,
                      groupValue: _roomsValue,
                      onChanged: _handleGuestsCountValueChange,
                    ),
                    new Text('3'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 3,
                      groupValue: _roomsValue,
                      onChanged: _handleGuestsCountValueChange,
                    ),
                    new Text('4'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 4,
                      groupValue: _roomsValue,
                      onChanged: _handleGuestsCountValueChange,
                    ),
                    new Text('Более'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleGuestsCountValueChange(int value) {
    setState(() {
      _roomsValue = value;

      switch (_roomsValue) {
        case 0:
          _roomsCount = '1';
          break;
        case 1:
          _roomsCount = '2';
          break;
        case 2:
          _roomsCount = '3';
          break;
        case 3:
          _roomsCount = '4';
          break;
        case 4:
          _roomsCount = 'Более 4';
          break;
      }
    });
  }

  Widget _buildPrice() {
    return new ListTile(
      leading: new Icon(Partnerum.ruble, color:Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(child: _buildStartPrice()),
          Flexible(child: _buildEndPrice()),
        ],
      ),
    );
  }

  Widget _buildStartPrice() {
    return new TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [new WhitelistingTextInputFormatter(
        new RegExp(r'^[()\d -]{1,15}$'),
      )],
      controller: _offerStartPriceController,
      decoration: InputDecoration(
        labelText: 'Цена (от)',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Поле не должно быть пустым';
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          _startPrice = int.parse(value);
        });
      },

    );
  }

  Widget _buildEndPrice() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: new TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [new WhitelistingTextInputFormatter(
          new RegExp(r'^[()\d -]{1,15}$'),
        )],
        controller: _offerEndPriceController,
        decoration: InputDecoration(
//       icon: Icon(MyIcons.rouble),
          labelText: 'Цена (до)',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Поле не должно быть пустым';
          }
          return null;
        },
        onSaved: (value) {
          setState(() {
            _endPrice = int.parse(value);
          });
        },

      ),
    );
  }

  Widget _buildCity() {
    return new ListTile(
      leading: new Icon(Partnerum.city, color: Colors.black,),
      title: new InkWell(
        child: new IgnorePointer(
          child: new TextFormField(
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            decoration: new InputDecoration(
              hintText: 'Город',
            ),
            controller: _offerCityNameController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Обязательно';
              }
              return null;
            },
          ),

        ),
      ),
      onTap: () async {
        _offerCityNameController.text = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetCityName(),
          ),
        );
      },
    );
  }

  Widget _buildMetro() {
    return _offerCityNameController.text != 'Москва' ?  new Container() : new ListTile(
      leading: new Icon(Partnerum.metro, color: Colors.black,),
      title: new InkWell(
        child: new IgnorePointer(
          child: new TextFormField(
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            decoration: new InputDecoration(
              hintText: 'Метро',
            ),
            controller: _offerMetroStationController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Обязательно';
              }
              return null;
            },
          ),

        ),
      ),
      onTap: () async {

        stations = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetMetroName(),
          ),
        );

        _offerMetroStationController.text = 'Метро (${stations.length})';

      },
    );
  }

  Widget _buildDistance() {
    return _offerCityNameController.text != 'Москва' ? new Container() : new ExpansionTile(
      leading: new Icon(Partnerum.walk, color: Colors.black,),
      title: new Text('Пешком до метро - $_distanceTime мин', style: new TextStyle(fontSize: 16, color: Colors.black),),
      trailing: new Icon(Icons.arrow_drop_down, color: Colors.black,),
      children: <Widget>[
        new Center(
          child: SizedBox(
            height: 80.0,
            child: new ListView(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 0,
                      groupValue: _timeValue,
                      onChanged: _handleTimeValueChange,
                    ),
                    new Text('5'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 1,
                      groupValue: _timeValue,
                      onChanged: _handleTimeValueChange,
                    ),
                    new Text('10'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 2,
                      groupValue: _timeValue,
                      onChanged: _handleTimeValueChange,
                    ),
                    new Text('15'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 3,
                      groupValue: _timeValue,
                      onChanged: _handleTimeValueChange,
                    ),
                    new Text('20'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 4,
                      groupValue: _timeValue,
                      onChanged: _handleTimeValueChange,
                    ),
                    new Text('25'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleTimeValueChange(int value) {
    setState(() {
      _timeValue = value;

      switch (_timeValue) {
        case 0:
          _distanceTime = '5';
          break;
        case 1:
          _distanceTime = '10';
          break;
        case 2:
          _distanceTime = '15';
          break;
        case 3:
          _distanceTime = '20';
          break;
        case 4:
          _distanceTime = '25';
          break;
      }
    });
  }

  Widget _buildAddress() {
    return new ListTile(
      leading: new Icon(Partnerum.address, color: Colors.black,),
      title: new InkWell(
        onTap: () => _getAddress(),
        child: new IgnorePointer(
          child: new TextFormField(
            decoration: new InputDecoration(
              hintText: 'Адрес',
            ),
            controller: _offerAddressNameController,
          ),
        ),
      ),
    );
  }


  FirebaseMethods appMethod = new FirebaseMethods();

  addNewOffers(document) async{
    if (imageList == null || imageList.isEmpty) {
      showSnackBar("Загрузите фото", scaffoldKey);
      return;
    }

    if (_formKey.currentState.validate()) {
      displayProgressDialog(context);

      Map<String, dynamic> newProduct = {
        'userId': widget.user.uid,
        'timestamp': new DateTime.now().millisecondsSinceEpoch.toString(),
        'offerCityName': _offerCityNameController.text,
        'offerAddressName': _offerAddressNameController.text,
        'offerRoomsCount': _roomsCount,
        'offerDistanceTime': _distanceTime,
        'offerStartPrice': int.parse(_offerStartPriceController.text),
        'offerEndPrice': int.parse(_offerEndPriceController.text),
        'offerMetroStantion': stations,
        'offerInfoField': _offerInfoController.text,
        'isSwitched': true,
        'userName': document['userName'],
        'userImage': document['userImage'],
        'offerAccepts': {},
        'orderAccepts': {},
        'dealsCount': 0,
        'offerToken': document['pushToken'],
      };

      String offerId = await appMethod.addNewProduct(newProduct: newProduct);

      if (Platform.isIOS) {
        iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
          print(data);

          _saveOfferToken(offerId: offerId);

        });

        _fcm.requestNotificationPermissions(IosNotificationSettings());
      } else {

        _saveOfferToken(offerId: offerId);

      }

      List<String> imagesURL = await appMethod.uploadProductImages(docID: offerId, imageList: imageList);

      if (imagesURL.contains(error)) {
        closeProgressDialog(context);
        showSnackBar('Ошибка вовремя загрузки', scaffoldKey);
        return;
      }

      bool result = await appMethod.updateProductImages(docID: offerId, data: imagesURL);

      if (result != null && result == true) {
        closeProgressDialog(context);
        resetEverything();
        showSnackBar('Квартира добавлена', scaffoldKey);
        Fluttertoast.showToast(
          textColor: Colors.white,
          backgroundColor: Colors.black54,
          msg: "Квартира добавлена",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
        );
        Navigator.of(context).pop();
      } else {
        closeProgressDialog(context);
        showSnackBar('Ошибка. Мы уже работаем над ней', scaffoldKey);
      }
    }
  }

  void resetEverything() {
    imageList.clear();
    stations.clear();
    _offerCityNameController.text = '';
    _offerMetroStationController.text = '';
    _offerAddressNameController.text = '';
    _offerStartPriceController.text = '';
    _offerEndPriceController.text = '';
    _offerInfoController.text = '';
    setState(() {});
  }

  Future<void> _getAddress() async {
    p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: _onError,
      language: "ru",
      components: [Component(Component.country, "ru")],
    );

    displayPrediction(p, addressScaffoldKey.currentState);
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      _offerAddressNameController.text = p.description;
    }
  }

  void _onError(PlacesAutocompleteResponse response) {
    addressScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  // Get the token, save it to the database for current user
  _saveOfferToken({String offerId}) async {

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var token = _db
          .collection('offers')
          .document('offerId');

      await token.updateData({
        'offerToken': fcmToken,
      });
    }
  }

}


