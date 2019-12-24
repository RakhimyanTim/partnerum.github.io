import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnerum/home_page.dart';

class WelcomePage extends StatefulWidget {

  WelcomePage({Key key, this.fbAuth}) : super(key: key);
  final FirebaseAuth fbAuth;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    widget.fbAuth.currentUser().then((FirebaseUser user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(builder: (context, constraint) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: constraint.maxWidth,
                  ),
                  Image.asset(
                    "assets/images/logo.png",
                    width: 150,
                    height: 150,
                  ),
                  new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 150.0),
                    child: new Divider(),
                  ),
                  new Container(
                    margin: new EdgeInsets.only(top: 20.0),
                    child: Text("Добро пожаловать",
                        style: TextStyle(fontSize: 25, color: Colors.amber)),
                  ),
                  SizedBox(height: 20),
                  Text("В Мир Partnerum"
                      "",
                      style: TextStyle(fontSize: 15)),
                  SizedBox(height: 20),
                  MaterialButton(
                      color: Colors.black,
                      onPressed: () {
//                        print('user: $_user');
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                            builder: (context) => HomePage(user: _user,),
//                          ),
//                        );
                      },
                      child: Text(
                        "Поехали",
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            );
          })),
    );
  }

}
