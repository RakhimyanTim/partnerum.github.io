import 'dart:io';

import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ProfileEditPage extends StatefulWidget {

  final FirebaseUser user;
  ProfileEditPage({this.user});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState(
    user: this.user,
  );
}

class _ProfileEditPageState extends State<ProfileEditPage> {

  final FirebaseUser user;
  _ProfileEditPageState({this.user});

  SharedPreferences prefs;
  String userImage = '';
  bool isLoading = false;
  File userFile;

  TextEditingController _userNameController = new TextEditingController();

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

        _userNameController.text = document['userName'];

        return new Scaffold(
          appBar: new AppBar(
            title: new Text(
              'Редактирование профиля',
              style: new TextStyle(fontSize: 20),
            ),
            automaticallyImplyLeading: true,
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
//        actions: <Widget>[
//          new IconButton(
//            icon: new Icon(Icons.check, color: Colors.black),
//            onPressed: () {},
//          ),
//        ],
          ),
          backgroundColor: Colors.white,
          body: new ListView(
            children: <Widget>[
              new Container(
                height: MediaQuery.of(context).size.height / 4,
                child: new Align(
                  alignment: Alignment.center,
                  child: new Stack(
                    children: <Widget>[
                      _buildImage(document),
                      new Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: new Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          child: new ClipOval(
                            child: Material(
                              color: Theme.of(context).primaryColor, // button color
                              child: InkWell(
                                splashColor: Colors.black, // inkwell color
                                child: SizedBox(width: 35, height: 35, child: Icon(Partnerum.edit, size: 20, color: Colors.white,)),
                                onTap: () => _getUserImage(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new ListTile(
                leading: new Icon(Partnerum.profile, color: Theme.of(context).primaryColor,),
                title: new TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  textInputAction: TextInputAction.go,
                  decoration: new InputDecoration(
                    suffixIcon: new IconButton(
                      icon: new Icon(Icons.check),
                      onPressed: () async {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        await Firestore.instance
                            .collection('users')
                            .document(user.uid)
                            .updateData({
                          "userName": _userNameController.text,
                        });
                        Fluttertoast.showToast(
                          textColor: Colors.white,
                          backgroundColor: Colors.black87,
                          msg: "Имя изменено - ${_userNameController.text}",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIos: 1,
                        );
                      },
                    ),
                  ),
                  controller: _userNameController,
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

  Future _getUserImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        userFile = image;
        _uploadUserFile(userFile);
      });
    }
  }

  Future _uploadUserFile(File file) async {
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
              .document(user.uid)
              .updateData({
            'userImage': userImage,
          }).then((data) async {
            await prefs.setString('userImage', userImage);
          });
        });
      } else {
      }
    });
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.black87,
      msg: "Фото загружено",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }
}
