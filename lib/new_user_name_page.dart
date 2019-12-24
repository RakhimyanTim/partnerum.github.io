import 'package:partnerum/models/user_model.dart';
import 'package:partnerum/new_user_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewUserNamePage extends StatefulWidget {

  final User user;
  final String userId;

  NewUserNamePage({this.user, this.userId});

  @override
  _NewUserNamePageState createState() => _NewUserNamePageState(
    user: this.user,
    userId: this.userId,
  );
}

class _NewUserNamePageState extends State<NewUserNamePage> {

  final User user;
  final String userId;

  _NewUserNamePageState({this.user, this.userId});

  final _formKey = GlobalKey<FormState>();

  TextEditingController _userNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    _userNameController.text = user.userName;

    return new Form(
      key: _formKey,
      child: new Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: Colors.white,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBtn() {
    return new Container(
      height: 50,
      margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: new BorderRadius.all(
          const Radius.circular(40.0),
        ),
      ),
      child: new FlatButton(
        child: new Text('ДАЛЕЕ', style: new TextStyle(color: Colors.white),),
        onPressed: () => _goToNextPage(),
      ),
    );
  }

  Widget _buildBody() {
    return new ListView(
      children: <Widget>[
        _buildWelcome(),
        _buildName(),
        _buildBtn(),
      ],
    );
  }

  Widget _buildWelcome() {
    return new Container(
//      height: MediaQuery.of(context).size.height / 2,
      margin: new EdgeInsets.symmetric(horizontal: 20, vertical: 40,),
      child: new ListTile(
        title: new Text('Добро пожаловать в \"Partnerum\"!', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: new Text('Давайте знакомиться', style: TextStyle(color: Colors.black, fontSize: 16), textAlign: TextAlign.center,),
        ),
      ),
    );
  }

  Widget _buildName() {
    return new ListTile(
      leading: new Icon(Icons.person, color: Theme.of(context).primaryColor),
      title: new TextFormField(
        decoration: new InputDecoration(
          labelText: 'Имя',
        ),
        controller: _userNameController,
        validator: (value) {
          if (value.isEmpty) {
            return 'Обязательно';
          }
          return null;
        },
        onFieldSubmitted: (term) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          _goToNextPage();
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return new AppBar(
      title: new Text('Ваше имя'),
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

  _goToNextPage() async {
    if (_formKey.currentState.validate()) {

      user.userName = _userNameController.text;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewUserImagePage(user: user, userId: userId,)),
      );
    }
  }
}
