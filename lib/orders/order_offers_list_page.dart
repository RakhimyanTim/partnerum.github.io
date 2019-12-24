import 'dart:io';
import 'dart:typed_data';

import 'package:partnerum/models/order.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:native_share/native_share.dart';
import 'package:partnerum/chats/chat_room_page.dart';
import 'package:partnerum/models/offer.dart';
import 'package:partnerum/orders/order_offer_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';


class OrderOffersListPage extends StatefulWidget {

  final FirebaseUser user;
  final String orderId;

  OrderOffersListPage({this.user, this.orderId});

  @override
  _OrderOffersListPageState createState() => _OrderOffersListPageState(
    user: this.user,
    orderId: this.orderId,
  );
}

class _OrderOffersListPageState extends State<OrderOffersListPage> {

  final FirebaseUser user;
  final String orderId;

  _OrderOffersListPageState({this.user, this.orderId});

  final _newForm = GlobalKey<FormState>();
  final _acceptedForm = GlobalKey<FormState>();
  final _rejectedForm = GlobalKey<FormState>();

  Map<int, Widget> children = <int, Widget>{
    0: Text("Новые", style: new TextStyle(fontSize: 16),),
    1: Text("В работе", style: new TextStyle(fontSize: 16),),
    2: Text("Откл", style: new TextStyle(fontSize: 16),),
  };

  getChildren() {
    return <int, Widget>{
      0: Form(
        key: _newForm,
        child: _buildNew(),
      ),
      1: Form(
        key: _acceptedForm,
        child: _buildAccepted(),
      ),
      2: Form(
        key: _rejectedForm,
        child: _buildRejected(),
      ),
    };
  }

  int _sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: _buildTabs(),
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

  Widget _buildAppBar() {
    return new AppBar(
      leading: new IconButton(
        icon: Theme.of(context).platform == TargetPlatform.iOS
            ? new Icon(Icons.arrow_back_ios)
            : new Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Подходящие квартиры'),
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

  Widget _buildNew() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('offers')
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      'Здесь появится список подходящих квартир',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
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
              itemBuilder: (context, index) => _buildNewItem(
                context,
                snapshot.data.documents[index],
                Offer.fromDocument(snapshot.data.documents[index]),
                Order.fromDocument(snapshot.data.documents[index]),
              ),
            );
          }
        }
    );
  }
  Widget _buildNewItem(context, document, offer, order) {
    if (offer.offerAccepts.containsKey(orderId) == true
        && offer.orderAccepts.containsKey(orderId) == false) {
      final _height = MediaQuery.of(context).size.height;
      final _width = MediaQuery.of(context).size.width;
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['userImage'] != null ? new CachedNetworkImage(
                      imageUrl: document['userImage'],
                      imageBuilder: (context, imageProvider) => Container(
                        height: _height / 22,
                        width: _width / 10,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ) : new Container(
                      child: new CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: new Text('${document['userName'][0]}', style: new TextStyle(color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: new Text('${document['userName']}', style: new TextStyle(color: Colors.black, fontSize: 18),),
                    ),
                  ],
                ),
                new IconButton(
                  icon: new Icon(Partnerum.help, color: Colors.grey,),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          peerId: document['userId'],
                          currentId: widget.user.uid,
                          peerName: document['userName'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.city, color: Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text('${document['offerCityName']}',),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['offerCityName'] == 'Москва' ? new SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Icon(Partnerum.metro, color: Colors.grey, size: 14,),
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
                                  return new Text('${document['offerMetroStantion'][index]} ');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : new Container()
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.ruble, color:  Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text(
                        'От ${document['offerStartPrice'].toString()} до ${document['offerEndPrice'].toString()} руб/сут',
                      ),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.rooms, color:  Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text(
                        '${document['offerRoomsCount']} комн.',
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderOfferDetailPage(
                        user: user,
                        offerId: document['offerId'],
                      ),
                    ),
                  );
                },
                child: new Text('Подробнее', style: TextStyle(color: Colors.grey),),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new Text('Вам подходит?'),
                  new PopupMenuButton(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, left: 8),
                      child: new Text('Ответить', style: TextStyle(color: Theme.of(context).primaryColor),),
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(child: Text('Согласен'), value: 'accepted'),
                      PopupMenuItem(child: Text('Отказ'), value: 'rejected'),
                    ],
                    onSelected: (value) {
                      if (value == 'accepted') {
                        Firestore.instance.document("offers/${document['offerId']}").updateData({
                          'orderAccepts.$orderId': true,
                        });
                      } else {
                        Firestore.instance.document("offers/${document['offerId']}").updateData({
                          'orderAccepts.$orderId': false,
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          new Divider(),
        ],
      );
    } else {
      return new Container();
    }
  }

  Widget _buildAccepted() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('offers')
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      'Здесь появится список подходящих квартир',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
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
              itemBuilder: (context, index) => _buildAcceptedItem(
                context,
                snapshot.data.documents[index],
                Offer.fromDocument(snapshot.data.documents[index]),
                Order.fromDocument(snapshot.data.documents[index]),
              ),
            );
          }
        }
    );
  }
  Widget _buildAcceptedItem(context, document, offer, order) {
    if (offer.offerAccepts.containsKey(orderId) == true
        && offer.orderAccepts.containsKey(orderId) == true
        && document['orderAccepts']['$orderId'] == true

        && offer.offerAccepts.containsKey(orderId) == true
        && document['offerAccepts']['$orderId'] == true
    ) {
      final _height = MediaQuery.of(context).size.height;
      final _width = MediaQuery.of(context).size.width;
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['userImage'] != null ? new CachedNetworkImage(
                      imageUrl: document['userImage'],
                      imageBuilder: (context, imageProvider) => Container(
                        height: _height / 22,
                        width: _width / 10,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ) : new Container(
                      child: new CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: new Text('${document['userName'][0]}', style: new TextStyle(color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: new Text('${document['userName']}', style: new TextStyle(color: Colors.black, fontSize: 18),),
                    ),
                  ],
                ),
                new IconButton(
                  icon: new Icon(Partnerum.help, color: Colors.grey,),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          peerId: document['userId'],
                          currentId: widget.user.uid,
                          peerName: document['userName'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.city, color: Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text('${document['offerCityName']}',),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['offerCityName'] == 'Москва' ? new SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Icon(Partnerum.metro, color: Colors.grey, size: 14,),
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
                                  return new Text('${document['offerMetroStantion'][index]} ');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : new Container()
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.ruble, color:  Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text(
                        'От ${document['offerStartPrice'].toString()} до ${document['offerEndPrice'].toString()} руб/сут',
                      ),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.rooms, color:  Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text(
                        '${document['offerRoomsCount']} комн.',
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: new Text('Переместить', style: TextStyle(color: Theme.of(context).primaryColor),),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('В отклоненные'), value: 'rejected'),
                ],
                onSelected: (value) {
                  Firestore.instance.document("offers/${document['offerId']}").updateData({
                    'orderAccepts.$orderId': false,
                  });
                },
              ),
            ],
          ),
          new Divider(),
        ],
      );
    } else {
      return new Container();
    }
  }

  Widget _buildRejected() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('offers')
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      'Здесь появится список подходящих квартир',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
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
              itemBuilder: (context, index) => _buildRejectedItem(
                context,
                snapshot.data.documents[index],
                Offer.fromDocument(snapshot.data.documents[index]),
                Order.fromDocument(snapshot.data.documents[index]),
              ),
            );
          }
        }
    );
  }
  Widget _buildRejectedItem(context, document, offer, order) {
    if (offer.offerAccepts.containsKey(orderId) == true
        && offer.orderAccepts.containsKey(orderId) == true
        && document['orderAccepts']['$orderId'] == false

    ) {
      final _height = MediaQuery.of(context).size.height;
      final _width = MediaQuery.of(context).size.width;
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['userImage'] != null ? new CachedNetworkImage(
                      imageUrl: document['userImage'],
                      imageBuilder: (context, imageProvider) => Container(
                        height: _height / 22,
                        width: _width / 10,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ) : new Container(
                      child: new CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: new Text('${document['userName'][0]}', style: new TextStyle(color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: new Text('${document['userName']}', style: new TextStyle(color: Colors.black, fontSize: 18),),
                    ),
                  ],
                ),
                new IconButton(
                  icon: new Icon(Partnerum.help, color: Colors.grey,),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          peerId: document['userId'],
                          currentId: widget.user.uid,
                          peerName: document['userName'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            subtitle: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.city, color: Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text('${document['offerCityName']}',),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    document['offerCityName'] == 'Москва' ? new SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Icon(Partnerum.metro, color: Colors.grey, size: 14,),
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
                                  return new Text('${document['offerMetroStantion'][index]} ');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : new Container(),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.ruble, color:  Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text(
                        'От ${document['offerStartPrice'].toString()} до ${document['offerEndPrice'].toString()} руб/сут',
                      ),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child: new Icon(Partnerum.rooms, color:  Colors.grey, size: 14,),
                    ),
                    new Container(
                      margin: new EdgeInsets.symmetric(vertical: 3.0),
                      child: new Text(
                        '${document['offerRoomsCount']} комн.',
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: new Text('Переместить', style: TextStyle(color: Theme.of(context).primaryColor),),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('В работе'), value: 'onWork'),
                ],
                onSelected: (value) {
                  Firestore.instance.document("offers/${document['offerId']}").updateData({
                    'orderAccepts.$orderId': true,
                  });
                },
              ),
            ],
          ),
          new Divider(),
        ],
      );
    } else {
      return new Container();
    }
  }

}

