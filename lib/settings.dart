import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final String empNameFn;
  final String userImage;
  final String location;
  Settings({Key key, @required this.empNameFn, this.userImage, this.location}) : super(key: key);
  @override
  _Settings createState() => _Settings();
}

class _Settings extends State<Settings>{
  String image;
  String name;
  String location;
  getData() {
      image = widget.userImage;
      name = widget.empNameFn;
      location = widget.location;
      print(image);
  }

  @override
  void initState(){
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Settings',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        textTheme: TextTheme(
              title: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              )
        ),
      ),
      body:ListView(
        children: <Widget>[
            Divider(
              color: Colors.transparent,
              height: 40.0,
            ),
           Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                  width: 190.0,
                  height: 190.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(image)
                      )
                  )),
              Divider(
                color: Colors.transparent,
                height: 40.0,
              ),
              new Text(name,textScaleFactor: 1.5),
              new Text(location,textScaleFactor: 1.1)
            ],
          )
        ],

      )
    );
  }
}




