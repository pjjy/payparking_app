import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class Delinquent extends StatefulWidget {
//  final String id;
  final String plateNo;
//  final String amount;
//  final String location;
  final String username;
//
//  Delinquent({Key key, @required this.id, this.plateNo, this.amount,this.location,this.username}) : super(key: key);
  Delinquent({Key key, @required this.plateNo,this.username}) : super(key: key);
  @override
  _Delinquent createState() => _Delinquent();
}
class _Delinquent extends State<Delinquent>{


  final _secNameController = TextEditingController();

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
    var _signatureCanvas = Signature(
      height: height/2.5,
      backgroundColor: Colors.blueGrey,
      onChanged: (points) {
        print(points);
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

          Padding(
            padding:EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Text("Signature Pad"),
          ),

          Divider(
            height: height/1000,
            color: Colors.transparent,
          ),
          _signatureCanvas,
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
                      print(_secNameController.text);
                      if (_signatureCanvas.isNotEmpty) {

                        var data = await _signatureCanvas.exportBytes();
                        print(data);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return Scaffold(
                                appBar: AppBar(),
                                body: Container(
                                  color: Colors.grey[300],
                                  child: Image.memory(data),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  //CLEAR CANVAS
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        return _signatureCanvas.clear();
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