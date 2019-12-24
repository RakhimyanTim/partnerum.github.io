import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetMetroName extends StatefulWidget {
  @override
  _GetMetroNameState createState() => _GetMetroNameState();
}

class _GetMetroNameState extends State<GetMetroName> {

  final _alphForm = GlobalKey<FormState>();
  final _lineForm = GlobalKey<FormState>();
  final _districtForm = GlobalKey<FormState>();

  final TextEditingController _metroNameController = new TextEditingController();

  List stations = [];

  String searchString;

  bool selected = false;



  Map<int, Widget> children = <int, Widget>{
    0: Text("По алфавиту", style: new TextStyle(fontSize: 14),),
    1: Text("По линиям", style: new TextStyle(fontSize: 14),),
    2: Text("По округам", style: new TextStyle(fontSize: 14),),
  };

  getChildren() {
    return <int, Widget>{
      0: Form(
        key: _alphForm,
        child: _buildAlph(),
      ),
      1: Form(
        key: _lineForm,
        child: _buildLine(),
      ),
      2: Form(
        key: _districtForm,
        child: _buildDistrict(),
      ),
    };
  }

  int _sharedValue = 0;

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
              if (stations == null || stations.length == 0){
                Fluttertoast.showToast(
                  textColor: Colors.white,
                  backgroundColor: Colors.black54,
                  msg: "Выберите метро",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                );
                return;
              }
              Navigator.of(context).pop();
            }
          ),
          title: new TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Поиск по названию',
            ),
            controller: _metroNameController,

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
                _metroNameController.clear();
              },
            ),
          ],
          backgroundColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: 500.0,
                child: CupertinoSegmentedControl<int>(
                  children: children,
                  borderColor: Theme.of(context).primaryColor,
                  selectedColor: Theme.of(context).primaryColor,
                  unselectedColor: Colors.white,
                  onValueChanged: (int newValue) {
                    setState(() {
                      _sharedValue = newValue;
                    });
                  },
                  groupValue: _sharedValue,
                ),
              ),
            ),
            getChildren()[_sharedValue],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: new Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).primaryColor,
        child: new FlatButton(
          child: new Text('ПРИМЕНИТЬ', style: new TextStyle(color: Colors.white),),
          onPressed: () {

            if (stations == null || stations.length == 0){
              Fluttertoast.showToast(
                textColor: Colors.white,
                backgroundColor: Colors.black54,
                msg: "Выберите метро",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 1,
              );
              return;
            }

            Navigator.pop(context, stations);

            Fluttertoast.showToast(
              textColor: Colors.white,
              backgroundColor: Colors.black54,
              msg: "Метро (${stations.length})",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
            );
          },
        ),
      ),
    );
  }
  Widget _buildSearchItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      leading: new Container(
        height: 25,
        width: 25,
        decoration: new BoxDecoration(
          color: document['stationLine'] != '15' ?
          document['stationLine'] != '14' ? // white
          document['stationLine'] != '13' ? // blue
          document['stationLine'] != '12' ? // black12
          document['stationLine'] != '11' ? // cyan
          document['stationLine'] != '11A' ? // cyan
          document['stationLine'] != '10' ? // lightGreenAccent
          document['stationLine'] != '9' ? // grey
          document['stationLine'] != '8' ? // yellow
          document['stationLine'] != '8A' ? // yellow
          document['stationLine'] != '7' ? // purple
          document['stationLine'] != '6' ? // orange
          document['stationLine'] != '5' ? // brown
          document['stationLine'] != '4' ? // lightBlueAccent
          document['stationLine'] != '3' ? // blue
          document['stationLine'] != '2' ? // green
          document['stationLine'] != '1' ? // red

          Colors.transparent :
          Colors.red :
          Colors.green :
          Colors.blue :
          Colors.lightBlueAccent :
          Colors.brown :
          Colors.orange :
          Colors.purple :
          Colors.yellow :
          Colors.yellow :
          Colors.grey :
          Colors.lightGreenAccent :
          Colors.cyan :
          Colors.cyan :
          Color(0xFF85D4F3) :
          Colors.blue :
          Colors.white :
          Color(0xFFDE64A1),

          border: Border.all(
            color: document['stationLine'] != '14' ?
            document['stationLine'] != '13' ?
            Colors.transparent :
            Colors.grey :
            Colors.red,
          ),

          shape: BoxShape.circle,
        ),
        child: new Center(
          child: new Text(
            '${document['stationLine']}',
            style: TextStyle(
              color: document['stationLine'] == '14' ? Colors.black : Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      title: new Text('${document['stationName']}', overflow: TextOverflow.fade,),
      trailing: new Checkbox(
        activeColor: Theme.of(context).primaryColor,
        value: stations.contains(document['stationName']),
        onChanged: (bool val) {
          setState(() {
            if (val) {
              stations.add(document['stationName']);
              print('-> $stations');
            } else {
              stations.remove(document['stationName']);
              print('-> $stations');
            }
            selected = val;
          },
          );
        },
      ),
    );
  }


  Widget _buildAlph() {
    return new StreamBuilder<QuerySnapshot>(
      stream: (searchString == null || searchString.trim() == '')
          ? Firestore.instance.collection('data').document('orders').collection('stations').limit(10)
          .orderBy('stationName').snapshots()
          : Firestore.instance.collection('data').document('orders').collection('stations')
          .where('searchIndex', arrayContains: searchString)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Container(
            alignment: FractionalOffset.center,
            child: new Center(
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoActivityIndicator()
                  : new CircularProgressIndicator(),
            ),
          );
        return Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: new ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) => _buildSearchItem(context, snapshot.data.documents[index], ),
          ),
        );
      },
    );
  }

  Widget _buildLine() {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('data').document('orders').collection('lines').orderBy('lineIndex').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Container(
            alignment: FractionalOffset.center,
            child: new Center(
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoActivityIndicator()
                  : new CircularProgressIndicator(),
            ),
          );
        return Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: new ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) => _buildLineItem(context, snapshot.data.documents[index], ),
          ),
        );
      },
    );
  }

  Widget _buildDistrict() {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('data').document('orders').collection('districts').orderBy('districtName').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Container(
            alignment: FractionalOffset.center,
            child: new Center(
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? new CupertinoActivityIndicator()
                  : new CircularProgressIndicator(),
            ),
          );
        return Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: new ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) => _buildDistrictItem(context, snapshot.data.documents[index], ),
          ),
        );
      },
    );
  }

  Widget _buildLineItem(BuildContext context, DocumentSnapshot document) {
    return new ExpansionTile(
      leading: new Container(
        height: 25,
        width: 25,
        decoration: new BoxDecoration(
          color: document['lineNum'] != '15' ? // purpleAccent
          document['lineNum'] != '14' ? // white
          document['lineNum'] != '13' ? // blue
          document['lineNum'] != '12' ? // black12
          document['lineNum'] != '11' ? // cyan
          document['lineNum'] != '11A' ? // cyan
          document['lineNum'] != '10' ? // lightGreenAccent
          document['lineNum'] != '9' ? // grey
          document['lineNum'] != '8' ? // yellow
          document['lineNum'] != '8A' ? // yellow
          document['lineNum'] != '7' ? // purple
          document['lineNum'] != '6' ? // orange
          document['lineNum'] != '5' ? // brown
          document['lineNum'] != '4' ? // lightBlueAccent
          document['lineNum'] != '3' ? // blue
          document['lineNum'] != '2' ? // green
          document['lineNum'] != '1' ? // red

          Colors.transparent :
          Colors.red :
          Colors.green :
          Colors.blue :
          Colors.lightBlueAccent :
          Colors.brown :
          Colors.orange :
          Colors.purple :
          Colors.yellow :
          Colors.yellow :
          Colors.grey :
          Colors.lightGreenAccent :
          Colors.cyan :
          Colors.cyan :
          Color(0xFF85D4F3)  :
          Colors.blue :
          Colors.white :
          Color(0xFFDE64A1),

          border: Border.all(
            color: document['lineNum'] != '14' ?
            document['lineNum'] != '13' ?
            Colors.transparent :
            Colors.grey :
            Colors.red,
          ),

          shape: BoxShape.circle,
        ),
        child: new Center(
          child: new Text(
            '${document['lineNum']}',
            style: TextStyle(
              color: document['lineNum'] == '14' ? Colors.black : Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      title: new Text(
        '${document['lineName']}',
        overflow: TextOverflow.fade,
      ),
      children: <Widget>[
        new StreamBuilder<QuerySnapshot>(
          stream: document['lineNum'] != '15' ? // purpleAccent
          document['lineNum'] != '14' ? // white
          document['lineNum'] != '13' ? // blue
          document['lineNum'] != '12' ? // black12
          document['lineNum'] != '11' ? // cyan
          document['lineNum'] != '11A' ? // cyan
          document['lineNum'] != '10' ? // lightGreenAccent
          document['lineNum'] != '9' ? // grey
          document['lineNum'] != '8' ? // yellow
          document['lineNum'] != '8A' ? // yellow
          document['lineNum'] != '7' ? // purple
          document['lineNum'] != '6' ? // orange
          document['lineNum'] != '5' ? // brown
          document['lineNum'] != '4' ? // lightBlueAccent
          document['lineNum'] != '3' ? // blue
          document['lineNum'] != '2' ? // green
          document['lineNum'] != '1' ? // red

          Firestore.instance.collection('data').document('orders').collection('stations').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '1').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '2').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '3').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '4').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '5').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '6').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '7').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '8A').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '8').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '9').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '10').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '11A').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '11').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '12').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '13').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '14').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationLine', isEqualTo: '15').orderBy('stationName').snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Container(
                alignment: FractionalOffset.center,
                child: new Center(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoActivityIndicator()
                      : new CircularProgressIndicator(),
                ),
              );
            return Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: new ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) => _buildStationItem(context, snapshot.data.documents[index], ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDistrictItem(BuildContext context, DocumentSnapshot document) {
    return new ExpansionTile(
      title: new Text(
        '${document['districtName']}',
        overflow: TextOverflow.fade,
      ),
      children: <Widget>[
        new StreamBuilder<QuerySnapshot>(
          stream: document['districtName'] != 'ВОСТОЧНЫЙ ОКРУГ' ? // white
          document['districtName'] != 'ЗАПАДНЫЙ ОКРУГ' ? // blue
          document['districtName'] != 'НОВОМОСКОВСКИЙ ОКРУГ' ? // black12
          document['districtName'] != 'СЕВЕРНЫЙ ОКРУГ' ? // cyan
          document['districtName'] != 'СЕВЕРО-ВОСТОЧНЫЙ ОКРУГ' ? // cyan
          document['districtName'] != 'СЕВЕРО-ЗАПАДНЫЙ ОКРУГ' ? // lightGreenAccent
          document['districtName'] != 'ЦЕНТРАЛЬНЫЙ ОКРУГ' ? // grey
          document['districtName'] != 'ЮГО-ВОСТОЧНЫЙ ОКРУГ' ? // yellow
          document['districtName'] != 'ЮГО-ЗАПАДНЫЙ ОКРУГ' ? // yellow
          document['districtName'] != 'ЮЖНЫЙ ОКРУГ' ? // purple

          Firestore.instance.collection('data').document('orders').collection('stations').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'ЮЖНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'ЮГО-ЗАПАДНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'ЮГО-ВОСТОЧНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'ЦЕНТРАЛЬНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'СЕВЕРО-ЗАПАДНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'СЕВЕРО-ВОСТОЧНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'СЕВЕРНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'НОВОМОСКОВСКИЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'ЗАПАДНЫЙ ОКРУГ').orderBy('stationName').snapshots() :
          Firestore.instance.collection('data').document('orders').collection('stations').where('stationDistrict', isEqualTo: 'ВОСТОЧНЫЙ ОКРУГ').orderBy('stationName').snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Container(
                alignment: FractionalOffset.center,
                child: new Center(
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoActivityIndicator()
                      : new CircularProgressIndicator(),
                ),
              );
            return Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: new ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) => _buildStationItem2(context, snapshot.data.documents[index], ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStationItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      title: new Text('${document['stationName']}', overflow: TextOverflow.fade,),
      trailing: Checkbox(
          activeColor: Theme.of(context).primaryColor,
          value: stations.contains(document['stationName']),
          onChanged: (bool val) {
            setState(() {
              if (val) {
                stations.add(document['stationName']);
                print('-> $stations');
              } else {
                stations.remove(document['stationName']);
                print('-> $stations');
              }
              selected = val;
            });
          }),
    );
  }

  Widget _buildStationItem2(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      leading: new Container(
        height: 25,
        width: 25,
        decoration: new BoxDecoration(
          color: document['stationLine'] != '15' ?
          document['stationLine'] != '14' ? // white
          document['stationLine'] != '13' ? // blue
          document['stationLine'] != '12' ? // black12
          document['stationLine'] != '11' ? // cyan
          document['stationLine'] != '11A' ? // cyan
          document['stationLine'] != '10' ? // lightGreenAccent
          document['stationLine'] != '9' ? // grey
          document['stationLine'] != '8' ? // yellow
          document['stationLine'] != '8A' ? // yellow
          document['stationLine'] != '7' ? // purple
          document['stationLine'] != '6' ? // orange
          document['stationLine'] != '5' ? // brown
          document['stationLine'] != '4' ? // lightBlueAccent
          document['stationLine'] != '3' ? // blue
          document['stationLine'] != '2' ? // green
          document['stationLine'] != '1' ? // red

          Colors.transparent :
          Colors.red :
          Colors.green :
          Colors.blue :
          Colors.lightBlueAccent :
          Colors.brown :
          Colors.orange :
          Colors.purple :
          Colors.yellow :
          Colors.yellow :
          Colors.grey :
          Colors.lightGreenAccent :
          Colors.cyan :
          Colors.cyan :
          Color(0xFF85D4F3)  :
          Colors.blue :
          Colors.white :
          Color(0xFFDE64A1),

          border: Border.all(
            color: document['stationLine'] != '14' ?
            document['stationLine'] != '13' ?
            Colors.transparent :
            Colors.grey :
            Colors.red,
          ),

          shape: BoxShape.circle,
        ),
        child: new Center(
          child: new Text(
            '${document['stationLine']}',
            style: TextStyle(
              color: document['stationLine'] == '14' ? Colors.black : Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      title: new Text('${document['stationName']}', overflow: TextOverflow.fade,),
      trailing: Checkbox(
          activeColor: Theme.of(context).primaryColor,
          value: stations.contains(document['stationName']),
          onChanged: (bool val) {
            setState(() {
              if (val) {
                stations.add(document['stationName']);
                print('-> $stations');
              } else {
                stations.remove(document['stationName']);
                print('-> $stations');
              }
              selected = val;
            });
          }),
    );
  }
}
