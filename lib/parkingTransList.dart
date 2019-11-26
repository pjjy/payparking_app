import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';


class ParkTransList extends StatefulWidget {
  @override
  _ParkTransList createState() => _ParkTransList();
}

class _ParkTransList extends State<ParkTransList> {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = PayParkingDatabase();
  List plateData;





  Future getTransData() async {
    var res = await db.fetchAll();
    setState((){
      plateData = res;
    });
  }



  Future passDataToHistoryWithOutPay(id,plateNo,dateTimeIn,dateTimeNow,amount,user) async{

    String plateNumber = plateNo;
    final dateIn = DateFormat("yyyy-MM-dd : hh:mm a").format(dateTimeIn);
    final dateNow = DateFormat("yyyy-MM-dd : hh:mm a").format(dateTimeNow);
    var amountPay = amount;
    var penalty = 0;



    //insert to history tbl
    await db.addTransHistory(plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user);
    //update  status to 0
    await db.updatePayTranStat(id);
    getTransData();
    //code for print
    Fluttertoast.showToast(
        msg: "Successfully added to history",
        toastLength: Toast.LENGTH_LONG ,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 2,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0
    );

  }

  Future passDataToHistoryWithPay(id,plateNo,dateTimeIn,dateTimeNow,amount,user,penalty) async{

    String plateNumber = plateNo;
    final dateIn = DateFormat("yyyy-MM-dd : hh:mm a").format(dateTimeIn);
    final dateNow = DateFormat("yyyy-MM-dd : hh:mm a").format(dateTimeNow);
    var amountPay = amount;



    //insert to history tbl
    await db.addTransHistory(plateNumber,dateIn.toString(),dateNow,amountPay.toString(),penalty.toString().toString(),user);
    //update  status to 0
    await db.updatePayTranStat(id);
    getTransData();
    //code for print
    Fluttertoast.showToast(
        msg: "Successfully added to history",
        toastLength: Toast.LENGTH_LONG ,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 2,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  void initState(){
    super.initState();
    getTransData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Transactions List',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),),
        textTheme: TextTheme(
            title: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            )
        ),
      ),

        body:Column(
          children: <Widget>[
          Card(
            color: Colors.transparent,
            margin: EdgeInsets.all(5),
            elevation: 0.0,
              child: Row(
                  children: <Widget>[
                    Text('Above 2 Hours:'),
                    Container(
                      margin: EdgeInsets.all(5),
                      height: 20.0,
                      width: 20.0,
                      child:  DecoratedBox(
                        decoration:  BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.redAccent.withOpacity(.3),
                        ),
                      ),
                    ),
                    Text('Almost 2 Hours:'),
                    Container(
                      margin: EdgeInsets.all(5),
                      height: 20.0,
                      width: 20.0,
                      child:  DecoratedBox(
                        decoration:  BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.blueAccent.withOpacity(.3),
                        ),
                      ),
                    ),
                    Text('New Entry:'),
                    Container(
                      margin: EdgeInsets.all(5),
                      height: 20.0,
                      width: 20.0,
                      child:  DecoratedBox(
                        decoration:  BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.white,
                        ),
                      ),
                    )
            ],
           ),
          ),
           Expanded(
               child:RefreshIndicator(
                 onRefresh: getTransData,
                 child:ListView.builder(
//                 physics: BouncingScrollPhysics(),
                   itemCount: plateData == null ? 0: plateData.length,
                   itemBuilder: (BuildContext context, int index) {

                    var f = index;
                    f++;
                    var trigger;
                    var penalty = 0;
                    String alertText;
                    String alertButton;
                    Color  cardColor;

                    var dateString = plateData[index]["dateToday"]; //getting time
                    var date = dateString.split("-"); //split time
                    var hrString = plateData[index]["dateTimeToday"]; //getting time
                    var hour = hrString.split(":"); //split time
                    var vType = plateData[index]["amount"];

                    final dateTimeIn = DateTime(int.parse(date[0]),int.parse(date[1]),int.parse(date[2]),int.parse(hour[0]),int.parse(hour[1]));
                    final dateTimeNow = DateTime.now();
                    final difference = dateTimeNow.difference(dateTimeIn).inMinutes;
                    final fifteenAgo = new DateTime.now().subtract(new Duration(minutes: difference));
                    final timeAg = timeAgo.format(fifteenAgo);
                    print(difference);
                    if(difference <= 90){
                      alertText = "Do you want to log out this person?";
                      alertButton = "Logout";
                      trigger = 0;
                      cardColor = Colors.white;
                    }if(difference >= 90 && difference <= 119){
                      alertText = "Do you want to log out this person?";
                      alertButton = "Logout";
                      trigger = 0;
                      cardColor = Colors.blueAccent.withOpacity(.3);
                    }if(difference >= 120){
                      alertText = "Do you want log out this person?";
                      alertButton = "Logout & Print";
                      trigger = 1;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 120 && vType == '100'){
                      penalty = 20;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 240 && vType == '100'){
                      penalty = 40;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 300 && vType == '100'){
                      penalty = 60;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 360 && vType == '100'){
                      penalty = 80;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 420 && vType == '100'){
                      penalty = 100;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 480 && vType == '100'){
                      penalty = 120;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 540 && vType == '100'){
                      penalty = 140;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 600 && vType == '100'){
                      penalty = 160;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 660 && vType == '100'){
                      penalty = 180;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 720 && vType == '100'){
                      penalty = 200;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 780 && vType == '100'){
                      penalty = 220;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 840 && vType == '100'){
                      penalty = 240;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 900 && vType == '100'){
                      penalty = 260;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 960 && vType == '100'){
                      penalty = 280;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 1020 && vType == '100'){
                      penalty = 300;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }

                    //for 2 wheels
                    if(difference >= 120 && vType == '50'){
                      penalty = 20;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 240 && vType == '50'){
                      penalty = 40;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 300 && vType == '50'){
                      penalty = 60;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 360 && vType == '50'){
                      penalty = 80;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 420 && vType == '50'){
                      penalty = 100;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 480 && vType == '50'){
                      penalty = 120;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 540 && vType == '50'){
                      penalty = 140;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 600 && vType == '50'){
                      penalty = 160;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 660 && vType == '50'){
                      penalty = 180;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 720 && vType == '50'){
                      penalty = 200;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 780 && vType == '50'){
                      penalty = 220;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 840 && vType == '50'){
                      penalty = 240;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 900 && vType == '50'){
                      penalty = 260;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 960 && vType == '50'){
                      penalty = 280;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
                    if(difference >= 1020 && vType == '50'){
                      penalty = 300;
                      cardColor = Colors.redAccent.withOpacity(.3);
                    }
//                    if(DateFormat("H:mm").format(new DateTime.now()) == 18 && vType == '50'){
//                      violation = 500;
//                    }

                    var totalAmount = penalty + num.parse(vType);



                     return InkWell(
                       onLongPress: (){
                         showDialog(
                           barrierDismissible: false,
                           context: context,
                           builder: (BuildContext context) {
                             // return object of type Dialog
                             return CupertinoAlertDialog(
                               title: new Text(plateData[index]["plateNumber"]),
                               content: new Text(alertText),
                               actions: <Widget>[
                                 // usually buttons at the bottom of the dialog
                                 new FlatButton(
                                   child: new Text(alertButton),
                                    onPressed: () {
                                     if(trigger == 0){
                                        passDataToHistoryWithOutPay(plateData[index]["id"],plateData[index]["plateNumber"],dateTimeIn,DateTime.now(),plateData[index]["amount"],plateData[index]["user"]);
                                     }
                                     if(trigger == 1){
                                        passDataToHistoryWithPay(plateData[index]["id"],plateData[index]["plateNumber"],dateTimeIn,DateTime.now(),plateData[index]["amount"],plateData[index]["user"],penalty);
                                     }
                                     Navigator.of(context).pop();
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
                       },
                       child: Card(
                         color: cardColor,
                         margin: EdgeInsets.all(5),
                         elevation: 0.0,
                         child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             ListTile(
                               title:Text('$f.Plt No : ${plateData[index]["plateNumber"]}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27.0),),
                               subtitle: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[
                                   Text('     Time In : '+DateFormat("yyyy-MM-dd hh:mm a").format(dateTimeIn),style: TextStyle(fontSize: 18.0),),
                                   Text('     Entrance Fee : '+oCcy.format(int.parse(plateData[index]["amount"])),style: TextStyle(fontSize: 18.0),),
                                   Text('     Time lapse : $timeAg',style: TextStyle(fontSize: 18.0),),
                                   Text('     Penalty : '+oCcy.format(penalty),style: TextStyle(fontSize: 18.0),),
                                   Text('     By : '+plateData[index]["user"],style: TextStyle(fontSize: 18.0),),
                                   Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: 18.0),),
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
          ],
        ),



    );
  }
}


