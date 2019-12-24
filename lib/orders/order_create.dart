import 'dart:async';
import 'dart:io';
import 'package:partnerum/orders/get_city_name.dart';
import 'package:partnerum/orders/get_metro_name.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

class OrderCreate extends StatefulWidget {

  final FirebaseUser user;

  OrderCreate({this.user});

  @override
  _OrderCreateState createState() => _OrderCreateState(
    user: this.user,
  );
}

class _OrderCreateState extends State<OrderCreate> {

  final FirebaseUser user;

  _OrderCreateState({this.user});

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  final _formKey = GlobalKey<FormState>();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _orderArrivelDateController = new TextEditingController();
  final TextEditingController _orderDepartureDateController = new TextEditingController();
  final TextEditingController _orderCityNameController = new TextEditingController();
  final TextEditingController _orderMetroNameController = new TextEditingController();
  final TextEditingController _orderMetroStationController = new TextEditingController();
  final TextEditingController _orderStartPriceController = new TextEditingController();
  final TextEditingController _orderEndPriceController = new TextEditingController();
  final TextEditingController _orderInfoFieldController = new TextEditingController();
  final TextEditingController _orderCustomerPhoneController = new TextEditingController();

  final dio = new Dio();

  String query = '';

  int _startPrice;

  int _endPrice;

  String _phoneNumber;

  String searchString;

  String _distanceTime = '5';
  int _timeValue = 0;

  String _roomsCount = '1';
  int _countValue = 0;

  String _guestsCount = '1';
  int _guestsValue = 0;

  String _comissionSize = '10';
  int _comissionValue = 0;

  List roomsList = ['1'];
  bool roomSelected = false;

  List stations = [];

  List<DateTime> pickedList = [];

  Stream<DocumentSnapshot> _streamUser;

  SharedPreferences prefs;
  String userImage = '';
  bool isLoading = false;
  File file;

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
          .collection('users')
          .document(user.uid)
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
          key: _scaffoldKey,
          appBar: new AppBar(
            leading: new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () => resetEverything(),
            ),

            title: new Text('Новая заявка'),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
            ),
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: new Form(
              key: _formKey,
              child: new ListView(
                children: <Widget>[
                  _buildCityName(),
                  _orderCityNameController.text != 'Москва'
                      ? new Container()
                      : _buildMetroName(),

                  new Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0,),
                    child: _orderCityNameController.text != 'Москва'
                        ? new Container()
                        : _buildDistanceTime(),
                  ),

                  new Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0,),
                    child: _buildRoomsCount(),
                  ),

                  new Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0,),
                    child: _buildGuestsCount(),
                  ),
                  _buildDate(),

                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(child: _buildStartPriceField()),
                        Flexible(child: _buildEndPriceField()),
                      ],
                    ),
                  ),

                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildCustomerPhoneField(),
                  ),

                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildInfoField(),
                  ),

                  _buildComissionSize(),

                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: new FlatButton(
              child: new Text('ДОБАВИТЬ ЗАЯВКУ', style: new TextStyle(color: Colors.white),),
              onPressed: () {
                if (_formKey.currentState.validate()) {

                  _addNewOrder(document);

                  Navigator.of(context).pop();

                  Fluttertoast.showToast(
                    textColor: Colors.white,
                    backgroundColor: Colors.black54,
                    msg: "Заявка добавлена",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                  );
                }
              },
            ),
          ),
        );
      }
    );
  }

  Widget _buildCityName() {
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
            controller: _orderCityNameController,
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
        _orderCityNameController.text = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetCityName(),
          ),
        );
      },
    );
  }

  Widget _buildMetroName() {
    return new ListTile(
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
            controller: _orderMetroNameController,
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

        _orderMetroNameController.text = 'Метро (${stations.length})';

      },
    );
  }

  Widget _buildDistanceTime() {
    return new ExpansionTile(
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

  Widget _buildRoomsCount() {
    return new ExpansionTile(
      leading: new Icon(Partnerum.rooms, color: Colors.black,),
      title: roomsList.length != 0 ? new Text('Количество комнат - ${roomsList.toString().replaceAll('[', '').replaceAll(']', '')}', style: new TextStyle(fontSize: 16, color: Colors.black),) :
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
                          } else {
                            roomsList.remove('2');
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
                          } else {
                            roomsList.remove('3');
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
                          } else {
                            roomsList.remove('4');
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
                          } else {
                            roomsList.remove('Неважно');
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

  Widget _buildGuestsCount() {
    return new ExpansionTile(
      leading: new Icon(Partnerum.guest, color: Colors.black,),
      title: new Text('Количество гостей - $_guestsCount', style: new TextStyle(fontSize: 16, color: Colors.black), ),
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
    });
  }

  Widget _buildComissionSize() {
    return new ExpansionTile(
      leading: new Icon(Partnerum.percent, color: Colors.black,),
      title: new Text('Размер комиссии - $_comissionSize %', style: new TextStyle(fontSize: 16, color: Colors.black),),
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
    });
  }

  Widget _buildStartPriceField() {
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
//        hintText: 'Цену',
        labelText: 'Цена (от)',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Обязательно';
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

  Widget _buildEndPriceField() {
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
//       icon: Icon(MyIcons.rouble),
//          hintText: '4200',
          labelText: 'Цена (до)',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Обязательно';
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

  Widget _buildDate() {
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
                },
                child: new Text("Выбрать даты", style: new TextStyle(color: Colors.black),)
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
                        hintText: 'Заезд',
                      ),
                      controller: _orderArrivelDateController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Обязательно';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                new Flexible(
                  child: new IgnorePointer(
                    child: new TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Выезд',
                      ),
                      controller: _orderDepartureDateController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Обязательно';
                        }
                        return null;
                      },
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

  Widget _buildCustomerPhoneField() {
    return new TextFormField(
      onFieldSubmitted: (term) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      keyboardType: TextInputType.phone,
      inputFormatters: [new WhitelistingTextInputFormatter(
        new RegExp(r'^[()\d -]{1,15}$'),
      )],
      controller: _orderCustomerPhoneController,
      decoration: InputDecoration(
        icon: Icon(Partnerum.phone, color: Colors.black,),
        hintText: 'Введите телефон заказчика',
        labelText: 'Телефон',
        suffixIcon: IconButton(
          icon: new Icon(Icons.help_outline,),
          onPressed: () {
            _displaySnackBar(context);
            print('onPressed SnackBar');
          },
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Обязательно';
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          _phoneNumber = value;
        });
      },

    );
  }

  Widget _buildInfoField() {
    return new TextFormField(
      onFieldSubmitted: (term) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      maxLines: 3,
      decoration: new InputDecoration(
        icon: const Icon(Partnerum.info, color: Colors.black,),
        hintText: 'Укажите дополнительную информацию',
        labelText: 'Дополнительная информация',
      ),
      controller: _orderInfoFieldController,
      keyboardType: TextInputType.text,
    );
  }

  void _addNewOrder(document) {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveWithOrderToken(document);
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveWithOrderToken(document);
    }
  }

  void resetEverything() {
    _orderArrivelDateController.text = '';
    _orderDepartureDateController.text = '';
    _orderCityNameController.text = '';
    _orderMetroStationController.text = '';
    _orderStartPriceController.text = '';
    _orderStartPriceController.text = '';
    _orderCustomerPhoneController.text = '';
    _orderInfoFieldController.text = '';
    roomsList.clear();
    pickedList.clear();

    setState(() {
      Navigator.of(context).pop();
    });
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Телефон будет виден арендодателю только после того, как вы договоритесь'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _saveWithOrderToken(document) async {
    String fcmToken = await _fcm.getToken();

    CollectionReference reference = Firestore.instance.collection('orders');

    await reference.add({
      'timestamp' : new DateTime.now().millisecondsSinceEpoch.toString(),
      'orderArrivelDate': pickedList[0],
      'orderDepartureDate': pickedList[1],
      'arrivel': DateFormat('dd MMM', 'ru').format(pickedList[0]).toString(),
      'departure': DateFormat('dd MMM', 'ru').format(pickedList[1]).toString(),
      'orderCityName': _orderCityNameController.text,
      'orderStationsList': stations,
      'orderStartPrice': int.parse(_orderStartPriceController.text),
      'orderEndPrice': int.parse(_orderEndPriceController.text),
      'orderCustomerPhone': _orderCustomerPhoneController.text,
      'orderInfoField': _orderInfoFieldController.text,
      'orderDistanceTime': _distanceTime,
      'orderRoomsList': roomsList,
      'orderComissionSize': _comissionSize,
      'isSwitched': true,
      'userId': user.uid,
      'userName': document['userName'],
      'userImage': document['userImage'],
      'orderAccepts': {},
      'offerAccepts': {},
      'orderToken': fcmToken,
      'orderGuestsCount': _guestsCount,

    }).then((DocumentReference doc) {
      String docId = doc.documentID;
      reference.document(docId).updateData({'orderId': docId});
    });
    resetEverything();
  }

}

