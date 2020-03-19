import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  final String empNameFn;
  final String location;
  Settings({Key key, @required this.empNameFn, this.location}) : super(key: key);
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings>{

  String name;
  String location;
  Future getData() async{

      name = widget.empNameFn;
      location = widget.location;
  }


  @override
  void initState(){
    super.initState();
    getData();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    new MaterialApp(
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => new SignInPage(),
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Settings',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        textTheme: TextTheme(
              caption: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              )
        ),
      ),
      body:Column(
          children: <Widget>[
            Expanded(
              child:RefreshIndicator(
                  onRefresh:getData,
                  child:ListView(
                    children: <Widget>[
                      Divider(
                        color: Colors.transparent,
                        height: 100.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Divider(
                            color: Colors.transparent,
                            height: 40.0,
                          ),
                          new Text(name,textScaleFactor: 1.5),
                          new Text(location,textScaleFactor: 1.1),
                          Divider(
                            color: Colors.transparent,
                            height: 60.0,
                          ),
//                          FlatButton(
//                            child: new Text('Log Out'.toString(),style: TextStyle(fontSize: width/30.0, color: Colors.grey),),
//                            color: Colors.transparent,
//                            padding: EdgeInsets.symmetric(horizontal:width/150.0,vertical: 20.0),
//                            shape: RoundedRectangleBorder(
//                                borderRadius: new BorderRadius.circular(30.0),
//                                side: BorderSide(color: Colors.lightBlue)
//                            ),
//                            onPressed:(){
//                              Navigator.push(
//                                   context,
//                                    MaterialPageRoute(builder: (context) => SignInPage()),
//                                  );
////                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  SignInPage()));
//                            },
//                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          FlatButton(
                            child: new Text('172.16.46.130'.toString(),style: TextStyle(fontSize: width/31.0, color: Colors.grey),),
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal:width/150.0,vertical: 20.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                                side: BorderSide(color: Colors.lightBlue)
                            ),
                            onPressed:(){
//                              Navigator.popUntil(context, ModalRoute.withName('/login'));
//                              Navigator.popUntil(context, ModalRoute.withName('/SignInPage'));
                            },
                          ),
//                          FlatButton(
//                            child: new Text('Connect to a Printer'.toString(),style: TextStyle(fontSize: width/31.0, color: Colors.grey),),
//                            color: Colors.transparent,
//                            padding: EdgeInsets.symmetric(horizontal:width/15.0,vertical: 5.0),
//                            shape: RoundedRectangleBorder(
//                                borderRadius: new BorderRadius.circular(35.0),
//                                side: BorderSide(color: Colors.lightBlue)
//                            ),
//                            onPressed:(){
//                              _getDeviceItems();
//                            },
//                          ),
                        ],
                      )
                    ],
                  )
              ),
            ),
          ],
      ),
    );
  }
}




