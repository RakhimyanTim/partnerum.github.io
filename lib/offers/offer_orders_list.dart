import 'package:partnerum/chats/chat_room_page.dart';
import 'package:partnerum/models/offer.dart';
import 'package:partnerum/models/order.dart';
import 'package:partnerum/offers/offer_order_detail_page.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class OfferOrdersList extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot offers;

  OfferOrdersList({this.user, this.offers});

  @override
  _OfferOrdersListState createState() => _OfferOrdersListState();
}

class _OfferOrdersListState extends State<OfferOrdersList> {

  bool isAccepted = false;
  bool acceptButtonClicked = false;
  bool isDeal = false;

  final _newOrdersForm = GlobalKey<FormState>();
  final _acceptedOrdersForm = GlobalKey<FormState>();
  final _bookedOrdersForm = GlobalKey<FormState>();
  final _rejectedOrdersForm = GlobalKey<FormState>();

  Map<int, Widget> children = <int, Widget>{
    0: Text("Новые", style: new TextStyle(fontSize: 16),),
    1: Text("Одобр", style: new TextStyle(fontSize: 16),),
    2: Text("Бронь", style: new TextStyle(fontSize: 16),),
    3: Text("Откл", style: new TextStyle(fontSize: 16),),
  };


  getChildren() {
    return <int, Widget>{
      0: Form(
        key: _newOrdersForm,
        child: _buildNewOrders(),
      ),
      1: Form(
        key: _acceptedOrdersForm,
        child: _buildAcceptedOrders(),
      ),
      2: Form(
        key: _bookedOrdersForm,
        child: _buildBookedOrders(),
      ),
      3: Form(
        key: _rejectedOrdersForm,
        child: _buildRejectedOrders(),
      ),
    };
  }

  int _sharedValue = 0;
  int _value = 0;
  String _acceptValue;

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
      title: Text('Подходящие заявки'),
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
    );
  }

  Widget _buildNewOrders() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
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
                      'Здесь появится список подходящих заявок',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
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
              itemBuilder: (context, index) => _buildNewOrderItem(context, snapshot.data.documents[index], Order.fromDocument(snapshot.data.documents[index]), Offer.fromDocument(snapshot.data.documents[index])),
            );
          }
        }
    );
  }

  Widget _buildAcceptedOrders() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
            .where('isSwitched', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return new Container(
              alignment: FractionalOffset.center,
              child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.data.documents.length == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      'Здесь появится список подходящих заявок',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
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
              itemBuilder: (context, index) => _buildAcceptedOrderItem(context, snapshot.data.documents[index], Order.fromDocument(snapshot.data.documents[index]), Offer.fromDocument(snapshot.data.documents[index]),),
            );
          }
        }
    );
  }

  Widget _buildRejectedOrders() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
            .where('isSwitched', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return new Container(
              alignment: FractionalOffset.center,
              child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.data.documents.length == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      'Здесь появится список отклоненных заявок',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
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
              itemBuilder: (context, index) => _buildRejectedOrderItem(context, snapshot.data.documents[index], Order.fromDocument(snapshot.data.documents[index]), Offer.fromDocument(snapshot.data.documents[index]),),
            );
          }
        }
    );
  }

  Widget _buildBookedOrders() {
    return new StreamBuilder(
        stream: Firestore.instance.collection('orders')
            .where('isSwitched', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return new Container(
              alignment: FractionalOffset.center,
              child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.data.documents.length == 0) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      'Здесь появится список бронированных заявок',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
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
              itemBuilder: (context, index) => _buildBookedOrderItem(context, snapshot.data.documents[index], Order.fromDocument(snapshot.data.documents[index]), Offer.fromDocument(snapshot.data.documents[index]),),
            );
          }
        }
    );
  }

  Widget _buildNewOrderItem(BuildContext context, DocumentSnapshot orders, Order order, Offer offer) {

    if (orders['userId'] != widget.user.uid
        && orders['orderCityName'] == widget.offers['offerCityName']
        && offer.offerAccepts.containsKey(widget.offers['offerId']) == false
        && order.orderAccepts.containsKey(widget.offers['offerId']) == false
    ) {

//      _addOrderId(orderId: document[orderId], offerId: widget.document[offerId],);

      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: _buildTitle(orders),
            subtitle: _buildSubtitle(orders),
            onTap: () {
//              Navigator.push(
//                context,
//                MaterialPageRoute(
//                  builder: (context) => OfferOrderDetailPage(
//                    user: widget.user,
//                    order: document,
//                  ),
//                ),
//              );
            },
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  if (order.orderAccepts.containsKey(widget.offers['offerId']) == true
                      && order.offerAccepts.containsKey(widget.offers['offerId']) == true) {
                    setState(() {
                      isDeal = true;
                    });
                  } else {
                    isDeal = false;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferOrderDetailPage(
                        user: widget.user,
                        orders: orders,
                        isDeal: isDeal,
                      ),
                    ),
                  );
                },
                child: new Text(
                  'Подробнее',
                  style: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              _buildOrderAcceptButton(orders, order),
            ],
          ),
          new Divider(),
        ],
      );

    } else {
      return new Container();
    }

  }

  Widget _buildAcceptedOrderItem(BuildContext context, DocumentSnapshot orders, Order order, Offer offer) {

    if (orders['userId'] != widget.user.uid
        && orders['orderCityName'] == widget.offers['offerCityName']

        && order.orderAccepts.containsKey(widget.offers['offerId']) == true
        && order.orderAccepts['${widget.offers['offerId']}'] == true

//        && offer.offerAccepts.containsKey(orders['orderId']) == true
//        && offer.offerAccepts['${orders['orderId']}'] == true

    ) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: _buildTitle(orders),
            subtitle: _buildSubtitle(orders),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  if (order.orderAccepts.containsKey(widget.offers['offerId']) == true
                      && order.offerAccepts.containsKey(widget.offers['offerId']) == true) {
                    setState(() {
                      isDeal = true;
                    });
                  } else {
                    isDeal = false;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferOrderDetailPage(
                        user: widget.user,
                        orders: orders,
                        isDeal: isDeal,
                      ),
                    ),
                  );
                },
                child: new Text('Подробнее',
                  style: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              new PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: new Text('Переместить', style: TextStyle(color: Theme.of(context).primaryColor),),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('Бронированные'), value: 'booked',),
                  PopupMenuItem(child: Text('Отклоненные'), value: 'rejected'),
                ],
                onSelected: (value) async {
                  if (value == 'booked') {
                    Firestore.instance.document("orders/${orders['orderId']}").updateData({
                      'orderAccepts.${widget.offers['offerId']}': true,
                    });
                    Firestore.instance.document("orders/${orders['orderId']}").updateData({
                      'offerAccepts.${widget.offers['offerId']}': true,
                    });
                    Fluttertoast.showToast(
                      textColor: Colors.black,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      msg: "Заявка перенесена в \"Бронированные\"",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                    );
                  } else if (value == 'rejected') {
                    Firestore.instance.document("orders/${orders['orderId']}").updateData({
                      'orderAccepts.${widget.offers['offerId']}': false,
                    });
                    Firestore.instance.document("offers/${widget.offers['offerId']}").updateData({
                      'offerAccepts.${orders['orderId']}': false,
                    });
                    Fluttertoast.showToast(
                      textColor: Colors.black,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      msg: "Заявка перенесена в \"Отклоненные\"",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                    );
                  }
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

  Widget _buildRejectedOrderItem(BuildContext context, DocumentSnapshot orders, Order order, Offer offer) {

    if (orders['userId'] != widget.user.uid
        && orders['orderCityName'] == widget.offers['offerCityName']

        && order.orderAccepts.containsKey(widget.offers['offerId']) == true
        && order.orderAccepts['${widget.offers['offerId']}'] == false

//        && order.offerAccepts.containsKey(widget.offers['offerId']) == true
//        && order.offerAccepts['${widget.offers['offerId']}'] == false
//
//        && offer.offerAccepts.containsKey(orders['orderId']) == true
//        && offer.offerAccepts['${orders['orderId']}'] == false


    ) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: _buildTitle(orders),
            subtitle: _buildSubtitle(orders),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  if (order.orderAccepts.containsKey(widget.offers['offerId']) == true
                      && order.offerAccepts.containsKey(widget.offers['offerId']) == true) {
                    setState(() {
                      isDeal = true;
                    });
                  } else {
                    isDeal = false;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferOrderDetailPage(
                        user: widget.user,
                        orders: orders,
                        isDeal: isDeal,
                      ),
                    ),
                  );
                },
                child: new Text('Подробнее',
                  style: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              new PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: new Text('Переместить', style: TextStyle(color: Theme.of(context).primaryColor),),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('Одобренные'), value: 'accepted',),
                ],
                onSelected: (value) {
                  setState(() {

                    Firestore.instance.document("orders/${orders['orderId']}").updateData({
                      'orderAccepts.${widget.offers['offerId']}': true,
                    });

                    Firestore.instance.document("orders/${orders['orderId']}").updateData({
                      'offerAccepts.${widget.offers['offerId']}': false,
                    });


                    Fluttertoast.showToast(
                      textColor: Colors.black,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      msg: "Заявка перенесена в \"Одобренные\"",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                    );
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

  Widget _buildBookedOrderItem(BuildContext context, DocumentSnapshot orders, Order order, Offer offer) {

    if (orders['userId'] != widget.user.uid
        && orders['orderCityName'] == widget.offers['offerCityName']
        && order.orderAccepts.containsKey(widget.offers['offerId']) == true
        && order.orderAccepts['${widget.offers['offerId']}'] == true
        && order.offerAccepts.containsKey(widget.offers['offerId']) == true
        && order.offerAccepts['${widget.offers['offerId']}'] == true
    ) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: _buildTitle(orders),
            subtitle: _buildSubtitle(orders),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  if (order.orderAccepts.containsKey(widget.offers['offerId']) == true
                      && order.offerAccepts.containsKey(widget.offers['offerId']) == true) {
                    setState(() {
                      isDeal = true;
                    });
                  } else {
                    isDeal = false;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferOrderDetailPage(
                        user: widget.user,
                        orders: orders,
                        isDeal: isDeal,
                      ),
                    ),
                  );
                },
                child: new Text('Подробнее',
                  style: new TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              new PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: new Text('Переместить', style: TextStyle(color: Theme.of(context).primaryColor),),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(child: Text('Отклоненные'), value: 'rejected'),
                ],
                onSelected: (value) {
                  setState(() {
                    Firestore.instance.document("orders/${orders['orderId']}").updateData({
                      'orderAccepts.${widget.offers['offerId']}': false,
                    });
                    Firestore.instance.document("offers/${widget.offers['offerId']}").updateData({
                      'offerAccepts.${orders['orderId']}': false,
                    });
                    Fluttertoast.showToast(
                      textColor: Colors.black,
                      backgroundColor: Colors.black.withOpacity(0.1),
                      msg: "Заявка перенесена в \"Отклоненные\"",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                    );
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

  Widget _buildSubtitle(orders) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: new Icon(Partnerum.calendar, color: Colors.grey, size: 14,),
            ),
            new Text(
              '${DateFormat('dd MMM', 'ru').format(orders['orderArrivelDate'].toDate()).toString()} - ${DateFormat('dd MMM', 'ru').format(orders['orderDepartureDate'].toDate()).toString()}',
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: new Icon(Partnerum.city, color: Colors.grey, size: 14,),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(vertical: 3.0),
              child: new Text('${orders['orderCityName']}',),
            ),
          ],
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            orders['orderCityName'] == 'Москва' ? new SingleChildScrollView(
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
                        itemCount: orders['orderStationsList'].length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return new Text('${orders['orderStationsList'][index]} ');
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
                'От ${orders['orderStartPrice'].toString()} до ${orders['orderEndPrice'].toString()} руб/сут',
              ),
            )
          ],
        ),
        new Row(
          children: <Widget>[
            new Icon(Partnerum.guest, color: Colors.grey, size: 14,),
            new Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: new Text('${orders['orderGuestsCount']} чел',),
            ),
          ],
        ),
        new Row(
          children: <Widget>[
            new SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Icon(Partnerum.rooms, color:  Colors.grey, size: 14,),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: new Container(
                      height: 16,
                      child: new ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: orders['orderRoomsList'].length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return new Text('${orders['orderRoomsList'][index]} комн.',);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(orders) {

    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new CachedNetworkImage(
              imageUrl: orders['userImage'],
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
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: new Text('${orders['userName']}', style: new TextStyle(color: Colors.black, fontSize: 18),),
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
                  peerId: orders['userId'],
                  currentId: widget.user.uid,
                  peerName: orders['userName'],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrderAcceptButton(DocumentSnapshot orders, Order order) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Text('Вам подходит?'),
          new IconButton(
            onPressed: () => _showAcceptDialog(context: context, orderId: orders['orderId'], offerId: widget.offers['offerId'],),
            icon: new Icon(Icons.check, color: Theme.of(context).primaryColor),
          ),
          new IconButton(
            onPressed: () => _showRejectDialog(context: context, orderId: orders['orderId'], offerId: widget.offers['offerId'],),
            icon: new Icon(Icons.clear, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<bool> _showAcceptDialog({BuildContext context, orderId, offerId}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Внимание!', textAlign: TextAlign.center,),
            content: new Text('Нажимая на кнопку, Вы предлагаете свою квартиру для этой заявки и ждете согласования с клиентом.'),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Согласен', style: new TextStyle(color: Theme.of(context).primaryColor),),
                onPressed: () async {
                  setState(() {
                    this.isAccepted = true;
                    acceptButtonClicked = true;
                  });

                  Firestore.instance.document("orders/$orderId").updateData({
                    'orderAccepts.$offerId': true
                  });

                  Firestore.instance.document("offers/$offerId").updateData({
                    'offerAccepts.$orderId': true,
                  });



                  await Firestore.instance
                      .collection("offers")
                      .document(offerId)
                      .collection("orders")
                      .document(orderId)
                      .setData({
                    "orderId": orderId,
                    "offerId": offerId,
                    "timestamp": new DateTime.now().millisecondsSinceEpoch.toString()
                  });

                  Fluttertoast.showToast(
                    textColor: Colors.black,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    msg: "Заявка переведена в \"Одобранные\"",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 1,
                  );
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Text('Отмена', style: TextStyle(color: Colors.black),),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  Future<bool> _showRejectDialog({BuildContext context, orderId, offerId}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new Text('Переместить заявку в раздел отколненные?'),

            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Нет', style: new TextStyle(color: Colors.grey),),
                onPressed: () => Navigator.of(context).pop(),
              ),
              new FlatButton(
                child: Text('Да', style: new TextStyle(color: Theme.of(context).primaryColor),),
                onPressed: () {
                  setState(() {
                    isAccepted = false;
                    acceptButtonClicked = true;
                  });

                  Firestore.instance.document("orders/$orderId").updateData({
                    'orderAccepts.$offerId': false
                  });

//                  Firestore.instance.document("orders/$orderId").updateData({
//                    'offerAccepts.$offerId': false,
//                  });

//                  Firestore.instance.document("offers/$offerId").updateData({
//                    'offerAccepts.$offerId': false,
//                  });

                  Fluttertoast.showToast(
                    textColor: Colors.black,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    msg: "Заявка отклонена",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIos: 1,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

}
