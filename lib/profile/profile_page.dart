import 'dart:io';

import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  ProfilePage({this.user, this.onSignedOut});

  @override
  _ProfilePageState createState() => _ProfilePageState(
    user: this.user,
    onSignedOut: this.onSignedOut,
  );
}

class _ProfilePageState extends State<ProfilePage> {

  final FirebaseUser user;
  final VoidCallback onSignedOut;

  _ProfilePageState({this.user, this.onSignedOut});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  SharedPreferences prefs;
  String userPasImage = '';
  bool isLoading = false;
  File userPasFile;

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
            appBar: new AppBar(
              title: new Text(
                'Профиль',
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
                    fontSize: 22,
                  )
              ),
              backgroundColor: Colors.white,
              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.exit_to_app, color: Colors.black),
                  onPressed: () => _signOut(),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: new ListView(
              children: <Widget>[
                new Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: new Stack(
                    children: <Widget>[
                      new Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: new ClipOval(
                            child: Material(
                              color: Theme.of(context).primaryColor, // button color
                              child: InkWell(
                                splashColor: Colors.black, // inkwell color
                                child: SizedBox(width: 35, height: 35, child: Icon(Partnerum.edit, size: 20, color: Colors.white,)),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileEditPage(user: user),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      new Align(
                        alignment: Alignment.center,
                        child: _buildImage(document),
                      ),
                      new Align(
                        alignment: Alignment.bottomCenter,
                        child: new ListTile(
                          title: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                document['userName'],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              document['isConfirmed'] == true ? new Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: new Icon(Partnerum.correct, color: Colors.green,),
                              ) : new Row(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: new StreamBuilder(
                          stream: Firestore.instance
                              .collection('orders')
                              .where('userId', isEqualTo: user.uid)
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

                            return new Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Text(
                                  '${snapshot.data.documents.length}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                new Text(
                                  'Заявок',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            );
                          },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: new StreamBuilder(
                        stream: Firestore.instance
                            .collection('offers')
                            .where('userId', isEqualTo: user.uid)
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
                          return new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                '${snapshot.data.documents.length}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              new Text(
                                'Квартир',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                _buildConfirm(document),
                Center(
                  child: new Container(
                    decoration: new BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: new BorderRadius.all(Radius.circular(5))),
                    child: new FlatButton(
                      child: new Text(
                        document['userPasImage'] == '' ? 'Загрузить документ' : 'Обновить документ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => _getUserPasImage(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _buildImage(document) {
    if (document['userImage'] != null && document['userImage'] != '') {
      return new CachedNetworkImage(
        imageUrl: '${document['userImage']}',
        imageBuilder: (context, imageProvider) => Container(
          width: 120,
          height: 120,
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
          width: 120,
          height: 120,
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
      return new Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          shape: BoxShape.circle,
        ),
        child: new Center(child: new Text('${document['userName'][0]}',
          style: new TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 26),),
        ),
      );

    }
  }

  Widget _buildConfirm(document) {
    if (document['userPasImage'] == '') {
      return new Container(
        margin: const EdgeInsets.all(20),
        decoration: new BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            borderRadius: new BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: new ListTile(
            subtitle: new Text(
              'Ваш профиль не подтвержден. Чтобы подтвердить его, загрузите фото паспорта.',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (document['isConfirmed'] == false) {
      return new Container(
        margin: const EdgeInsets.all(20),
        decoration: new BoxDecoration(
            color: Colors.green.withOpacity(0.3),
            borderRadius: new BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: new ListTile(
            subtitle: new Text(
              'Фото паспорта ожидает проверки админа.',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      return new Container(
        margin: const EdgeInsets.all(20),
      );
    }
  }

  Future _getUserPasImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        userPasFile = image;
        _uploadUserPasFile(userPasFile);
      });
    }
  }

  Future _uploadUserPasFile(File file) async {
    var uuid = new Uuid().v1();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child("user_pas_image_$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(file);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          userPasImage = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(user.uid)
              .updateData({
            'userPasImage': userPasImage,
            'isConfirmed': false,
          }).then((data) async {
            await prefs.setString('userPasImage', userPasImage);
          });
        });
      } else {
      }
    });
    Fluttertoast.showToast(
      textColor: Colors.black,
      backgroundColor: Colors.black.withOpacity(0.1),
      msg: "Докуент загружен",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  _signOut() async {
    try {
      await _auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

}
