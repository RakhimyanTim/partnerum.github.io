import 'dart:async';

import 'package:partnerum/models/user_model.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnerum/chats/chat_room_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ChatsPage extends StatefulWidget {

  final FirebaseUser user;
  ChatsPage({this.user});

  @override
  _ChatsPageState createState() => _ChatsPageState(
    user: this.user,
  );
}

class _ChatsPageState extends State<ChatsPage> {

  final FirebaseUser user;
  _ChatsPageState({this.user});

  @override
  Widget build(BuildContext context) {

    bool isLoading = false;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Чат',
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
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // List
          Container(
            child: new StreamBuilder(
              stream: Firestore.instance
                  .collection("users")
                  .document(widget.user.uid)
                  .collection("chats")
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
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new Column(
                      children: <Widget>[
                        new ListTile(
                          title: new Text(
                            'Пока у вас нет чатов',
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) => buildItem(
                        context: context,
                        document: snapshot.data.documents[index],
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
              child: Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
              ),
              color: Colors.white.withOpacity(0.8),
            )
                : Container(),
          )
        ],
      ),
    );
  }


  Widget buildItem({BuildContext context, DocumentSnapshot document, }) {
    return new Column(
      children: <Widget>[
        new ListTile(
          leading: _buildImage(document),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Text('${document['userName']}', style: TextStyle(color: Colors.black),),
              new Padding(
                padding: const EdgeInsets.only(left: 8),
                child: document['isConfirmed'] != false ? new Icon(Partnerum.correct, color: Colors.green,) : new Row(),
              ),
            ],
          ) ,
          subtitle: new Text('${document['lastMessage']}', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontSize: 14, ),),
          trailing: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(DateFormat('dd/MM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))), style: TextStyle(color: Colors.grey, fontSize: 14, ),),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: new Container(
                  height: 20,
                  width: 30,
                  color: Colors.transparent,
                  child: document['unReadCount'] != 0 ? new Container(
                    decoration: new BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: new BorderRadius.all(Radius.circular(5))),
                    child: new Center(child: new Text('${document['unReadCount'].toString()}', style: new TextStyle(color: Colors.white, fontSize: 14),)),
                  ) : new Row(),
                ),
              ),
            ],
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomPage(
                  peerId: document['userId'],
                  currentId: widget.user.uid,
                  peerName: document['userName']!= null
                      ? document['userName']
                      : 'Имя',
                ),
              ),
            );
          },
        ),
        new Divider(),
      ],
    );
  }

  Widget _buildImage(document) {
    if (document['userImage'] != null && document['userImage'] != '') {
      return new CachedNetworkImage(
        imageUrl: '${document['userImage']}',
        imageBuilder: (context, imageProvider) => Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(Colors.white, BlendMode.colorBurn),
            ),
          ),
        ),
        placeholder: (context, url) => Theme.of(context).platform == TargetPlatform.iOS
            ? new CupertinoActivityIndicator()
            : new CircularProgressIndicator(),
        errorWidget: (context, url, error) => new Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(child: new Icon(Icons.info_outline, color: Theme.of(context).primaryColor,)),
        ),
      );
    } else {
      return new CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: new Text('${document['userName'][0]}', style: new TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      );
    }
  }


  void choiceAction(String choice){
    if (choice == Constants.ToBlock) {
      _toBlock();
    }
  }

  _toBlock() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new SimpleDialog(
          title: const Text('Заблокировать'),
          children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.info, color: Colors.black,),
              title: new Text('Внимание'),
              subtitle: new Text('Вы уверены, что хотите заблокировать этого пользователя?'),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
//                    _addBlockData();
                    _onPressBlock();
                  },
                  child: new Text('ДА', style: new TextStyle(color: Colors.redAccent),),
                ),
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('НЕТ', style: new TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onPressBlock() {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          'Ваша заявка принята и будет расмотрена в течении 24 часов!',
          style: new TextStyle(color: Colors.yellow),
        ),
      ),
    );
  }

  void _getUserData() async {

//    await Firestore.instance.collection('users').where('userId', isEqualTo: widget.user.uid).getDocuments().then((value) {
//      setState(() {
//        userList = value.documents[0]['userList'] as List;
//        print(userList);
//      });
//    });
  }



}

class Constants{
  static const String ToBlock = 'Заблокировать';

  static const List<String> choices = <String>[
    ToBlock,
  ];
}