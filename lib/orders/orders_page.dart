import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:partnerum/orders/order_create.dart';
import 'package:partnerum/orders/order_detail.dart';
import 'package:partnerum/orders/order_offers_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class OrdersPage extends StatefulWidget {

  final FirebaseUser user;

  OrdersPage({this.user});

  @override
  _OrdersPageState createState() => _OrdersPageState(
    user: this.user,
  );
}

class _OrdersPageState extends State<OrdersPage> {

  final FirebaseUser user;

  _OrdersPageState({this.user});

  List<dynamic> tagList = <dynamic>[];

  bool isSwitched = true;

  final _activeForm = GlobalKey<FormState>();
  final _noActiveForm = GlobalKey<FormState>();

  Map<int, Widget> children = <int, Widget>{
    0: Text("Активные", style: new TextStyle(fontSize: 16),),
    1: Text("Не активные", style: new TextStyle(fontSize: 16),),
  };

  getChildren() {
    return <int, Widget>{
      0: Form(
        key: _activeForm,
        child: _buildActive(),
      ),
      1: Form(
        key: _noActiveForm,
        child: _buildNoActive(),
      ),
    };
  }

  int _sharedValue = 0;

  DateFormat formatDates;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: _buildTabs(),
    );
  }

  Widget _buildOrderItem(BuildContext context, DocumentSnapshot document) {
    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildDate(document),
                _buildSwitch(document),
              ],
            ),
            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildCity(document),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildMetro(document),
                  ],
                ),
                _buildPrice(document),
//                _buildGuests(document),
//                _buildRooms(document),
              ],
            ),
          ),
          _buildBtns(document),
        ],
      ),
    );
  }

  Widget _buildBtns(document) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new FlatButton(
          onPressed: () {
            document['isSwitched'] != true ? new Container() : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  user: user,
                  orderId: document['orderId'],
                ),
              ),
            );
          },
          child: new Text('Подробнее',
            style: new TextStyle(color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.black, fontSize: 16),
          ),
        ),
        new FlatButton(
          onPressed: () {
            document['isSwitched'] != true ? new Container() : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderOffersListPage(
                  user: user,
                  orderId: document['orderId'],
                ),
              ),
            );
          },
          child: new Text(document['offerAccepts'].length == 0 ? 'Предложения' : 'Предложения ' + '(${document['offerAccepts'].length.toString()})',
            style: new TextStyle(color: document['isSwitched']  != true ? Color(0xFFE7E7E7) : Theme.of(context).primaryColor, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(document) {
    return new Row(
      children: <Widget>[
        new Icon(Partnerum.ruble, color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey, size: 14,),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Text(
            'От ${document['orderStartPrice'].toString()} до ${document['orderEndPrice'].toString()} руб/сут',
            style: new TextStyle(
              fontSize: 14,
              color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetro(document) {
    return document['orderCityName'] == 'Москва' ? new SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Icon(Partnerum.metro, color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey, size: 14,),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: new Container(
              height: 16,
              child: new ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: document['orderStationsList'].length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new Text(
                    '${document['orderStationsList'][index]} ',
                    style: new TextStyle(fontSize: 14, color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey,),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ) : new Container();
  }

  Widget _buildCity(document) {
    return new Row(
      children: <Widget>[
        new Icon(Partnerum.city, color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey, size: 14,),
        new Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Text(
            '${document['orderCityName']}',
            style: new TextStyle(fontSize: 14, color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey,),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(document) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[

        Switch(
          activeColor: Theme.of(context).primaryColor,
          value: document['isSwitched'],
          onChanged: (value) {

            setState(() {
              isSwitched = value;
            });

            Firestore.instance
                .collection('orders')
                .document(document['orderId'])
                .updateData({
              "isSwitched": isSwitched,
            });

            document['isSwitched'] != true ?  Fluttertoast.showToast(
              textColor: Colors.white,
              backgroundColor: Colors.black54,
              msg: "Заявка выключена",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
            ) : Fluttertoast.showToast(
              textColor: Colors.white,
              backgroundColor: Colors.black54,
              msg: "Заявка выключена",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIos: 1,
            );

          },
        ),
      ],
    );
  }

  Widget _buildDate(document) {
    return new Text(
      '${DateFormat('dd MMM', 'ru').format(document['orderArrivelDate'].toDate()).toString()} - ${DateFormat('dd MMM', 'ru').format(document['orderDepartureDate'].toDate()).toString()}',
      style: new TextStyle(
        fontSize: 16,
        color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRooms(document) {
    return new SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Icon(Partnerum.metro, color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey, size: 14,),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: new Container(
              height: 16,
              child: new ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: document['orderRoomsList'].length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new Text(
                    '${document['orderRoomsList'][index]}, ',
                    style: new TextStyle(fontSize: 14, color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey,),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuests(document) {
    return new Row(
      children: <Widget>[
        new Icon(Partnerum.guest, color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey, size: 14,),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Text(
            '${document['orderGuestsCount']} чел',
            style: new TextStyle(
              fontSize: 14,
              color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZeroOrders() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: new Container(
          width: 300,
          height: 300,
          child: new SvgPicture.asset(
              'assets/images/zero_orders.svg',
              semanticsLabel: 'Zero orders'
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: new Text(
        'Продать заявку',
        style: new TextStyle(fontSize: 20),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),

      textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          )
      ),
      actions: <Widget>[
        _buildAction(user),
      ],
      backgroundColor: Colors.white,
    );
  }

  Widget _buildOnWork() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('isSwitched', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
              alignment: FractionalOffset.center,
              child: Center(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoActivityIndicator()
                      : new CircularProgressIndicator()
              ),
            );
          if (snapshot.data.documents.length == 0) {
            return new Container(
              margin: new EdgeInsets.all(20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildZeroOrders(),
                  new Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: new Text(
                      'Здесь будут показаны ваши заявки. Добавляйте заявки, чтобы получать комиссию со сделок.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 14.0,),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return new ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildOrderItem(context, snapshot.data.documents[index], ),
            );
          }
        }
    );
  }

  Widget _buildActive() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('isSwitched', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
              alignment: FractionalOffset.center,
              child: Center(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoActivityIndicator()
                      : new CircularProgressIndicator()
              ),
            );
          if (snapshot.data.documents.length == 0) {
            return new Container(
              margin: new EdgeInsets.all(20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildZeroOrders(),
                  new Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: new Text(
                      'Здесь будут показаны ваши заявки. Добавляйте заявки, чтобы получать комиссию со сделок.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 14.0,),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return new ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildOrderItem(context, snapshot.data.documents[index], ),
            );
          }
        }
    );
  }

  Widget _buildNoActive() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('isSwitched', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
              alignment: FractionalOffset.center,
              child: Center(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoActivityIndicator()
                      : new CircularProgressIndicator()
              ),
            );
          if (snapshot.data.documents.length == 0) {
            return new Container(
              margin: new EdgeInsets.all(20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildZeroOrders(),
                  new Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: new Text(
                      'Здесь будут показаны ваши заявки. Добавляйте заявки, чтобы получать комиссию со сделок.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 14.0,),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return new ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) => _buildOrderItem(context, snapshot.data.documents[index], ),
            );
          }
        }
    );
  }

  Widget _buildTabs() {
    return new SingleChildScrollView(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: 500.0,
              child: CupertinoSegmentedControl<int>(
                children: children,
                borderColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).primaryColor,
                unselectedColor: Colors.white,
                onValueChanged: (int newValue) {
                  setState(() {
                    _sharedValue = newValue;
                  });
                },
                groupValue: _sharedValue,
              ),
            ),
          ),
          getChildren()[_sharedValue],
        ],
      ),
    );
  }

  Widget _buildAction(user) {
    return new IconButton(
      icon: new Stack(
        children: <Widget>[
          new Icon(Icons.add, size: 30, color: Colors.black),
          new Positioned(
            right: 0,
            child: Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              constraints: BoxConstraints(
                minWidth: 13,
                minHeight: 13,
              ),
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderCreate(user: user,),
            fullscreenDialog: true,
          ),
        );
      },
    );
  }
}
