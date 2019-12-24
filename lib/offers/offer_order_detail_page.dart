import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';

class OfferOrderDetailPage extends StatefulWidget {

  final FirebaseUser user;
  final DocumentSnapshot orders;
  final bool isDeal;
//  final bool isDeal;

  OfferOrderDetailPage({this.user, this.orders, this.isDeal});

  @override
  _OfferOrderDetailPageState createState() => _OfferOrderDetailPageState();
}

class _OfferOrderDetailPageState extends State<OfferOrderDetailPage> {

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
      appBar: AppBar(
        leading: new IconButton(
          icon: Theme.of(context).platform == TargetPlatform.iOS
              ? new Icon(Icons.arrow_back_ios)
              : new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${DateFormat('dd MMM', 'ru').format(widget.orders['orderArrivelDate'].toDate()).toString()} - ${DateFormat('dd MMM', 'ru').format(widget.orders['orderDepartureDate'].toDate()).toString()}'),
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
      body: new ListView(
        children: <Widget>[
          _buildCity(widget.orders),
          _buildMetro(widget.orders),
          _buildDistance(widget.orders),
          _buildPrice(widget.orders),
          _buildRooms(widget.orders),
          _buildComission(widget.orders),
          _buildInfo(widget.orders),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: new Container(
        margin: new EdgeInsets.symmetric(vertical: 30),
        child: widget.isDeal != false
            ? FloatingActionButton.extended(
          icon: new Icon(Icons.phone),
          backgroundColor: Colors.amber,
          label: new Text('${widget.orders['orderCustomerPhone']}',),
          onPressed: () => launch("tel://${widget.orders['orderCustomerPhone']}"),
        )
            : new Row(),
      ),
    );
  }

  Widget _buildDistance(document) {
    if (document['orderCityName'] == 'Москва') {
      return new ListTile(
        leading: new Icon(Partnerum.walk, color: Theme.of(context).primaryColor),
        title: new Text('Пешком до метро'),
        subtitle: document['orderDistanceTime'] == 'Неважно'
            ? new Text('${document['orderDistanceTime']}')
            : new Text('${document['orderDistanceTime']} мин'),
      );
    } else {
      return new Container();
    }
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
            return new Text('${document['orderRoomsList'][index]} ');
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

  Widget _buildMetro(document) {
    return document['orderCityName'] == 'Москва' ? new ExpansionTile(
      leading: new Icon(Partnerum.metro, color: Theme.of(context).primaryColor),
      title: new Text('Станции метро (${document['orderStationsList'].length})'),
      children: <Widget>[
        new Container(
          margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _buildCity(document) {
    return new ListTile(
      leading: new Icon(Partnerum.city, color: Theme.of(context).primaryColor),
      title: new Text('Город'),
      subtitle: new Text('${document['orderCityName']}'),
    );
  }

  Widget _buildInfo(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.info, color: Theme.of(context).primaryColor),
      title: new Text('Информация'),
      children: <Widget>[
        new Container(
          margin: new EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
      title: new Text('Комиссия'),
      subtitle: document['orderComissionSize'] == 'Неважно' ? new Text(
        '${document['orderComissionSize']}',
      ) : new Text('${document['orderComissionSize']} %'),
    );
  }
}
