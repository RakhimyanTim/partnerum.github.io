import 'package:partnerum/orders/get_city_name.dart';
import 'package:partnerum/orders/get_metro_name.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:intl/date_symbol_data_local.dart';



class OrderEditPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot order;
  const OrderEditPage({this.user, this.order});

  @override
  _OrderEditPageState createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _orderCityNameController = new TextEditingController();
  final TextEditingController _orderMetroNameController = new TextEditingController();
  final TextEditingController _orderStartPriceController = new TextEditingController();
  final TextEditingController _orderEndPriceController = new TextEditingController();
  final TextEditingController _orderArrivelDateController = new TextEditingController();
  final TextEditingController _orderDepartureDateController = new TextEditingController();
  final TextEditingController _orderCustomerPhoneController = new TextEditingController();
  final TextEditingController _orderInfoController = new TextEditingController();

  int _startPrice;
  int _endPrice;
  String _phoneNumber;
  String _orderId;

  List stations = [];
  List pickedList = [];
  List roomsList = ['1'];

  String _distanceTime = '5';
  int _timeValue = 0;
  bool roomSelected = false;
  String _guestsCount = '1';
  int _guestsValue = 0;
  String _comissionSize = '10';
  int _comissionValue = 0;

  DateFormat formatDates;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('orders')
            .document(widget.order['orderId'])
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

          _orderId = document['orderId'];

          return new Scaffold(
            appBar: new AppBar(
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

              textTheme: TextTheme(
                  title: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  )
              ),
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  _buildDate(document),
                  _buildCityName(document),
                  _buildMetroStations(document),
                  _buildDistanceTime(document),
                  _buildPrice(document),
                  _buildRooms(document),
                  _buildGuests(document),
                  _buildPhone(document),
                  _buildComission(document),
                  _buildInfo(document),
                ],
              ),
            ),
          );
        }
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
          hintText: document['orderInfoField'] != '' ? '${document['orderInfoField']}' : 'Обновите дополнительную информацию',
          labelText: 'Дополнительная информация',
        ),
        controller: _orderInfoController,
        keyboardType: TextInputType.text,
        onChanged: (value) {
          setState(() {
            _updateInfo();
          });
        },
      ),
    );
  }

  Widget _buildComission(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.percent, color: Colors.black,),
      title: new Text('Размер комиссии - ${document['orderComissionSize']} %', style: new TextStyle(fontSize: 16, color: Colors.black),),
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
                      groupValue: _comissionValue,
                      onChanged: _handleComissionValueChange,
                    ),
                    new Text('10'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 1,
                      groupValue: _comissionValue,
                      onChanged: _handleComissionValueChange,
                    ),
                    new Text('15'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 2,
                      groupValue: _comissionValue,
                      onChanged: _handleComissionValueChange,
                    ),
                    new Text('20'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Radio(
                      activeColor: Theme.of(context).primaryColor,
                      value: 3,
                      groupValue: _comissionValue,
                      onChanged: _handleComissionValueChange,
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

  void _handleComissionValueChange(int value) {
    setState(() {
      _comissionValue = value;

      switch (_comissionValue) {
        case 0:
          _comissionSize = '10';
          break;
        case 1:
          _comissionSize = '15';
          break;
        case 2:
          _comissionSize = '20';
          break;
        case 3:
          _comissionSize = '25';
          break;
      }
      _updateComission();
    });
  }

  Widget _buildPhone(document) {
    return new ListTile(
      leading: Icon(Partnerum.phone, color: Colors.black,),
      title: new TextFormField(
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        keyboardType: TextInputType.phone,
        inputFormatters: [new WhitelistingTextInputFormatter(
          new RegExp(r'^[()\d -]{1,15}$'),
        )],
        controller: _orderCustomerPhoneController,
        decoration: InputDecoration(
          hintText: '${document['orderCustomerPhone']}',
          labelText: 'Телефон заказчика',
        ),
        onChanged: (value) {
          setState(() {
            _phoneNumber = value;
            _updatePhone();
          });
        },

      ),
      trailing: IconButton(
        icon: new Icon(Icons.help_outline,),
        onPressed: () {
          _displaySnackBar(context);
        },
      ),
    );
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Телефон будет виден арендодателю только после того, как вы договоритесь'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget _buildGuests(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.guest, color: Colors.black,),
      title: new Text('Количество гостей - ${document['orderGuestsCount']}', style: new TextStyle(fontSize: 16, color: Colors.black), ),
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
                      groupValue: _guestsValue,
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
                      groupValue: _guestsValue,
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
                      groupValue: _guestsValue,
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
                      groupValue: _guestsValue,
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
                      groupValue: _guestsValue,
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
      _guestsValue = value;

      switch (_guestsValue) {
        case 0:
          _guestsCount = '1';
          break;
        case 1:
          _guestsCount = '2';
          break;
        case 2:
          _guestsCount = '3';
          break;
        case 3:
          _guestsCount = '4';
          break;
        case 4:
          _guestsCount = 'Более 4';
          break;
      }
      _updateGuests();
    });
  }

  Widget _buildRooms(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.rooms, color: Colors.black,),
      title: roomsList.length != 0 ? new Text('Количество комнат - ${document['orderRoomsList'].toString().replaceAll('[', '').replaceAll(']', '')}', style: new TextStyle(fontSize: 16, color: Colors.black),) :
      new Text('Количество комнат - 0', style: new TextStyle(fontSize: 16, color: Colors.black),),
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
                    new Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: roomsList.contains('1'),
                      onChanged: (bool val) {
                        setState(() {
                          if (val) {
                            roomsList.add('1');
                            _updateRooms();
                          } else {
                            roomsList.remove('1');
                          }
                          roomSelected = val;
                        },
                        );
                      },
                    ),
                    new Text('1'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: roomsList.contains('2'),
                      onChanged: (bool val) {
                        setState(() {
                          if (val) {
                            roomsList.add('2');
                            _updateRooms();
                          } else {
                            roomsList.remove('2');
                            _updateRooms();
                          }
                          roomSelected = val;
                        },
                        );
                      },
                    ),
                    new Text('2'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: roomsList.contains('3'),
                      onChanged: (bool val) {
                        setState(() {
                          if (val) {
                            roomsList.add('3');
                            _updateRooms();
                          } else {
                            roomsList.remove('3');
                            _updateRooms();
                          }
                          roomSelected = val;
                        },
                        );
                      },
                    ),
                    new Text('3'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: roomsList.contains('4'),
                      onChanged: (bool val) {
                        setState(() {
                          if (val) {
                            roomsList.add('4');
                            _updateRooms();
                          } else {
                            roomsList.remove('4');
                            _updateRooms();
                          }
                          roomSelected = val;
                        },
                        );
                      },
                    ),
                    new Text('4'),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: roomsList.contains('Неважно'),
                      onChanged: (bool val) {
                        setState(() {
                          if (val) {
                            roomsList.add('Неважно');
                            _updateRooms();
                          } else {
                            roomsList.remove('Неважно');
                            _updateRooms();
                          }
                          roomSelected = val;
                        },
                        );
                      },
                    ),
                    new Text('Неважно'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDate(document) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                )
            ),
            child: new MaterialButton(
                onPressed: () async {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  pickedList = await DateRagePicker.showDatePicker(
                      context: context,
                      initialFirstDate: new DateTime.now(),
                      initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
                      firstDate: new DateTime(2015),
                      lastDate: new DateTime(2020)
                  );
                  if (pickedList != null && pickedList.length == 2) {
                    _orderArrivelDateController.text = DateFormat('dd MMM', 'ru').format(pickedList[0]).toString();
                    _orderDepartureDateController.text = DateFormat('dd MMM', 'ru').format(pickedList[1]).toString();
                  }
                  _updateDate();
                },
                child: new Text("Изменить даты", style: new TextStyle(color: Colors.black),)
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 58,),
            child: new Row(
              children: <Widget>[
                new Flexible(
                  child: new IgnorePointer(
                    child: new TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '${DateFormat('dd MMM').format(document['orderArrivelDate'].toDate()).toString()}',
                      ),
                      controller: _orderArrivelDateController,
                    ),
                  ),
                ),
                new Flexible(
                  child: new IgnorePointer(
                    child: new TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '${DateFormat('dd MMM').format(document['orderDepartureDate'].toDate()).toString()}',
                      ),
                      controller: _orderDepartureDateController,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice(document) {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(child: _buildStartPrice(document)),
          Flexible(child: _buildEndPrice(document)),
        ],
      ),
    );
  }

  Widget _buildStartPrice(document) {
    return new TextFormField(
      onFieldSubmitted: (term) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      keyboardType: TextInputType.number,
      inputFormatters: [new WhitelistingTextInputFormatter(
        new RegExp(r'^[()\d -]{1,15}$'),
      )],
      controller: _orderStartPriceController,
      decoration: InputDecoration(
        icon: Icon(Partnerum.ruble, color: Colors.black,),
        hintText: 'От ${document['orderStartPrice'].toString()}',
//        labelText: 'Цена (от)',
      ),
      onChanged: (value) {
        setState(() {
          _startPrice = int.parse(value);
          _updateStartPrice();
        });
      },

    );
  }

  Widget _buildEndPrice(document) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: new TextFormField(
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        keyboardType: TextInputType.number,
        inputFormatters: [new WhitelistingTextInputFormatter(
          new RegExp(r'^[()\d -]{1,15}$'),
        )],
        controller: _orderEndPriceController,
        decoration: InputDecoration(
          hintText: 'До ${document['orderEndPrice'].toString()}',
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

  Widget _buildDistanceTime(document) {
    return document['orderCityName'] != 'Москва' ? new Container() :
    new ExpansionTile(
      leading: new Icon(Partnerum.walk, color: Colors.black,),
      title: new Text('Пешком до метро - ${document['orderDistanceTime']} мин', style: new TextStyle(fontSize: 16, color: Colors.black),),
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
      _updateDistanceTime();
    });
  }

  Widget _buildMetroStations(document) {
    return document['orderCityName'] != 'Москва' ? new Container() : new ListTile(
      leading: new Icon(Partnerum.metro, color: Colors.black,),
      title: new InkWell(
        child: new IgnorePointer(
          child: new TextFormField(
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            decoration: new InputDecoration(
              hintText: 'Станции метро (${document['orderStationsList'].length})',
            ),
            controller: _orderMetroNameController,
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

        _orderMetroNameController.text = 'Метро (${stations.length})';

        _updateMetro();

      },
    );
  }

  Widget _buildCityName(document) {
    return new ListTile(
      leading: new Icon(Partnerum.city, color: Colors.black,),
      title: new InkWell(
        child: new IgnorePointer(
          child: new TextFormField(
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            decoration: new InputDecoration(
              hintText: '${document['orderCityName']}',
            ),
            controller: _orderCityNameController,
          ),
        ),
      ),
      onTap: () async {
        _orderCityNameController.text = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetCityName(),
          ),
        );
        _updateCityName();
      },
    );
  }

  void _updateCityName() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      "orderCityName": _orderCityNameController.text,
    });
  }

  void _updateInfo() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      "orderInfoField": _orderInfoController.text,
    });
  }

  void _updateMetro() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      "orderStationsList": stations,
    });
  }

  void _updateDistanceTime() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      "orderDistanceTime": _distanceTime,
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

  void _updateGuests() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      "orderGuestsCount": _guestsCount,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "$_guestsCount чел",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  void _updateStartPrice() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      "orderStartPrice": _startPrice,
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
        .collection('orders')
        .document(_orderId)
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

  void _updatePhone() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      'orderCustomerPhone': _orderCustomerPhoneController.text,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "${_orderCustomerPhoneController.text}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  void _updateDate() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      'orderArrivelDate': pickedList[0],
      'orderDepartureDate': pickedList[1],
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "${_orderArrivelDateController.text} - ${_orderDepartureDateController.text}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  void _updateComission() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      'orderComissionSize': _comissionSize,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "Комиссия - $_comissionSize %",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  void _updateRooms() {
    Firestore.instance
        .collection('orders')
        .document(_orderId)
        .updateData({
      'orderRoomsList': roomsList,
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black54,
      msg: "${roomsList.toString().replaceAll('[', '').replaceAll(']', '')}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  Widget _buildArrivelDate({arrivelDate}) {
    return new ListTile(
      title: new IgnorePointer(
        child: new TextFormField(
          decoration: new InputDecoration(
//            hintText: arrivelDate,
            icon: new Icon(Icons.today),
          ),
        ),
      ),
      trailing: new FlatButton(
        onPressed: () {
          _selectArrivelDate();
        },
        child: new Text('Изменить', style: new TextStyle(color: Colors.blue),),
      ),
    );
  }
  _selectArrivelDate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2023, 1, 1),
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          if (new DateFormat('MMM').format(date) == 'Jan') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' янв';
          } else if (new DateFormat('MMM').format(date) == 'Feb') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' фев';
          } else if (new DateFormat('MMM').format(date) == 'Mar') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' мар';
          } else if (new DateFormat('MMM').format(date) == 'Apr') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' апр';
          } else if (new DateFormat('MMM').format(date) == 'May') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' май';
          } else if (new DateFormat('MMM').format(date) == 'Jun') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' июн';
          } else if (new DateFormat('MMM').format(date) == 'Jul') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' июл';
          } else if (new DateFormat('MMM').format(date) == 'Aug') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' авг';
          } else if (new DateFormat('MMM').format(date) == 'Sep') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' сен';
          } else if (new DateFormat('MMM').format(date) == 'Oct') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' окт';
          } else if (new DateFormat('MMM').format(date) == 'Nov') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' нов';
          } else if (new DateFormat('MMM').format(date) == 'Dec') {
            _orderArrivelDateController.text = new DateFormat('d').format(date) + ' дек';
          }
          Firestore.instance
              .collection('orders')
              .document(widget.order['orderId'])
              .updateData({
            "orderArrivelDate": _orderArrivelDateController.text,
          });
          Fluttertoast.showToast(
            textColor: Colors.black,
            backgroundColor: Colors.black.withOpacity(0.1),
            msg: "Изменения сохранены",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
          );
        });
      },
      currentTime: DateTime.now(), locale: LocaleType.ru,

    );
  }

  Widget _buildDepartureDate({departureDate}) {
    return new ListTile(
      title: new IgnorePointer(
        child: new TextFormField(
          decoration: new InputDecoration(
//            hintText: departureDate,
            icon: new Icon(Icons.today),
          ),
        ),
      ),
      trailing: new FlatButton(
        onPressed: () {
          _selectDepartureDate();
        },
        child: new Text('Изменить', style: new TextStyle(color: Colors.blue),),
      ),
    );
  }
  _selectDepartureDate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2023, 1, 1),
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          if (new DateFormat('MMM').format(date) == 'Jan') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' янв';
          } else if (new DateFormat('MMM').format(date) == 'Feb') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' фев';
          } else if (new DateFormat('MMM').format(date) == 'Mar') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' мар';
          } else if (new DateFormat('MMM').format(date) == 'Apr') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' апр';
          } else if (new DateFormat('MMM').format(date) == 'May') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' май';
          } else if (new DateFormat('MMM').format(date) == 'Jun') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' июн';
          } else if (new DateFormat('MMM').format(date) == 'Jul') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' июл';
          } else if (new DateFormat('MMM').format(date) == 'Aug') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' авг';
          } else if (new DateFormat('MMM').format(date) == 'Sep') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' сен';
          } else if (new DateFormat('MMM').format(date) == 'Oct') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' окт';
          } else if (new DateFormat('MMM').format(date) == 'Nov') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' нов';
          } else if (new DateFormat('MMM').format(date) == 'Dec') {
            _orderDepartureDateController.text = new DateFormat('d').format(date) + ' дек';
          }
          Firestore.instance
              .collection('orders')
              .document(widget.order['orderId'])
              .updateData({
            "orderDepartureDate": _orderDepartureDateController.text,
          });
          Fluttertoast.showToast(
            textColor: Colors.black,
            backgroundColor: Colors.black.withOpacity(0.1),
            msg: "Изменения сохранены",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
          );
        });
      },
      currentTime: DateTime.now(), locale: LocaleType.ru,

    );
  }


  Widget _buildCustomerPhoneField({String customerPhone}) {
    return new ListTile(
      title: new IgnorePointer(
        child: new TextFormField(
          decoration: new InputDecoration(
            hintText: customerPhone,
            icon: new Icon(Icons.phone),
          ),
        ),
      ),
      trailing: new FlatButton(
        onPressed: () {
          _customerPhoneInputDialog(context);
        },
        child: new Text('Изменить', style: new TextStyle(color: Colors.blue),),
      ),
    );
  }

  Future<String> _customerPhoneInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Введите телефон клиента'),
          content: new TextFormField(
            keyboardType: TextInputType.phone,
            inputFormatters: [new WhitelistingTextInputFormatter(
              new RegExp(r'^[()\d -]{1,15}$'),
            )],
            controller: _orderCustomerPhoneController,
            onSaved: (value) {
              setState(() {
                _phoneNumber = value;
              });
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Сохранить'),
              onPressed: () {
                Firestore.instance
                    .collection('orders')
                    .document(widget.order['orderId'])
                    .updateData({
                  "orderCustomerPhone": _orderCustomerPhoneController.text,
                });
                Fluttertoast.showToast(
                  textColor: Colors.black,
                  backgroundColor: Colors.black.withOpacity(0.1),
                  msg: "Изменения сохранены",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIos: 1,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}


