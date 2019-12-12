import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'syncing.dart';
import 'constants.dart';
import 'package:data_connection_checker/data_connection_checker.dart';


class HistoryTransList extends StatefulWidget {
  @override
  _HistoryTransList createState() => _HistoryTransList();
}

class _HistoryTransList extends State<HistoryTransList> {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = PayParkingDatabase();
  List plateData;
  List syncData;
  String alert;

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
    var res = await db.fetchAllHistory();
    setState((){
      plateData = res;
    });

  }

  Future promptSyncData() async{
    bool result = await DataConnectionChecker().hasConnection;
    if(result  == true){
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
    getHistoryTransData();
    getSyncDate();
  }

  @override
   Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text('History',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),),
        textTheme: TextTheme(
            title: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            )
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
                child:ListView.builder(
//                 physics: BouncingScrollPhysics(),
                  itemCount: plateData == null ? 0: plateData.length,
                  itemBuilder: (BuildContext context, int index) {
                    var f = index;
                    f++;
                    var totalAmount = int.parse(plateData[index]["penalty"]) + int.parse(plateData[index]["amount"]);
                    return GestureDetector(
                      onLongPress: (){},
                      child: Card(
                        margin: EdgeInsets.all(5),
                        elevation: 0.0,
                        child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title:Text('$f.Plt No : ${plateData[index]["plateNumber"]}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26.0),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('     Time In : ${plateData[index]["dateTimein"]}',style: TextStyle(fontSize: 17.0),),
                                  Text('     Time Out : ${plateData[index]["dateTimeout"]}',style: TextStyle(fontSize: 17.0),),
                                  Text('     Entrance Fee : '+oCcy.format(int.parse(plateData[index]["amount"])),style: TextStyle(fontSize: 17.0),),
                                  Text('     Penalty : '+oCcy.format(int.parse(plateData[index]["penalty"])),style: TextStyle(fontSize: 17.0),),
                                  Text('     In By : ${plateData[index]["empNameIn"]}',style: TextStyle(fontSize: 17.0),),
                                  Text('     Out By : ${plateData[index]["empNameOut"]}',style: TextStyle(fontSize: 17.0),),
                                  Text('     Location : ${plateData[index]["location"]}',style: TextStyle(fontSize: 17.0),),
                                  Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: 17.0),),
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