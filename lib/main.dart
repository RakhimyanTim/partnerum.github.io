import 'package:partnerum/login_page.dart';
import 'package:partnerum/root_page.dart';
import 'package:partnerum/walk_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {

  final SharedPreferences prefs;
  MyApp({this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: [
        const Locale('ru'), // Russian
      ],

      title: 'Partnerum',

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFFFF6F00),
        accentColor: Color(0xFFFF6F00),
        colorScheme: Theme.of(context).colorScheme.copyWith(
          secondary: Color(0xFFFF6F00),
        ),
        fontFamily: 'Roboto',
      ),

      home: _handleCurrentScreen(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
//        '/walk': (BuildContext context) => new WalkPage(),
        '/root': (BuildContext context) => new RootPage(),
        '/login': (BuildContext context) => new LoginPage(),
      },
    );
  }
  Widget _handleCurrentScreen() {
    bool seen = (prefs.getBool('seen') ?? false);
    if (seen) {
      return new RootPage();
    } else {
      return new WalkPage(prefs: prefs);
    }
  }
}
