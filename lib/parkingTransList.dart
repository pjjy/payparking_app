import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'update.dart';
import 'delinquent.dart';

class ParkTransList extends StatefulWidget{
  final String empId;
  final String name;
  final String empNameFn;
  final String location;
  ParkTransList({Key key, @required this.name, this.empNameFn, this.location, this.empId}) : super(key: key);
  @override
  _ParkTransList createState() => _ParkTransList();
}

class _ParkTransList extends State<ParkTransList> {
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = PayParkingDatabase();
  List plateData;
  List plateData2;
  TextEditingController _textController;



//  Future getTransData() async {
//    var res = await db.fetchAll();
//    setState((){
//      plateData = res;
//    });
//  }

  Future getTransData() async {
    listStat = false;
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true){
      var res = await db.olFetchAll(widget.location);
      setState((){
        plateData = res["user_details"];
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



  Future passDataToHistoryWithOutPay(id,plateNo,dateTimeIn,dateTimeNow,amount,user,empNameIn,outBy,empNameOut,location) async{

    String plateNumber = plateNo;
    final dateIn = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeIn);
    final dateNow = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeNow);
    var amountPay = amount;
    var penalty = 0;

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true){
      //code for mysql
      await db.olAddTransHistory(id,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),outBy.toString(),location.toString());
      //insert to history tbl
      await db.addTransHistory(plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),empNameIn.toString(),outBy.toString(),empNameOut.toString(),location.toString());
      //code for mysql
      //update  status to 0
      //await db.updatePayTranStat(id);
      getTransData();
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

  Future passDataToHistoryWithPay(id,plateNo,dateTimeIn,dateTimeNow,amount,penalty,user,empNameIn,outBy,empNameOut,location) async{

    String plateNumber = plateNo;
    final dateIn = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeIn);
    final dateNow = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeNow);
    var amountPay = amount;

    bool result = await DataConnectionChecker().hasConnection;
    if(result == true){
      //code for mysql
      await db.olAddTransHistory(id,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),outBy.toString(),location.toString());
      //insert to history tbl
      await db.addTransHistory(plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),empNameIn.toString(),outBy.toString(),empNameOut.toString(),location.toString());
      //code for mysql
      //await db.updatePayTranStat(id);
      getTransData();
      //code for print here
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



 bool listStat = false;
  Future _onChanged(text) async {
    listStat = true;
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true){
      var res = await db.olFetchSearch(text,widget.location);
      setState((){
        plateData2 = res["user_details"];
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
    getTransData();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Transactions List',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28,color: Colors.black),),
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
//                   onChanged: _onChanged,
                 ),
                 actions: <Widget>[
                   new FlatButton(
                     child: new Text("Search"),
                     onPressed:() {
//                       print(_textController.text);
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
          FlatButton(
            textColor: Colors.white,
            onPressed: (){},
            child: Text(widget.name.toString(),style: TextStyle(fontSize: width/36,color: Colors.black),),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),

        body:Column(
          children: <Widget>[
            SingleChildScrollView(
//            color: Colors.transparent,
//            margin: EdgeInsets.all(5),
//            elevation: 0.0,
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: <Widget>[
                    Text('  Above 2 Hours:', style: TextStyle(fontSize: width/32,color: Colors.black),),
                    Container(
                      margin: EdgeInsets.all(10),
                      height: 20.0,
                      width: 20.0,
                      child:  DecoratedBox(
                        decoration:  BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.redAccent.withOpacity(.3),
                        ),
                      ),
                    ),
                    Text('Almost 2 Hours:', style: TextStyle(fontSize: width/32,color: Colors.black),),
                    Container(
                      margin: EdgeInsets.all(10),
                      height: 20.0,
                      width: 20.0,
                      child:  DecoratedBox(
                        decoration:  BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: Colors.blueAccent.withOpacity(.3),
                        ),
                      ),
                    ),
                    Text('New Entry:', style: TextStyle(fontSize: width/32,color: Colors.black),),
                    Container(
                      margin: EdgeInsets.all(10),
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
                child:Scrollbar(
                  child: listStat == true ?
                  ListView.builder(
//                   physics: BouncingScrollPhysics(),
                    itemCount: plateData2 == null ? 0: plateData2.length,
                    itemBuilder: (BuildContext context, int index) {

                      var f = index;
                      f++;
                      var trigger;
                      var penalty = 0;

                      String alertButton;
                      Color  cardColor;

                      var dateString = plateData2[index]["d_dateToday"]; //getting time
                      var date = dateString.split("-"); //split time
                      var hrString = plateData2[index]["d_dateTimeToday"]; //getting time
                      var hour = hrString.split(":"); //split time
                      var vType = plateData2[index]["d_amount"];

                      final dateTimeIn = DateTime(int.parse(date[0]),int.parse(date[1]),int.parse(date[2]),int.parse(hour[0]),int.parse(hour[1]));
                      final dateTimeNow = DateTime.now();
                      final difference = dateTimeNow.difference(dateTimeIn).inMinutes;
                      final fifteenAgo = new DateTime.now().subtract(new Duration(minutes: difference));
                      final timeAg = timeAgo.format(fifteenAgo);

                      if(difference <= 90){
                        alertButton = "Logout";
                        trigger = 0;
                        cardColor = Colors.white;
                      }
                      if(difference >= 70 && difference <= 100){
                        alertButton = "Logout";
                        trigger = 0;
                        cardColor = Colors.blueAccent.withOpacity(.3);
                      }
                      if(difference >= 101){
                        alertButton = "Logout & Print receipt";
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

                      return GestureDetector(
                        onLongPress: (){
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return CupertinoAlertDialog(
//                                 title: new Text(plateData[index]["d_Plate"]),
//                                 content: new Text(alertText),
                                title: new Text("Please choose an action"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text(alertButton),
                                    onPressed: () {
//                                       if(trigger == 0){
//                                         passDataToHistoryWithOutPay(int.parse(plateData[index]["d_id"]),plateData[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData[index]["d_amount"],plateData[index]["d_emp_id"],plateData[index]['d_user'],widget.empId,widget.name,plateData[index]["d_location"]);
//                                       }
//                                       if(trigger == 1){
//                                         passDataToHistoryWithPay(int.parse(plateData[index]["d_id"]),plateData[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData[index]["d_amount"],penalty,plateData[index]["d_emp_id"],plateData[index]['d_user'],widget.empId,widget.name,plateData[index]["d_location"]);
//                                       }
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return CupertinoAlertDialog(
                                            title: new Text("Are you sure?"),
                                            content: new Text("Do you want to log out this plate # ${plateData[index]["d_Plate"]}"),
                                            actions: <Widget>[
                                              // usually buttons at the bottom of the dialog
                                              new FlatButton(
                                                child: new Text("Yes"),
                                                onPressed: () {
                                                  if(trigger == 0){
                                                    passDataToHistoryWithOutPay(int.parse(plateData2[index]["d_id"]),plateData2[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData2[index]["d_amount"],plateData2[index]["d_emp_id"],plateData2[index]['d_user'],widget.empId,widget.empNameFn,plateData[index]["d_location"]);
                                                  }
                                                  if(trigger == 1){
                                                    passDataToHistoryWithPay(int.parse(plateData2[index]["d_id"]),plateData2[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData2[index]["d_amount"],penalty,plateData2[index]["d_emp_id"],plateData2[index]['d_user'],widget.empId,widget.empNameFn,plateData[index]["d_location"]);
                                                  }
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              new FlatButton(
                                                child: new Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Edit"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => UpdateTrans(id:plateData2[index]["d_id"],plateNo:plateData2[index]["d_Plate"],amount:plateData2[index]['d_amount'],location:widget.location,username:widget.name)),
                                      );
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Takas ni!"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
//                                      Navigator.push(
//                                        context,
//                                        MaterialPageRoute(builder: (context) => Delinquent(id:plateData2[index]["d_id"],plateNo:plateData2[index]["d_Plate"],amount:plateData2[index]['d_amount'],location:widget.location,username:widget.name)),
//                                      );
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
//                           crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ListTile(
                                title:Text('$f.Plt No : ${plateData2[index]["d_Plate"]}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: width/20),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('     Time In : '+DateFormat("yyyy-MM-dd hh:mm a").format(dateTimeIn),style: TextStyle(fontSize: width/32),),
                                    Text('     Entrance Fee : '+oCcy.format(int.parse(plateData2[index]["d_amount"])),style: TextStyle(fontSize: width/32),),
                                    Text('     Time lapse : $timeAg',style: TextStyle(fontSize: width/32),),
                                    Text('     Penalty : '+oCcy.format(penalty),style: TextStyle(fontSize: width/32),),
                                    Text('     In By : '+plateData2[index]["d_user"],style: TextStyle(fontSize: width/32),),
                                    Text('     Location : '+plateData2[index]["d_location"],style: TextStyle(fontSize: width/32),),
                                    Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/32),),
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
//                   physics: BouncingScrollPhysics(),
                    itemCount: plateData == null ? 0: plateData.length,
                    itemBuilder: (BuildContext context, int index) {

                      var f = index;
                      f++;
                      var trigger;
                      var penalty = 0;

                      String alertButton;
                      Color  cardColor;

                      var dateString = plateData[index]["d_dateToday"]; //getting time
                      var date = dateString.split("-"); //split time
                      var hrString = plateData[index]["d_dateTimeToday"]; //getting time
                      var hour = hrString.split(":"); //split time
                      var vType = plateData[index]["d_amount"];

                      final dateTimeIn = DateTime(int.parse(date[0]),int.parse(date[1]),int.parse(date[2]),int.parse(hour[0]),int.parse(hour[1]));
                      final dateTimeNow = DateTime.now();
                      final difference = dateTimeNow.difference(dateTimeIn).inMinutes;
                      final fifteenAgo = new DateTime.now().subtract(new Duration(minutes: difference));
                      final timeAg = timeAgo.format(fifteenAgo);

                      if(difference <= 90){
                        alertButton = "Logout";
                        trigger = 0;
                        cardColor = Colors.white;
                      }
                      if(difference >= 70 && difference <= 100){
                        alertButton = "Logout";
                        trigger = 0;
                        cardColor = Colors.blueAccent.withOpacity(.3);
                      }
                      if(difference >= 101){
                        alertButton = "Logout & Print receipt";
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

                      return GestureDetector(
                        onLongPress: (){
                          showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return CupertinoAlertDialog(
//                                 title: new Text(plateData[index]["d_Plate"]),
//                                 content: new Text(alertText),
                                title: new Text("Please choose an action"),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text(alertButton),
                                    onPressed: () {
//                                       if(trigger == 0){
//                                         passDataToHistoryWithOutPay(int.parse(plateData[index]["d_id"]),plateData[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData[index]["d_amount"],plateData[index]["d_emp_id"],plateData[index]['d_user'],widget.empId,widget.name,plateData[index]["d_location"]);
//                                       }
//                                       if(trigger == 1){
//                                         passDataToHistoryWithPay(int.parse(plateData[index]["d_id"]),plateData[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData[index]["d_amount"],penalty,plateData[index]["d_emp_id"],plateData[index]['d_user'],widget.empId,widget.name,plateData[index]["d_location"]);
//                                       }
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return CupertinoAlertDialog(
                                            title: new Text("Are you sure?"),
                                            content: new Text("Do you want to log out this plate # ${plateData[index]["d_Plate"]}"),
                                            actions: <Widget>[
                                              // usually buttons at the bottom of the dialog
                                              new FlatButton(
                                                child: new Text("Yes"),
                                                onPressed: () {
                                                  if(trigger == 0){
                                                    passDataToHistoryWithOutPay(int.parse(plateData[index]["d_id"]),plateData[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData[index]["d_amount"],plateData[index]["d_emp_id"],plateData[index]['d_user'],widget.empId,widget.empNameFn,plateData[index]["d_location"]);
                                                  }
                                                  if(trigger == 1){
                                                    passDataToHistoryWithPay(int.parse(plateData[index]["d_id"]),plateData[index]["d_Plate"],dateTimeIn,DateTime.now(),plateData[index]["d_amount"],penalty,plateData[index]["d_emp_id"],plateData[index]['d_user'],widget.empId,widget.empNameFn,plateData[index]["d_location"]);
                                                  }
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              new FlatButton(
                                                child: new Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Edit"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => UpdateTrans(id:plateData[index]["d_id"],plateNo:plateData[index]["d_Plate"],amount:plateData[index]['d_amount'],location:widget.location,username:widget.name)),
                                      );
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Takas ni!"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
//                                        MaterialPageRoute(builder: (context) => Delinquent(id:plateData2[index]["d_id"],plateNo:plateData2[index]["d_Plate"],amount:plateData2[index]['d_amount'],location:widget.location,username:widget.name)),
                                        MaterialPageRoute(builder: (context) => Delinquent(username:widget.name,plateNo:plateData[index]["d_Plate"])),
                                      );
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
//                           crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ListTile(
                                title:Text('$f.Plt No : ${plateData[index]["d_Plate"]}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: width/20),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('     Time In : '+DateFormat("yyyy-MM-dd hh:mm a").format(dateTimeIn),style: TextStyle(fontSize: width/32),),
                                    Text('     Entrance Fee : '+oCcy.format(int.parse(plateData[index]["d_amount"])),style: TextStyle(fontSize: width/32),),
                                    Text('     Time lapse : $timeAg',style: TextStyle(fontSize: width/32),),
                                    Text('     Penalty : '+oCcy.format(penalty),style: TextStyle(fontSize: width/32),),
                                    Text('     In By : '+plateData[index]["d_user"],style: TextStyle(fontSize: width/32),),
                                    Text('     Location : '+plateData[index]["d_location"],style: TextStyle(fontSize: width/32),),
                                    Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/32),),
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
  }






