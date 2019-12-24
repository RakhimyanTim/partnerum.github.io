import 'dart:io';

import 'package:partnerum/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NewUserImagePage extends StatefulWidget {

  final User user;
  final String userId;
  NewUserImagePage({this.user, this.userId});

  @override
  _NewUserImagePageState createState() => _NewUserImagePageState(
    user: this.user,
    userId: this.userId,
  );
}

class _NewUserImagePageState extends State<NewUserImagePage> {

  final User user;
  final String userId;
  _NewUserImagePageState({this.user, this.userId});

  final _formKey = GlobalKey<FormState>();

  TextEditingController _userImageController = new TextEditingController();

  SharedPreferences prefs;
  String userImage = '';
  bool isLoading = false;
  File userFile;

  @override
  Widget build(BuildContext context) {
    return new Form(
      key: _formKey,
      child: new StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(userId)
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
              appBar: _buildAppBar(),
              backgroundColor: Colors.white,
              body: _buildBody(document),
            );
          }
      ),
    );
  }

  Widget _buildAppBar() {
    return new AppBar(
      title: new Text('Ваше фото'),
      automaticallyImplyLeading: true,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      textTheme: TextTheme(
        title: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBody(document) {

    _userImageController.text = document['userImage'];

    return new ListView(
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
                          child: SizedBox(width: 35, height: 35, child: Icon(Icons.edit, size: 20, color: Colors.white,)),
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
          leading: new Icon(Icons.person, color: Theme.of(context).primaryColor),
          title: new TextFormField(
            decoration: new InputDecoration(
              hintText: 'Ссылка на фото',
            ),
            controller: _userImageController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Обязательно';
              }
              return null;
            },
            onFieldSubmitted: (term) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              _goToRootPage();
            },
          ),
        ),
        new Container(
          height: 50,
          margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: new BorderRadius.all(
              const Radius.circular(40.0),
            ),
          ),
          child:  new FlatButton(
            child: new Text('ДАЛЕЕ', style: new TextStyle(color: Colors.white),),
            onPressed: () => _goToRootPage(),
          ),
        )
      ],
    );
  }

  Widget _buildImage(document) {
    if (document['userImage'] != null) {
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
        child: new Center(child: new Text('Нет\nфото',
          textAlign: TextAlign.center,
          style: new TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),),
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
              .document(userId)
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
      backgroundColor: Colors.black54,
      msg: "Фото загружено",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  _goToRootPage() async {
    if (_formKey.currentState.validate()) {
      Firestore.instance
          .collection('users')
          .document(userId)
          .updateData({
        "userName": user.userName,
      });
      Navigator.of(context).pushNamed("/root");
    }
  }
}
