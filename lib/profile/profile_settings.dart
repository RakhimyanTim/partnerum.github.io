import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:partnerum/profile/edit_user_name.dart';
import 'package:partnerum/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';

class ProfileSettings extends StatefulWidget {

  final FirebaseUser user;
  const ProfileSettings({this.user});

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  SharedPreferences prefs;
  String userImage = '';
  bool isLoading = false;
  File file;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(widget.user.uid)
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
              leading: new IconButton(
                icon: Theme.of(context).platform == TargetPlatform.iOS
                    ? new Icon(Icons.arrow_back_ios)
                    : new Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: new Text('Настройки пользователя'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: new Column(
                    children: <Widget>[
                      new Card(
                        child: new ListTile(
                          leading: new CircleAvatar(
                            radius: 25.0,
                            backgroundImage: document['userImage'] != null
                                ? NetworkImage(document['userImage'])
                                : AssetImage("assets/images/default.png"),
                          ),
                          trailing: new FlatButton(
                            child: new Text('Изменить', style: new TextStyle(color: Theme.of(context).primaryColor),),
                            onPressed: () {
                              _getImage();
                            },
                          ),

                        ),
                      ),
                      new Card(
                        child: new ListTile(
                          title: _buildTitle(document),
                          trailing: new FlatButton(
                            child: new Text('Изменить', style: new TextStyle(color: Theme.of(context).primaryColor),),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditUserName(
                                    user: widget.user,
                                  ),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _buildTitle(document) {
    if (document['userName'] == null) {
      return new Text('Не указано');
    } else if (document['userName'] == '') {
      return new Text('Не указано');
    } else {
      return new Text('${document['userName']}');
    }
  }

  Future _getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        file = image;
        _uploadFile(file);
      });
    }
  }

  Future _uploadFile(File file) async {
    var uuid = new Uuid().v1();
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child("user_image_$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(file);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          userImage = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(widget.user.uid)
              .updateData({'userImage': userImage}).then((data) async {
            await prefs.setString('userImage', userImage);
          });
        });
      } else {
      }
    });
  }
}
