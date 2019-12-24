import 'package:partnerum/orders/order_edit_page.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class OrderDetailPage extends StatefulWidget {

  final FirebaseUser user;
  final String orderId;

  OrderDetailPage({this.user, this.orderId});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState(
    user: this.user,
    orderId: this.orderId,
  );
}

class _OrderDetailPageState extends State<OrderDetailPage> {

  final FirebaseUser user;
  final String orderId;

  _OrderDetailPageState({this.user, this.orderId});

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
            .document(orderId)
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
            appBar: _buildAppBar(user, document),
            backgroundColor: Colors.white,
            body: new SingleChildScrollView(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildCity(document),
                  _buildMetro(document),
                  _buildDistance(document),
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

  Widget _buildAppBar(user, document) {
    return new AppBar(
      leading: new IconButton(
        icon: Theme.of(context).platform == TargetPlatform.iOS
            ? new Icon(Icons.arrow_back_ios)
            : new Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('${DateFormat('dd MMM', 'ru').format(document['orderArrivelDate'].toDate()).toString()} - ${DateFormat('dd MMM', 'ru').format(document['orderDepartureDate'].toDate()).toString()}'),
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
      actions: <Widget>[
        _buildAction(user, document),
      ],
      backgroundColor: Colors.white,
    );
  }

  Widget _buildAction(user, document) {
    return new IconButton(
      icon: new Icon(
        Partnerum.edit,
        color: Colors.black,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderEditPage(
              user: user,
              order: document,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.info, color: Theme.of(context).primaryColor),
      title: new Text('Информация'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: new Align(
            alignment: Alignment.topLeft,
            child: document['orderInfoField'] != '' ?
            new Text('${document['orderInfoField']}') :
            new Text('Не указана'),
          ),
        ),
      ],
    );
  }

  Widget _buildComission(document) {
    return ListTile(
      leading: new Icon(Partnerum.percent, color: Theme.of(context).primaryColor),
      title: new Text('размер комиссии'),
      subtitle: new Text('${document['orderComissionSize']} %'),
    );
  }

  Widget _buildPhone(document) {
    return new ListTile(
      leading: new Icon(Partnerum.phone, color: Theme.of(context).primaryColor),
      title: new Text('Телефон заказчика'),
      subtitle: new Text('${document['orderCustomerPhone']}',),
    );
  }

  Widget _buildGuests(document) {
    return ListTile(
      leading: new Icon(Partnerum.guest, color: Theme.of(context).primaryColor),
      title: new Text('Количество гостей'),
      subtitle: new Text('${document['orderGuestsCount']} чел'),
    );
  }

  Widget _buildRooms(document) {
    return ListTile(
      leading: new Icon(Partnerum.rooms, color: Theme.of(context).primaryColor),
      title: new Text('Количество комнат'),
      subtitle: new Container(
        height: 16,
        child: new ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: document['orderRoomsList'].length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return new Text('${document['orderRoomsList'][index]}, ');
          },
        ),
      ),
    );
  }

  Widget _buildPrice(document) {
    return new ListTile(
      leading: new Icon(Partnerum.ruble, color: Theme.of(context).primaryColor),
      title: new Text('Цена'),
      subtitle: new Text('От ${document['orderStartPrice']} до ${document['orderEndPrice']} руб/сут',),
    );
  }

  Widget _buildCity(document) {
    return new ListTile(
      leading: new Icon(Partnerum.city, color: Theme.of(context).primaryColor),
      title: new Text('Город'),
      subtitle: new Text('${document['orderCityName']}'),

    );
  }

  Widget _buildMetro(document) {
    return document['orderCityName'] == 'Москва' ? new ExpansionTile(
      leading: new Icon(Partnerum.metro, color: Theme.of(context).primaryColor),
      title: new Text('Станции метро (${document['orderStationsList'].length})'),
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: new Align(
            alignment: Alignment.topLeft,
            child: new ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: document['orderStationsList'].length,
              itemBuilder: (context, index) {
                return new Text('${document['orderStationsList'][index]}', style: new TextStyle(fontSize: 14, color: Colors.grey),);
              },
            ),
          ),
        ),
      ],
    ) : new Container();
  }

  Widget _buildDistance(document) {
    return document['orderCityName'] == 'Москва' ? new ListTile(
      leading: new Icon(Partnerum.walk, color: Theme.of(context).primaryColor),
      title: new Text('Пешком до метро'),
      subtitle: document['orderDistanceTime'] == 'Неважно'
          ? new Text('${document['orderDistanceTime']}')
          : new Text('${document['orderDistanceTime']} мин'),
    ) : new Container();
  }

}
