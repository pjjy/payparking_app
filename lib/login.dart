import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => new _SignInPageState();
}
class _SignInPageState extends State<SignInPage> {
  final db = PayParkingDatabase();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future createDatabase() async{
     await db.init();
  }

  Future logInAttempt() async{
    var res = await db.mysqlLogin(_usernameController.text,_passwordController.text);
    bool result = await DataConnectionChecker().hasConnection;
    if(result == true){
      if(res.length >= 1 && res != 'error'){
//        print(res);
        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeT(logInData:res)),
        );
      }
      if(res == 'error'){
        //print("Wrong Password");
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return CupertinoAlertDialog(
              title: new Text("Wrong credentials"),
              content: new Text("Please check your username or password"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

              ],
            );
          },
        );
      }
    }else{
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("Connection Problem"),
            content: new Text("Please Connect to the wifi hotspot or turn the wifi on"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ],
          );
        },
      );
    }
  }

  @override
  void initState(){
    super.initState();
    createDatabase();

  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final logoSmall = GradientText("Surface",
          gradient: LinearGradient(colors: [Colors.deepOrangeAccent, Colors.blueAccent, Colors.pink]),
          style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 25),
          textAlign: TextAlign.center);

    final logo = GradientText("PayParking",
        gradient: LinearGradient(colors: [Colors.deepOrangeAccent, Colors.blue, Colors.pink]),
        style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 62),
        textAlign: TextAlign.center);



    final username = Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
      child: new TextField(
        autofocus: false,
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
          contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );

    final password = Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
      child: new TextField(
        autofocus: false,
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );


    final loginButton = Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 5.0, top: 10.0),
      child: new Container(
        height: 90.0,
        child: CupertinoButton(
          child: const Text('Log in',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25.0, color: Colors.lightBlue),),
          onPressed:(){
//            Navigator.push(
//              context,
//              MaterialPageRoute(builder: (context) => HomeT()),
//            );
            logInAttempt();
          },
        ),
      ),
    );


    return Container(
      child: Scaffold(
//        appBar: AppBar(
//          backgroundColor: Colors.white,
//          elevation: 0.0,
//          centerTitle: true,
//          title: Text(''),
//          textTheme: TextTheme(
//              title: TextStyle(
//                  color: Colors.black,
//                  fontWeight: FontWeight.bold
//              )
//          ),
//        ),
        backgroundColor: Colors.white,
        body: new Center(
          child: Form(
            key: _formKey,
            child: new ListView(
              physics: new PageScrollPhysics(),
              shrinkWrap: true,
              padding: new EdgeInsets.only(left: 30.0, right: 30.0),
              children: <Widget>[
                SizedBox(height: 100.0),
                logoSmall,
                SizedBox(height: 0.0),
                logo,
                SizedBox(height: 40.0),
                username,
                SizedBox(height: 20.0),
                password,
                SizedBox(height: 20.0),
                loginButton,
                SizedBox(height: 20.0),
              ],
            ),),
        ),
      ),
    );
  }
}
