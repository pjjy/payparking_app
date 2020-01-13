import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


class Delinquent extends StatefulWidget {
//  final String id;
  final String plateNo;
//  final String amount;
  final String fullName;
  final String username;
  final String uid;
//
//  Delinquent({Key key, @required this.id, this.plateNo, this.amount,this.location,this.username}) : super(key: key);
  Delinquent({Key key, @required this.fullName, this.uid, this.plateNo, this.username}) : super(key: key);
  @override
  _Delinquent createState() => _Delinquent();
}
class _Delinquent extends State<Delinquent>{


  final _secNameController = TextEditingController();
  var dateToday = DateFormat("yyyy-MM-dd H:mm").format(new DateTime.now());


  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _secNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var _guardSignature = Signature(
      height: 150,
      backgroundColor: Colors.blueGrey,
      onChanged: (points) {
//        print(points);
      },
    );

    var _empSignature = Signature(
      height: 150,
      backgroundColor: Colors.blueGrey,
      onChanged: (points) {
//        print(points);
      },
    );
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,

        title: Text('Delinquent',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {},
            child: Text(widget.username.toString(),style: TextStyle(fontSize: width/36,color: Colors.black),),
          ),
        ],
        textTheme: TextTheme(
            title: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            )
        ),
      ),
      body: ListView(
          physics: BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Text("Plate #: "+widget.plateNo,style: TextStyle(fontSize: width/17)),
          ),
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: new TextField(
             autofocus: false,
            controller: _secNameController,
              decoration: InputDecoration(
              labelText: 'Security Name',
//              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, width/15.0),
//              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
              ),
            ),
          ),
          Divider(
            height: 10,
            color: Colors.transparent,
          ),
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text("Security Signature"),
          ),

          Divider(
            height: height/1000,
            color: Colors.transparent,
          ),
          _guardSignature,
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text("Your Signature"),
          ),
          _empSignature,
          Divider(
            height: height/25,
            color: Colors.transparent,
          ),
          Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  //SHOW EXPORTED IMAGE IN NEW ROUTE
                  IconButton(
                    icon: const Icon(Icons.check),
                    color: Colors.blue,
                    onPressed: () async {

                      if (_guardSignature.isNotEmpty && _empSignature.isNotEmpty) {

                        var guardData = await _guardSignature.exportBytes();
                        var imgGuard = base64.encode(guardData);
                        var empData = await _empSignature.exportBytes();
                        var imgEmp = base64.encode(empData);
                        print(_secNameController.text);
                        print(widget.uid);
                        print(widget.fullName);
                        print(dateToday);
                        print(widget.plateNo);
//                        print(img);
//                        print(data);
//                        Navigator.of(context).push(
//                          MaterialPageRoute(
//                            builder: (BuildContext context) {
//                              return Scaffold(
//                                appBar: AppBar(),
//                                body: Container(
//                                  color: Colors.grey[300],
//                                  child: Image.memory(data),
//                                ),
//                              );
//                            },
//                          ),
//                        );
                      }
                    },
                  ),
                  //CLEAR CANVAS
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        return _guardSignature.clear();
                      });
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}