import 'package:partnerum/offers/offer_edit_page.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:partnerum/offers/offer_orders_list.dart';
import 'package:partnerum/offers/offer_create.dart';
import 'package:partnerum/offers/offer_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class OffersPage extends StatefulWidget {

  final FirebaseUser user;
  OffersPage({this.user});

  @override
  _OffersPageState createState() => _OffersPageState(
    user: this.user,
  );
}

class _OffersPageState extends State<OffersPage> {

  final FirebaseUser user;
  _OffersPageState({this.user});

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

  @override
  void initState() {
    setState(() {
      print('userId: ${widget.user.uid}');
    });
    super.initState();
  }

  Widget _buildActive() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('offers')
            .where('userId', isEqualTo: widget.user.uid)
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
                    : new CircularProgressIndicator(),
              ),
            );
          if (snapshot.data.documents.length == 0) {
            return new Container(
              margin: new EdgeInsets.all(20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildZeroOffers(),
                  new Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: new Text(
                      'Здесь будут показаны ваши квартиры. Добавляйте квартиры и сервис автоматически подберёт подходящие заявки.',
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
              itemBuilder: (context, index) => _buildOfferItem(context, snapshot.data.documents[index]),
            );
          }
        }
    );
  }

  Widget _buildNoActive() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('offers')
            .where('userId', isEqualTo: widget.user.uid)
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
                    : new CircularProgressIndicator(),
              ),
            );
          if (snapshot.data.documents.length == 0) {
            return new Container(
              margin: new EdgeInsets.all(20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildZeroOffers(),
                  new Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: new Text(
                      'Здесь будут показаны ваши квартиры. Добавляйте квартиры и сервис автоматически подберёт подходящие заявки.',
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
              itemBuilder: (context, index) => _buildOfferItem(context, snapshot.data.documents[index]),
            );
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text(
          'Мои квартиры',
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
        backgroundColor: Colors.white,
        actions: <Widget>[
          new IconButton(
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
                  builder: (context) => OfferCreatePage(user: widget.user,),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: new SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildOfferItem(BuildContext context, document) {
    return new Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildCity(document),
                _buildSwitch(document),
              ],
            ),
            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildMetro(document),
                  ],
                ),
                _buildAddress(document),
                _buildPrice(document),
              ],
            ),
          ),
          _buildBtns(document, user),
        ],
      ),
    );
  }

  Widget _buildBtns(document, user) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new FlatButton(
          onPressed: () {
            document['isSwitched'] != true ? new Container() : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfferDetailsPage(
                  user: user,
                  offerId: document['offerId'],
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
                builder: (context) => OfferOrdersList(
                  user: user,
                  offers: document,
                ),
              ),
            );
          },
          child: new Text(document['orderAccepts'].length == 0 ? 'Заявки' : 'Заявки ' + '(${document['orderAccepts'].length.toString()})',
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
            'От ${document['offerStartPrice'].toString()} до ${document['offerEndPrice'].toString()} руб/сут',
            style: new TextStyle(
              fontSize: 14,
              color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddress(document) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Icon(Partnerum.address, color: document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.grey, size: 14,),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: new Text(
            '${document['offerAddressName']}',
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              color: document['isSwitched'] != true ?
              Color(0xFFE7E7E7) : Colors.grey, fontSize: 14,
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
                itemCount: document['offerMetroStantion'].length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new Text(
                    '${document['offerMetroStantion'][index]} ',
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

  Widget _buildSwitch(document) {
    return new Switch(
      activeColor: Theme.of(context).primaryColor,
      value: document['isSwitched'],
      onChanged: (value) {
        setState(() {
          isSwitched = value;

        });
        Firestore.instance
            .collection('offers')
            .document(document['offerId'])
            .updateData({
          "isSwitched": isSwitched,
        });

        document['isSwitched'] != true ?  Fluttertoast.showToast(
          textColor: Colors.white,
          backgroundColor: Colors.black54,
          msg: "Квартира включена",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
        ) : Fluttertoast.showToast(
          textColor: Colors.white,
          backgroundColor: Colors.black54,
          msg: "Квартира выключена",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
        );

      },
    );
  }

  Widget _buildCity(document) {
    return new Text(
      '${document['offerCityName']}',
      style: new TextStyle(
        fontSize: 16,
        color:  document['isSwitched'] != true ? Color(0xFFE7E7E7) : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildZeroOffers() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: new Container(
          width: 300,
          height: 300,
          child: new SvgPicture.asset(
              'assets/images/zero_offers.svg',
              semanticsLabel: 'Zero offers'
          ),
        ),
      ),
    );
  }
}
