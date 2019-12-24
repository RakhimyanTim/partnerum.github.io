import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:partnerum/chats/chats_page.dart';
import 'package:partnerum/offers/offers_page.dart';
import 'package:partnerum/orders/orders_page.dart';
import 'package:partnerum/profile/profile_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  HomePage({this.user, this.onSignedOut});

  @override
  _HomePageState createState() => _HomePageState(
      user: this.user,
      onSignedOut: this.onSignedOut,
  );
}

class _HomePageState extends State<HomePage> {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  _HomePageState({this.user, this.onSignedOut});

  PageController pageController;

  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  int _page = 0;

  bool _newOrderNotification = false;
  bool _newOfferNotification = false;
  bool _newMessageNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new PageView(
        children: [
          new Container(color: Colors.white, child: new OrdersPage(user: widget.user)),
          new Container(color: Colors.white, child: new OffersPage(user: widget.user)),
          new Container(color: Colors.white, child: new ChatsPage(user: widget.user)),
          new Container(color: Colors.white, child: new ProfilePage(user: user, onSignedOut: onSignedOut)),
        ],
        controller: pageController,
        physics: new NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: new Container(
        height: Theme.of(context).platform == TargetPlatform.iOS ? 85.0 : 64.0,
        child: new Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Colors.white,
              primaryColor: Colors.redAccent,
              textTheme: Theme
                  .of(context)
                  .textTheme
                  .copyWith(caption: new TextStyle(color: Colors.black))),
          child: PreferredSize(
            preferredSize: Size.fromHeight(25.0),
            child: new BottomNavigationBar(items: [
              BottomNavigationBarItem(
                icon: _newOfferNotification
                    ? new Stack(
                  children: <Widget>[
                    new Icon(Partnerum.offer, size: 25.0, color: (_page == 0) ? Theme.of(context).primaryColor : Colors.black),
                    Positioned(
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
                    )
                  ],
                )
                    : new Icon(Partnerum.offer, size: 25.0, color: (_page == 0) ? Theme.of(context).primaryColor: Colors.black),
                title: Text('Продать заявку', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,),),
                backgroundColor: Colors.white,
              ),
              BottomNavigationBarItem(
                icon: _newOrderNotification
                    ? new Stack(
                  children: <Widget>[
                    new Icon(Partnerum.order, size: 25.0, color: (_page == 1) ? Theme.of(context).primaryColor : Colors.black),
                    Positioned(
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
                    )
                  ],
                ) : Icon(Partnerum.order, size: 25.0, color: (_page == 1) ? Theme.of(context).primaryColor : Colors.black),
                title: Text('Мои квартиры', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                backgroundColor: Colors.white,
              ),
              BottomNavigationBarItem(
                icon: _newMessageNotification
                    ? new Stack(
                  children: <Widget>[
                    new Icon(Partnerum.help, size: 25.0, color: (_page == 2) ? Theme.of(context).primaryColor: Colors.black),
                    Positioned(
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
                    )
                  ],
                )
                    : new Icon(Partnerum.help, size: 25.0, color: (_page == 2) ? Theme.of(context).primaryColor : Colors.black),
                title: Text('Чат', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                backgroundColor: Colors.white,
              ),
              BottomNavigationBarItem(
                icon: Icon(Partnerum.profile, size: 25.0, color: (_page == 3) ? Theme.of(context).primaryColor : Colors.black),
                title: Text('Профиль', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0,)),
                backgroundColor: Colors.white,
              ),
            ],
              fixedColor: Colors.white,
              type: BottomNavigationBarType.shifting,
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),

    );

  }

  void onPageChanged(int page) {
    setState(() {
     _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    if (page == 0){
      setState(() {
        _newOfferNotification = false;
      });
    } else if (page == 1){
      setState(() {
        _newOrderNotification = false;
      });
    } else if (page == 2){
      setState(() {
        _newMessageNotification = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
    registerNotification();
    configLocalNotification();
  }


  void registerNotification() {
    _fcm.requestNotificationPermissions();

    _fcm.configure(onMessage: (Map<String, dynamic> message) {

      showNotification(message['notification']);

      if (message['data']['type'] == 'newOrderNotificationType') {
        setState(() {
//          _navigateToOrderDetail(message);
          _newOrderNotification = true;
        });
      } else if (message['data']['type'] == 'newOfferNotificationType') {
        setState(() {
//          _navigateToOfferDetail(message);
          _newOfferNotification = true;
        });
      }
      else if (message['data']['type'] == 'newMessageNotificationType') {
        setState(() {
//          _navigateToMessageDetail(message);
          _newMessageNotification = true;
        });
      }

      print('onMessage: $message');
      return;
    }, onResume: (Map<String, dynamic> message) {

      showNotification(message['notification']);


      if (message['data']['type'] == 'newOrderNotificationType') {
        setState(() {
          _newOrderNotification = true;
        });
      } else if (message['data']['type'] == 'newOfferNotificationType') {
        setState(() {
          _newOfferNotification = true;
        });
      } else if (message['data']['type'] == 'newMessageNotificationType') {
        setState(() {
          _newMessageNotification = true;
        });
      }

      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {

      showNotification(message['notification']);

      print('onLaunch: $message');
      return;
    });

    _fcm.getToken().then((token) {
      Firestore.instance.collection('users').document(widget.user.uid).updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('appicon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'ru.rakhimyan.partnerum': 'ru.rakhimyan.partnerum',
      'Partnerum',
      'Новое уведомление',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }
}



