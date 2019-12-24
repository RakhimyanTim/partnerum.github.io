import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:native_share/native_share.dart';
import 'package:partnerum/widgets/partnerum_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderOfferDetailPage extends StatefulWidget {

  final FirebaseUser user;
  final String offerId;

  OrderOfferDetailPage({this.user, this.offerId});

  @override
  _OrderOfferDetailPageState createState() => _OrderOfferDetailPageState(
    user: this.user,
    offerId: this.offerId,
  );
}

class _OrderOfferDetailPageState extends State<OrderOfferDetailPage> {

  final FirebaseUser user;
  final String offerId;

  _OrderOfferDetailPageState({this.user, this.offerId});

  int photoIndex = 0;
  ScrollController _scrollController;
  double _appBarHeight;
  List images = [];

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('offers')
            .document(offerId)
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

          images = document['offerImages'] as List;

          return new Scaffold(
            appBar: _buildAppBar(user, document),
            backgroundColor: Colors.white,
            body: _buildBody(document),
          );
        }
    );
  }

  Widget _buildAppBar(user, document) {
    return new AppBar(
      leading: new IconButton(
        icon: Theme.of(context).platform == TargetPlatform.iOS
            ? new Icon(Icons.arrow_back_ios)
            : new Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('О квартире'),
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
      centerTitle: false,
      textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          )
      ),
      backgroundColor: Colors.white,
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Partnerum.share),
          onPressed: () async {
            final _string = images.reduce((value, element) => value + '\n\nФото -> ' + element);
            await NativeShare.share({'title':'${document['offerAddressName']}', 'image': '${images[0]}', 'url': '$_string'});
          },
        ),
      ],
    );
  }

  Widget _buildBody(document) {
    if (images == null || images.length == 0) {
      return _buildSubBody(document);
    } else {
      return new NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          _appBarHeight = MediaQuery.of(context).size.height / 3;
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: false,
              expandedHeight: _appBarHeight,
              pinned: false,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      child: new Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: new CachedNetworkImage(
                              imageUrl: images[photoIndex],
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                              placeholder: (context, url) => Center(
                                  child: Theme.of(context).platform == TargetPlatform.iOS
                                      ? new CupertinoActivityIndicator()
                                      : new CircularProgressIndicator()
                              ),
                              fadeOutDuration: new Duration(seconds: 1),
                              fadeInDuration: new Duration(seconds: 3),
                              fit: BoxFit.cover,
                            ),
                          ),
//                          new SelectedPhoto(numberOfDots: itemImages.length, photoIndex: photoIndex),
                          new Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: new IconButton(
                                      icon: Theme.of(context).platform == TargetPlatform.iOS
                                          ? new Icon(Icons.arrow_back_ios, size: 15, color: Theme.of(context).primaryColor,)
                                          : new Icon(Icons.arrow_back, size: 15, color: Theme.of(context).primaryColor,),
                                      onPressed: () => _previousImage(),
                                    ),
                                  ),
                                  new CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: new IconButton(
                                      icon: Theme.of(context).platform == TargetPlatform.iOS
                                          ? new Icon(Icons.arrow_forward_ios, size: 15, color: Theme.of(context).primaryColor,)
                                          : new Icon(Icons.arrow_forward, size: 15, color: Theme.of(context).primaryColor,),
                                      onPressed: () => _nextImage(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _buildSubBody(document),
      );
    }
  }

  Widget _buildSubBody(document) {
    return new SingleChildScrollView(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildCity(document),
          _buildMetro(document),
          _buildDistance(document),
          _buildAddress(document),
          _buildPrice(document),
          _buildRooms(document),
          _buildInfo(document),
        ],
      ),
    );
  }

  Widget _buildInfo(document) {
    return new ExpansionTile(
      leading: new Icon(Partnerum.info, color: Theme.of(context).primaryColor),
      title: new Text('Информация'),
      children: <Widget>[
        new Container(
          margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: new Align(
            alignment: Alignment.topLeft,
            child: document['offerInfoField'] != '' ?
            new Text('${document['offerInfoField']}') :
            new Text('Не указана'),
          ),
        ),
      ],
    );
  }

  Widget _buildRooms(document) {
    return new ListTile(
      leading: new Icon(Partnerum.rooms, color: Theme.of(context).primaryColor),
      title: new Text('Количество комнат'),
      subtitle: new Text('${document['offerRoomsCount']}'),
    );
  }

  Widget _buildPrice(document) {
    return new ListTile(
      leading: new Icon(Partnerum.ruble, color: Theme.of(context).primaryColor),
      title: new Text('Цена'),
      subtitle: new Text('От ${document['offerStartPrice']} до ${document['offerEndPrice']} руб/сут',),
    );
  }

  Widget _buildAddress(document) {
    return new ListTile(
      leading: new Icon(Partnerum.address, color: Theme.of(context).primaryColor),
      title: new Text('Адрес'),
      subtitle: new Text('${document['offerAddressName']}'),
    );
  }

  Widget _buildDistance(document) {
    if (document['offerCityName'] == 'Москва') {
      return new ListTile(
        leading: new Icon(Partnerum.walk, color: Theme.of(context).primaryColor),
        title: new Text('Пешком до метро'),
        subtitle: document['offerDistanceTime'] == 'Неважно'
            ? new Text('${document['offerDistanceTime']}')
            : new Text('${document['offerDistanceTime']} мин'),
      );
    } else {
      return new Container();
    }
  }

  Widget _buildCity(document) {
    return new ListTile(
      leading: new Icon(Partnerum.city, color: Theme.of(context).primaryColor),
      title: new Text('Город'),
      subtitle: new Text('${document['offerCityName']}'),
    );
  }

  Widget _buildMetro(document) {
    return document['offerCityName'] == 'Москва' ? new ExpansionTile(
      leading: new Icon(Partnerum.metro, color: Theme.of(context).primaryColor),
      title: new Text('Станции метро (${document['offerMetroStantion'].length})'),
      children: <Widget>[
        new Container(
          margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: new Align(
            alignment: Alignment.topLeft,
            child: new ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: document['offerMetroStantion'].length,
              itemBuilder: (context, index) {
                return new Text('${document['offerMetroStantion'][index]}', style: new TextStyle(fontSize: 14, color: Colors.grey),);
              },
            ),
          ),
        ),
      ],
    ) : new Container();
  }

  void _previousImage() {
    setState(() {
      photoIndex = photoIndex > 0 ? photoIndex - 1 : 0;
    });
  }

  void _nextImage() {
    setState(() {
      photoIndex = photoIndex < images.length - 1 ? photoIndex + 1 : photoIndex;
    });
  }

}

class SelectedPhoto extends StatelessWidget {

  final int numberOfDots;
  final int photoIndex;

  SelectedPhoto({this.numberOfDots, this.photoIndex});

  Widget _inactivePhoto() {
    return new Container(
        child: new Padding(
          padding: const EdgeInsets.only(left: 3.0, right: 3.0),
          child: Container(
            height: 8.0,
            width: 8.0,
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4.0)
            ),
          ),
        )
    );
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 0.0,
                    blurRadius: 2.0
                )
              ]
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];

    for(int i = 0; i< numberOfDots; ++i) {
      dots.add(
          i == photoIndex ? _activePhoto(): _inactivePhoto()
      );
    }

    return dots;
  }


  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}