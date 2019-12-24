import 'package:partnerum/models/walkthrough.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:undraw/undraw.dart';


class WalkPage extends StatefulWidget {

  final SharedPreferences prefs;
  final List<Walkthrough> pages = [
    Walkthrough(
      title: "Трудитесь в посуточной аренде квартир?",
      color: Colors.white,
      description: "Тогда это приложение поможет Вам!",
      illustration: UnDrawIllustration.apartment_rent,
    ),

    Walkthrough(
      title: "Привлекайте клиентов",
      color: Colors.white,
      description: "Работайте с максимальной заполняемостью квартир и зарабатывайте больше.",
      illustration: UnDrawIllustration.order_confirmed,
    ),

    Walkthrough(
      title: "Зарабатывайте больше",
      color: Colors.white,
      description: "Зарабатывайте на лишних заявках 10-20% с общей суммы проживания.",
      illustration: UnDrawIllustration.make_it_rain,
    ),
  ];

  WalkPage({this.prefs});

  @override
  _WalkPageState createState() => _WalkPageState();
}

class _WalkPageState extends State<WalkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Swiper.children(
        autoplay: false,
        index: 0,
        loop: false,
        pagination: new SwiperPagination(
          margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
          builder: new DotSwiperPaginationBuilder(
              color: Colors.black26,
              activeColor: Colors.black,
              size: 6.5,
              activeSize: 8.0),
        ),
        control: SwiperControl(
          iconPrevious: null,
          iconNext: null,
        ),
        children: _getPages(context),
      ),
    );
  }

  List<Widget> _getPages(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.pages.length; i++) {
      Walkthrough page = widget.pages[i];
      widgets.add(
        new Container(
          color: page.color,
          child: new Stack(
            children: <Widget>[
              new Container(
//                margin: new EdgeInsets.symmetric(vertical: 250),
                child: new Align(
                  alignment: Alignment.topCenter,
                  child: new UnDraw(
                    color: Theme.of(context).primaryColor,
                    illustration: page.illustration,
                  ),
                ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 100,),
                child: new Align(
                  alignment: Alignment.topCenter,
                  child: new Text(
                    page.title,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.none,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Roboto",
                    ),
                  ),
                ),
              ),

              new Container(
                margin: new EdgeInsets.symmetric(vertical: 100, horizontal: 16),
                child: new Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    page.description,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w300,
                      fontFamily:'Roboto',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    widgets.add(
      new Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[

            new Container(
              margin: new EdgeInsets.symmetric(vertical: 100,),
              child: new Align(
                alignment: Alignment.topCenter,
                child: new Text(
                  'Добавляйте свои квартиры БЕСПЛАТНО прямо сейчас',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.none,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Roboto",
                  ),
                ),
              ),
            ),

            new Container(
//              margin: new EdgeInsets.symmetric(vertical: 150),
              child: new Align(
                alignment: Alignment.center,
                child: new UnDraw(
                  color: Theme.of(context).primaryColor,
                  illustration: UnDrawIllustration.update,
                ),
              ),
            ),

            new Container(
              margin: new EdgeInsets.symmetric(vertical: 180),
              child: new Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'и получайте заявки от коллег',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300,
                    fontFamily: "Roboto",
                  ),
                ),
              ),
            ),

            new Container(
              margin: new EdgeInsets.symmetric(vertical: 100),
              child: new Align(
                alignment: Alignment.bottomCenter,
                child: new FlatButton(
                  onPressed: () {
                    widget.prefs.setBool('seen', true);

                    Navigator.of(context).pushNamed("/root");

                  },
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    'Жмите',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return widgets;
  }
}