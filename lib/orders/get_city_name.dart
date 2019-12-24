import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class GetCityName extends StatefulWidget {

  @override
  _GetCityNameState createState() => _GetCityNameState();
}

class _GetCityNameState extends State<GetCityName> {

  final TextEditingController _cityNameController = new TextEditingController();

  String searchString;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: new AppBar(
          leading: new IconButton(
              icon: Theme.of(context).platform == TargetPlatform.iOS ?
              new Icon(Icons.arrow_back_ios) : new Icon(Icons.arrow_back),
              onPressed: () {
                if (_cityNameController.text == ''){
                  Fluttertoast.showToast(
                    textColor: Colors.white,
                    backgroundColor: Colors.black54,
                    msg: "Выберите город",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIos: 1,
                  );
                  return;
                }
                Navigator.pop(context, _cityNameController.text);
              }
          ),
          title: new TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Поиск по названию',
            ),
            controller: _cityNameController,

            onChanged: (value) {
              setState(() {
                searchString = value.toLowerCase();
              });
            },
          ),
          automaticallyImplyLeading: true,
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
              icon: new Icon(Icons.clear),
              onPressed: () {
                _cityNameController.clear();
              },
            ),
          ],
          backgroundColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new StreamBuilder<QuerySnapshot>(
              stream: (searchString == null || searchString.trim() == '')
                  ? Firestore.instance.collection('data').document('orders').collection('cities')
                  .orderBy('cityNum').snapshots()
                  : Firestore.instance.collection('data').document('orders').collection('cities')
                  .where('searchIndex', arrayContains: searchString)
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
                return new ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) => _buildSearchItem(context, snapshot.data.documents[index], ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchItem(BuildContext context, DocumentSnapshot document) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new ListTile(
          title: new Text('${document['cityName']}'),
          onTap: () {
            _cityNameController.text = document['cityName'];
            if (_cityNameController.text == null || _cityNameController.text.length == 0){
              return;
            }
            Navigator.pop(context, _cityNameController.text);
            Fluttertoast.showToast(
              textColor: Colors.white,
              backgroundColor: Colors.black54,
              msg: "${_cityNameController.text}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
            );
          },
        ),
//        new Divider(),
      ],
    );
  }
}
