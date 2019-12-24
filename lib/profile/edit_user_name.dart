import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnerum/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditUserName extends StatefulWidget {

  final FirebaseUser user;
  const EditUserName({this.user});

  @override
  _EditUserNameState createState() => _EditUserNameState();
}

class _EditUserNameState extends State<EditUserName> {

  final TextEditingController userNameController = new TextEditingController();

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

          userNameController.text = snapshot.data['userName'];

          return new Scaffold(
            appBar: AppBar(
              leading: new IconButton(
                icon: Theme.of(context).platform == TargetPlatform.iOS
                    ? new Icon(Icons.arrow_back_ios)
                    : new Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: new Text('Имя пользователя', style: new TextStyle(color: Colors.black, ),),
//              automaticallyImplyLeading: false,
//              centerTitle: true,
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
                new IconButton(
                  icon: Icon(Icons.check, color: Colors.deepOrange,),
                  onPressed: () {
                    _addData();
                    Navigator.pop(context);
                  },
                ),
              ],
              backgroundColor: Colors.white,
            ),
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: new Form(
                child: new ListView(
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: (snapshot.data['userName'] != '')
                            ? buildTextField(name: snapshot.data['userName'], controller: userNameController)
                            : buildTextField(name: "Ваше имя", controller: userNameController),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: new Container(
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).primaryColor,
              child: new FlatButton(
                child: new Text('ОТПРАВИТЬ', style: new TextStyle(color: Colors.white),),
                onPressed: () {
                  _addData();
                  Navigator.pop(context, userNameController.text);
                  Fluttertoast.showToast(
                    textColor: Colors.white,
                    backgroundColor: Colors.black54,
                    msg: "Имя изменено",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                  );
                },
              ),
            ),
          );
        }
    );
  }
  void _addData() {
    Firestore.instance
        .collection('users')
        .document(widget.user.uid)
        .updateData({
      "userName": userNameController.text,
    });
  }

  Widget buildTextField({String name, TextEditingController controller}) {
    return new TextFormField(
      controller: controller,
      decoration: new InputDecoration(
        labelText: 'Имя',
      ),
    );
  }
}
