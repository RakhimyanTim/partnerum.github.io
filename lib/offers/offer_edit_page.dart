import 'package:partnerum/orders/get_city_name.dart';
import 'package:partnerum/orders/get_metro_name.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';



const kGoogleApiKey = "AIzaSyDtFvx7jVOFOyAxnD4yXBr0fZWMa3yW8gk";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);


class OfferEditPage extends StatefulWidget {

  final FirebaseUser user;
  final String offerId;

  OfferEditPage({ this.user, this.offerId});

  @override
  _OfferEditPageState createState() => _OfferEditPageState(
    user: this.user,
    offerId: this.offerId,
  );
}

class _OfferEditPageState extends State<OfferEditPage> {

  final FirebaseUser user;
  final String offerId;

  _OfferEditPageState({ this.user, this.offerId});

  final addressScaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _offerCityNameController = new TextEditingController();
  final TextEditingController _offerMetroNameController = new TextEditingController();
  final TextEditingController _offerAddressNameController = new TextEditingController();
  final TextEditingController _offerStartPriceController = new TextEditingController();
  final TextEditingController _offerEndPriceController = new TextEditingController();
  final TextEditingController _offerInfoController = new TextEditingController();

  int _startPrice;
  int _endPrice;

  List stations = [];
  String _distanceTime = '5';
  int _timeValue = 0;
  Prediction p;

  String _roomsCount = '1';
  int _roomsValue = 0;



  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('offers')
            .document(offerId)
            .snapshots(),
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
            appBar: _buildAppBar(),
            backgroundColor: Colors.white,
            body: _buildBody(document),
          );
        }
    );
  }

  Widget _buildBody(document) {
    return SingleChildScrollView(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildCity(document),
          _buildMetro(document),
          _buildDistance(document),
          _buildAddress(document),
          _buildPrice(document),
          _buildRooms(document),
          _buildInfo(document),
        ],
      ),
    );
  }

  Widget _buildInfo(document) {
    return new ListTile(
      leading: new Icon(Partnerum.info, color: Colors.black,),
      title: new TextFormField(
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        maxLines: 3,
        decoration: new InputDecoration(
          hintText: document['offerInfoField'] != '' ? '${document['offerInfoField']}' : 'Обновите дополнительную информацию',
          labelText: 'Дополнительная информация',
        ),
        controller: _offerInfoController,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          setState(() {
            _updateInfo();
          });
        },
      ),
    );
  }

  void _updateInfo() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "offerInfoField": _offerInfoController.text,
    });
  }

  Widget _buildRooms(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.guest, color: Colors.black,),
      title: new Text('Количество комнат - ${document['offerRoomsCount']}', style: new TextStyle(fontSize: 16, color: Colors.black), ),
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
      _updateRooms();
    });
  }

  void _updateRooms() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      'offerRoomsCount': _roomsCount,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "$_roomsCount комн.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  Widget _buildPrice(document) {
    return new ListTile(
      leading: new Icon(Partnerum.ruble, color: Colors.black,),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Flexible(child: _buildStartPrice(document)),
          new Flexible(child: _buildEndPrice(document)),
        ],
      ),
    );
  }

  Widget _buildStartPrice(document) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: new TextFormField(
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        keyboardType: TextInputType.number,
        inputFormatters: [new WhitelistingTextInputFormatter(
          new RegExp(r'^[()\d -]{1,15}$'),
        )],
        controller: _offerStartPriceController,
        decoration: InputDecoration(
          hintText: 'От ${document['offerStartPrice'].toString()}',
//        labelText: 'Цена (от)',
        ),
        onChanged: (value) {
          setState(() {
            _startPrice = int.parse(value);
            _updateStartPrice();
          });
        },

      ),
    );
  }

  Widget _buildEndPrice(document) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: new TextFormField(
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        keyboardType: TextInputType.number,
        inputFormatters: [new WhitelistingTextInputFormatter(
          new RegExp(r'^[()\d -]{1,15}$'),
        )],
        controller: _offerEndPriceController,
        decoration: InputDecoration(
          hintText: 'До ${document['offerEndPrice'].toString()}',
//          labelText: 'Цена (до)',
        ),
        onChanged: (value) {
          setState(() {
            _endPrice = int.parse(value);
            _updateEndPrice();
          });
        },

      ),
    );
  }

  void _updateStartPrice() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "offerStartPrice": _startPrice,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "$_startPrice руб",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  void _updateEndPrice() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "orderEndPrice": _endPrice,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "$_endPrice руб",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  Widget _buildAddress(document) {
    return new ListTile(
      leading: new Icon(Partnerum.address, color: Colors.black,),
      title: new InkWell(
        onTap: () => _getAddress(document),
        child: new IgnorePointer(
          child: new TextFormField(
            decoration: new InputDecoration(
              hintText: '${document['offerAddressName']}',
            ),
            controller: _offerAddressNameController,
          ),
        ),
      ),
    );
  }

  Future<void> _getAddress(document) async {
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
      _updateAddress();
    }
  }

  void _onError(PlacesAutocompleteResponse response) {
    addressScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  void _updateAddress() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "offerAddressName": _offerAddressNameController.text,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "${_offerAddressNameController.text}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  Widget _buildDistance(document) {
    return document['offerCityName'] == 'Москва' ? new ExpansionTile(
      leading: new Icon(Partnerum.walk, color: Colors.black,),
      title: new Text('Пешком до метро - ${document['offerDistanceTime']} мин',
        style: new TextStyle(fontSize: 16, color: Colors.black),
      ),
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
    ) : new Container();
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
      _updateDistance();
    });
  }

  void _updateDistance() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "offerDistanceTime": _distanceTime,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "$_distanceTime мин",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  Widget _buildMetro(document) {
    return document['offerCityName'] == 'Москва' ? new ListTile(
      leading: new Icon(Partnerum.metro, color: Colors.black,),
      title: new InkWell(
        child: new IgnorePointer(
          child: new TextFormField(
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            decoration: new InputDecoration(
              hintText: 'Станции метро (${document['offerMetroStantion'].length})',
            ),
            controller: _offerMetroNameController,
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

        _offerMetroNameController.text = 'Метро (${stations.length})';

        _updateMetro();

      },
    ) : new Container();
  }

  void _updateMetro() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "offerMetroStantion": stations,
    });
  }

  Widget _buildCity(document) {
    return new ListTile(
      leading: new Icon(Partnerum.city, color: Colors.black,),
      title: new InkWell(
        child: new IgnorePointer(
          child: new TextFormField(
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            decoration: new InputDecoration(
              hintText: '${document['offerCityName']}',
            ),
            controller: _offerCityNameController,
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
        _updateCity();
      },
    );
  }

  void _updateCity() {
    Firestore.instance
        .collection('offers')
        .document(offerId)
        .updateData({
      "offerCityName": _offerCityNameController.text,
    });
  }

  Widget _buildAppBar() {
    return new AppBar(
      leading: new IconButton(
        icon: Theme.of(context).platform == TargetPlatform.iOS
            ? new Icon(Icons.arrow_back_ios)
            : new Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: new Text('Редактирование'),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      centerTitle: false,
      textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          )
      ),
      backgroundColor: Colors.white,
    );
  }

}
