import 'dart:io';

import 'package:partnerum/tools/app_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomPage extends StatefulWidget {

  final String peerId;
  final String currentId;
  final String peerName;

  ChatRoomPage({
    this.peerId,
    this.currentId,
    this.peerName,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {


  bool isBlocked = true;
  bool blockButtonClicked = true;

  @override
  void dispose() {
    super.dispose();
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
        title: Text('${widget.peerName}'),
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
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              PopupMenuButton<String>(
                icon: new Icon(Icons.more_vert),
                onSelected: choiceAction,
                itemBuilder: (BuildContext context){
                  return Constants.choices.map((String choice){
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
            ],
          ),
        ],
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: new ChatScreen(
        peerId: widget.peerId,
        currentId: widget.currentId,
        peerName: widget.peerName,
      ),
    );
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
//              trailing: new Row(
//                mainAxisAlignment: MainAxisAlignment.end,
//                children: <Widget>[
//                  Switch(
//                    activeColor: Colors.green,
//                    value: document['isSwitched'],
//                    onChanged: (value) {
//
//                      setState(() {
//                        isSwitched = value;
//
//                      });
//
//                      Firestore.instance
//                          .collection('orders')
//                          .document(document[orderId])
//                          .updateData({
//                        "isSwitched": isSwitched,
//                      });
//
//                      document['isSwitched'] != true ?  Fluttertoast.showToast(
//                        textColor: Colors.white,
//                        backgroundColor: Colors.black,
//                        msg: "Заявка включена",
//                        toastLength: Toast.LENGTH_SHORT,
//                        timeInSecForIos: 1,
//                      ) : Fluttertoast.showToast(
//                        textColor: Colors.white,
//                        backgroundColor: Colors.black,
//                        msg: "Заявка выключена",
//                        toastLength: Toast.LENGTH_SHORT,
//                        timeInSecForIos: 1,
//                      );
//
//                    },
//                  ),
//                ],
//              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _onPressBlock(
                      currentUserId: widget.currentId,
                      blockedUserId: widget.peerId,
                    );
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


  void _onPressBlock({currentUserId, blockedUserId}) async {
    setState(() {
      this.isBlocked = true;
      blockButtonClicked = true;
    });


    await Firestore.instance
        .collection("users")
        .document(currentUserId)
        .collection("blocks")
        .document(blockedUserId)
        .setData({
      "userId": blockedUserId,
      "timestamp": new DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }
}

class ChatScreen extends StatefulWidget {

  final String peerId;
  final String currentId;
  final String peerName;

  ChatScreen({this.peerId, this.currentId, this.peerName,});

  @override
  State createState() => new ChatScreenState(
    peerId: peerId,
    currentId: currentId,
    peerName: peerName,
  );
}

class ChatScreenState extends State<ChatScreen> {

  ChatScreenState({this.peerId,  this.currentId, this.peerName,});

  final String peerId;
  final String currentId;
  final String peerName;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  String currentName;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    Firestore.instance.collection('users').document('${widget.currentId}')
        .snapshots().listen(
            (data) {
          setState(() {
            currentName = data['userName'];
          });
        }
    );

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {

    if (currentId.hashCode <= peerId.hashCode) {
      groupChatId = '$currentId-$peerId';
    } else {
      groupChatId = '$peerId-$currentId';
    }
    setState(() {});
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child('messages')
        .child(currentId)
        .child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }


  void onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker, 3 = foodImage
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());


      await documentReference.setData({
        'idFrom': currentId,
        'currentName': currentName,
        'idTo': peerId,
        'peerName': peerName,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type
      });
//          .then((value) async {
//
//        await Firestore.instance.document("users/$currentId/chats/$peerId").updateData({
//          'lastMessage': content,
//        });
//
//        await Firestore.instance.collection('users')
//            .where('userId', isEqualTo: currentId)
//            .getDocuments()
//            .then((value2) {
//              setState(() {
//
//                List chats = value2.documents[0]['chats'] as List;
//
//                for(int i = 0; i < chats.length; i++) {
//
//                  if (chats[i]['userId'] == peerId) {
//                    setState(() {
//                      _updateLastMessage(docId: currentId, chat: chats[i], lastMessage: content);
//                    });
//                  }
//                }
//              });
//        });
//      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
    }
  }

  void _updateLastMessage({docId, chat, lastMessage}) async {
    print('lastMessage: $lastMessage');
    var docRef = Firestore.instance.collection('users').document(docId);
    await docRef.updateData({
      '$chat': {
        'lastMessage': lastMessage,
      },
    });
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == currentId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
          // Text
              ? Container(
            child: Text(
              document['content'],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
              : document['type'] == 1 || document['type'] == 3
          // Image
              ? Container(
            child: Material(
              child: new CachedNetworkImage(
                imageUrl: document['content'],
                placeholder: (context, url) => new Center(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoActivityIndicator()
                      : new CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => new Icon(Icons.error),
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
          // Sticker
              : Container(
            child: new Image.asset(
              'images/${document['content']}.gif',
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[

                document['type'] == 0
                    ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : document['type'] == 1
                    ? Container(
                  child: Material(
                    child: new CachedNetworkImage(
                      imageUrl: document['content'],
                      placeholder: (context, url) => new Center(
                        child: Theme.of(context).platform == TargetPlatform.iOS
                            ? new CupertinoActivityIndicator()
                            : new CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
                    : Container(
                  child: new Image.asset(
                    'images/${document['content']}.gif',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
              child: Text(
                DateFormat('dd/MM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == currentId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != currentId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),


              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
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
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: Colors.deepOrange,
              ),
            ),
            color: Colors.white,
          ),


          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.deepOrange, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Сообщение...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.deepOrange,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
        child: Theme.of(context).platform == TargetPlatform.iOS
            ? new CupertinoActivityIndicator()
            : new CircularProgressIndicator(),
      )
          : StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoActivityIndicator()
                    : new CircularProgressIndicator(),
            );
          }
          listMessage = snapshot.data.documents;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
            itemCount: snapshot.data.documents.length,
            reverse: true,
            controller: listScrollController,
          );
        },
      ),
    );
  }
}


class Constants{
  static const String ToBlock = 'Заблокировать';

  static const List<String> choices = <String>[
    ToBlock,
  ];
}