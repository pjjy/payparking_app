import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'syncing.dart';
import 'constants.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'dart:async';

class HistoryTransList extends StatefulWidget {
  final String location;
 final String empId;
  HistoryTransList({Key key, @required this.location,this.empId}) : super(key: key);
  @override
  _HistoryTransList createState() => _HistoryTransList();
}

class _HistoryTransList extends State<HistoryTransList> {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = PayParkingDatabase();
  List plateData;
  List syncData;
  String alert;
  List plateData2;
  TextEditingController _textController;

  Future getSyncDate() async{
    var res = await db.fetchSync();
    setState((){
      syncData = res;
    });

    if(syncData.isEmpty){
//        print("way sud");
    }else{
//      print(syncData[0]['syncDate']);
    }
   }// to be delete soon



   Future insertSyncDate() async{
    await db.insertSyncDate(DateFormat("yyyy-MM-dd : hh:mm a").format(new DateTime.now()).toString());
    getSyncDate();
   }

   Future getHistoryTransData() async {
    listStat = false;
    var res = await db.fetchAllHistory();
    setState((){
      plateData = res;
    });
   }

   promptSyncData() {

//    if(result == true){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("Confirm Data Sync"),
            content: new Text("Are you sure you want to sync?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Confirm"),
                onPressed: () {
                    insertSyncDate();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SyncingPage()),
                    ).then((result) {
                      Navigator.of(context).pop();
                    });
                },
              ),
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

  bool listStat = false;
  Future _onChanged(text) async {
    listStat = true;
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true){
      var res = await db.ofFetchSearchHistory(text);
      setState((){
        plateData2 = res;
      });
    }
    else{
      showDialog(
        barrierDismissible: true,
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
                onPressed:() {
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
    getHistoryTransData();
    getSyncDate();
    _textController = TextEditingController();
  }

  @override
   Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('History',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        leading: new IconButton(
          icon: new Icon(Icons.search, color: Colors.black),
          onPressed: () {
            showDialog(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return CupertinoAlertDialog(
                  title: new Text("Search Plate#"),
                  content: new CupertinoTextField(
                    controller: _textController,
                    autofocus: true,
//                    onChanged: _onChanged,
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Search"),
                      onPressed:() {
                        _onChanged(_textController.text);
                        _textController.clear();
                        Navigator.of(context).pop();
                      },
                    ),
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed:() {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),

        actions: <Widget>[
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: choiceAction,
            itemBuilder: (BuildContext context){
              return Constants.choices.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),

      body:Column(
        children: <Widget>[
          Expanded(
            child:RefreshIndicator(
              onRefresh: getHistoryTransData,
              child:Scrollbar(
                child: listStat == true ?
                ListView.builder(
                  itemCount: plateData2 == null ? 0: plateData2.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    f++;
                    var totalAmount = int.parse(plateData2[index]["penalty"]) + int.parse(plateData2[index]["amount"]);
                    return GestureDetector(
                      onLongPress: (){
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return CupertinoAlertDialog(
                              title: new Text("Manager's key"),
                              content: new Column(
                                children: <Widget>[
                                  new CupertinoTextField(
                                    autofocus: true,
                                    placeholder: "Username",

                                  ),
                                  Divider(),
                                  new CupertinoTextField(
                                    autofocus: true,
                                    placeholder: "Password",

                                    obscureText: true,
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                    child: new Text("Proceed"),
                                    onPressed:(){
                                      Navigator.of(context).pop();

                                    }
                                ),
                                new FlatButton(
                                  child: new Text("Close"),
                                  onPressed:(){
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.all(5),
                        elevation: 0.0,
                        child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title:Text('$f.Plt No : ${plateData2[index]["plateNumber"]}'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize:  width/20),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('     Time In : ${plateData2[index]["dateTimein"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Time Out : ${plateData2[index]["dateTimeout"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Entrance Fee : '+oCcy.format(int.parse(plateData2[index]["amount"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Charge : '+oCcy.format(int.parse(plateData2[index]["penalty"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Trans Code : ${plateData2[index]["checkDigit"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     In By : ${plateData2[index]["empNameIn"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Out By : ${plateData2[index]["empNameOut"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Location : ${plateData2[index]["location"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/30),),
                                ],
                              ),
//                               trailing: Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                :ListView.builder(
//                 physics: BouncingScrollPhysics(),
                  itemCount: plateData == null ? 0: plateData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    Color cardColor;
                    f++;
                    if(int.parse(plateData[index]["penalty"]) > 0){
                      cardColor = Colors.redAccent.withOpacity(.2);
                    }else{
                      cardColor = Colors.white;
                    }
                    var totalAmount = int.parse(plateData[index]["penalty"]) + int.parse(plateData[index]["amount"]);
                    return GestureDetector(
                      onLongPress: (){
                        if(int.parse(plateData[index]["penalty"])!=0){
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return CupertinoAlertDialog(
                                title: new Text("Info"),
                                content: new Text("Press proceed to reprint"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Proceed"),
                                    onPressed:() async{
                                      Navigator.of(context).pop();
//                                      print(widget.empId);
//                                      print('reprint_penalty');
                                        await db.olSendTransType(widget.empId,'reprint_penalty');
                                        await db.olPenaltyReprint(plateData[index]['d_uid'],plateData[index]['d_transcode'],plateData[index]['d_Plate'],plateData[index]['d_dateTimeIn'],plateData[index]['d_dateTimeout'],plateData[index]['d_amount'],plateData[index]['d_penalty'],plateData[index]['d_in_empid'],plateData[index]['out_empid'],plateData[index]['d_location']);
                                        AppAvailability.launchApp("com.example.cpcl_test_v1").then((_) {
                                        });
//                                        print(plateData[index]['d_uid']);
//                                        print(plateData[index]['d_transcode']);
//                                        print(plateData[index]['d_Plate']);
//                                        print(plateData[index]['d_dateTimeIn']);
//                                        print(plateData[index]['d_dateTimeout']);
//                                        print(plateData[index]['d_amount']);
//                                        print(plateData[index]['d_penalty']);
//                                        print(plateData[index]['d_in_empid']);
//                                        print(plateData[index]['out_empid']);
//                                        print(plateData[index]['d_location']);
                                    },
                                  ),
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
                      },
                      child: Card(
                        color: cardColor,
                        margin: EdgeInsets.all(5),
                        elevation: 0.0,
                        child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title:Text('$f.Plt No : ${plateData[index]["plateNumber"]}'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold,fontSize:  width/20),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('     Time In : ${plateData[index]["dateTimein"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Time Out : ${plateData[index]["dateTimeout"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Entrance Fee : '+oCcy.format(int.parse(plateData[index]["amount"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Charge : '+oCcy.format(int.parse(plateData[index]["penalty"])),style: TextStyle(fontSize: width/30),),
                                  Text('     Trans Code : ${plateData[index]["checkDigit"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     In By : ${plateData[index]["empNameIn"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Out By : ${plateData[index]["empNameOut"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Location : ${plateData[index]["location"]}',style: TextStyle(fontSize: width/30),),
                                  Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/30),),
                                ],
                              ),
//                               trailing: Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }

  void choiceAction(String choice){
    if(choice == Constants.dbSync){
      promptSyncData();
    }else if(choice == Constants.dlReport){
      print('daily report');
    }else if(choice == Constants.rgReport){
      print('range report');
    }
  }

}