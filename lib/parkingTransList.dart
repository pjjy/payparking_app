import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:payparking_app/utils/file_creator.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

import 'update.dart';
import 'delinquent.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';

class ParkTransList extends StatefulWidget{
  final String empId;
  final String name;
  final String empNameFn;
  final String location;
  ParkTransList({Key key, @required this.name, this.empNameFn, this.location, this.empId}) : super(key: key);
  @override
  _ParkTransList createState() => _ParkTransList();
}

class _ParkTransList extends State<ParkTransList>{
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final db = PayParkingDatabase();
  final fileCreate = PayParkingFileCreator();
  List plateData;
  List plateData2;
  TextEditingController _managerKeyUserPass;
  TextEditingController _managerKeyUser;
  TextEditingController  _textController;
//  Timer timer;
//  Future getTransData() async {
//    var res = await db.fetchAll();
//    setState((){
//      plateData = res;
//    });
//  }
  Future getTransData() async {
    listStat = false;
    var res = await db.ofFetchAll();
    setState((){
      plateData = res;
    });
  }



  Future passDataToHistoryWithOutPay(id,uid,checkDigit,plateNo,dateTimeIn,dateTimeNow,amount,user,empNameIn,outBy,empNameOut,location) async{

    String plateNumber = plateNo;
    final dateIn = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeIn);
    final dateNow = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeNow);
    var amountPay = amount;
    var penalty = 0;


//     await db.olAddTransHistory(id,uid,checkDigit,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),outBy.toString(),location.toString());
     await db.addTransHistory(uid,checkDigit,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),empNameIn.toString(),outBy.toString(),empNameOut.toString(),location.toString());
     await db.updatePayTranStat(id);
     getTransData();
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

  Future passDataToHistoryWithPay(id,uid,checkDigit,plateNo,dateTimeIn,dateTimeNow,amount,penalty,user,empNameIn,outBy,empNameOut,location) async{

    String plateNumber = plateNo;
    final dateIn = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeIn);
    final dateNow = DateFormat("yyyy-MM-dd : H:mm").format(dateTimeNow);
    var amountPay = amount;



//      await db.olAddTransHistory(id,uid,checkDigit,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),outBy.toString(),location.toString());
      await db.addTransHistory(uid,checkDigit,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),empNameIn.toString(),outBy.toString(),empNameOut.toString(),location.toString());
      await db.updatePayTranStat(id);
      await fileCreate.transactionTypeFunc('print_penalty');
      await fileCreate.transPenaltyFunc(uid,checkDigit,plateNumber,dateIn,dateNow,amountPay.toString(),penalty.toString(),user.toString(),empNameIn.toString(),outBy.toString(),empNameOut.toString(),location.toString());
      getTransData();

//      await db.olSendTransType(widget.empId,'penalty');
      AppAvailability.launchApp("com.example.cpcl_test_v1").then((_) {
      });

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


 bool listStat = false;
  Future _onChanged(text) async {
    listStat = true;
      var res = await db.ofFetchSearch(text);
      setState((){
        plateData2 = res;
      });
  }
//  managerLoginReprint(plateData[index]['d_uid'],plateData[index]["d_chkdigit"],plateData[index]["d_Plate"],plateData[index]['d_dateToday'],plateData[index]["d_dateTimeToday"],plateData[index]['d_amount'],plateData[index]["d_emp_id"],plateData[index]['d_location']);

  Future managerLoginReprint(uid,checkDigit,plateNo,dateToday,dateTimeToday,dateUntil,amount,empId,location) async{
//    bool result = await DataConnectionChecker().hasConnection;

      var res = await db.olManagerLogin(_managerKeyUser.text,_managerKeyUserPass.text);
//      print(res);
      if(res == 'true'){
        _managerKeyUser.clear();
        _managerKeyUserPass.clear();
        await db.olSendTransType(widget.empId,'reprint');
        await db.olReprintCouponTicket(uid,checkDigit,plateNo,dateToday,dateTimeToday,dateUntil,amount,empId,location);
        AppAvailability.launchApp("com.example.cpcl_test_v1").then((_) {
        });
      }
      if(res == 'false'){
        _managerKeyUser.clear();
        _managerKeyUserPass.clear();
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return CupertinoAlertDialog(
              title: new Text("Wrong credentials"),
              content: new Text("Please check your username and password"),
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


  Future managerCancel(plateNumber,id) async{




      var res = await db.olManagerLogin(_managerKeyUser.text,_managerKeyUserPass.text);
      if(res == 'true'){
        _managerKeyUser.clear();
        _managerKeyUserPass.clear();
        await db.olCancel(id);
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return CupertinoAlertDialog(
              title: new Text("Successfully Cancelled"),
              content: new Text("Plate '$plateNumber' successfully removed"),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    getTransData();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      if(res == 'false'){
        _managerKeyUser.clear();
        _managerKeyUserPass.clear();
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return CupertinoAlertDialog(
              title: new Text("Wrong credentials"),
              content: new Text("Please check your username and password"),
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
    getTransData();
    _managerKeyUser = TextEditingController();
    _managerKeyUserPass = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
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
         onPressed:(){
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
                    //physics: BouncingScrollPhysics(),
                    itemCount: plateData2 == null ? 0: plateData2.length,
                    itemBuilder: (BuildContext context, int index) {
                      var f = index;
                      f++;
                      var trigger;
                      var penalty = 0;
                      String alertButton;
                      Color cardColor;
                      var dateString = plateData2[index]["dateToday"]; //getting time
                      var date = dateString.split("-"); //split time
                      var hrString = plateData2[index]["dateTimeToday"]; //getting time
                      var hour = hrString.split(":"); //split time
                      var vType = plateData2[index]["amount"];

                      final dateTimeIn = DateTime(int.parse(date[0]),int.parse(date[1]),int.parse(date[2]),int.parse(hour[0]),int.parse(hour[1]));
                      final dateTimeNow = DateTime.now();
                      final difference = dateTimeNow.difference(dateTimeIn).inMinutes;
                      final fifteenAgo = new DateTime.now().subtract(new Duration(minutes: difference));
                      final timeAg = timeAgo.format(fifteenAgo);
                      bool enabled = true;
                      if(difference >= 6){
                        enabled = false;
                      }

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
                        penalty = 10;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 240 && vType == '50'){
                        penalty = 20;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 300 && vType == '50'){
                        penalty = 30;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 360 && vType == '50'){
                        penalty = 40;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 420 && vType == '50'){
                        penalty = 50;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 480 && vType == '50'){
                        penalty = 60;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 540 && vType == '50'){
                        penalty = 70;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 600 && vType == '50'){
                        penalty = 80;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 660 && vType == '50'){
                        penalty = 90;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 720 && vType == '50'){
                        penalty = 100;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 780 && vType == '50'){
                        penalty = 110;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 840 && vType == '50'){
                        penalty = 120;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 900 && vType == '50'){
                        penalty = 130;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 960 && vType == '50'){
                        penalty = 140;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 1020 && vType == '50'){
                        penalty = 150;
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
                                title: new Text(plateData2[index]["plateNumber"]),
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
                                            content: new Text("Do you want to log out this plate # ${plateData2[index]["plateNumber"]}"),
                                            actions: <Widget>[
                                              // usually buttons at the bottom of the dialog
                                              new FlatButton(
                                                child: new Text("Yes"),
                                                onPressed: () {
                                                  if(trigger == 0){
                                                    passDataToHistoryWithOutPay(plateData2[index]["id"],plateData2[index]['uid'],plateData2[index]["checkDigit"],plateData2[index]["plateNumber"],dateTimeIn,DateTime.now(),plateData2[index]["amount"],plateData2[index]["empId"],plateData2[index]['fname'],widget.empId,widget.empNameFn,plateData2[index]["location"]);
                                                  }
                                                  if(trigger == 1){
                                                    passDataToHistoryWithPay(plateData2[index]["id"],plateData2[index]['uid'],plateData2[index]["checkDigit"],plateData2[index]["plateNumber"],dateTimeIn,DateTime.now(),plateData2[index]["amount"],penalty,plateData2[index]["empId"],plateData2[index]['fname'],widget.empId,widget.empNameFn,plateData2[index]["location"]);
//                                                    penaltyPrint.sample();
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
                                        MaterialPageRoute(builder: (context) => UpdateTrans(id:plateData2[index]["id"],plateNo:plateData2[index]["plateNumber"],username:widget.name)),
                                      );
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Escapee"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
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
                                                  controller: _managerKeyUser,
                                                ),
                                                Divider(),
                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Password",
                                                  controller: _managerKeyUserPass,
                                                  obscureText: true,
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Proceed"),
                                                onPressed:() async{
                                                    var res = await db.olManagerLogin(_managerKeyUser.text,_managerKeyUserPass.text);
                                                    if(res == 'true'){
                                                      _managerKeyUser.clear();
                                                      _managerKeyUserPass.clear();
                                                      Navigator.of(context).pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Delinquent(id:plateData[index]["id"],fullName:widget.empNameFn,username:widget.name,uid:plateData[index]["uid"],plateNo:plateData[index]["plateNumber"])),
                                                      );
                                                    }
                                                    if(res == 'false'){
                                                      _managerKeyUser.clear();
                                                      _managerKeyUserPass.clear();
                                                      Navigator.of(context).pop();
                                                      showDialog(
                                                        barrierDismissible: true,
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          // return object of type Dialog
                                                          return CupertinoAlertDialog(
                                                            title: new Text("Wrong credentials"),
                                                            content: new Text("Please check your username and password"),
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

                                                },
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
                                  ),
                                  new FlatButton(
                                    child: new Text("Reprint"),
                                    onPressed: (){
//                                        couponPrint.sample(plateData[index]["d_Plate"],DateFormat("yyyy-MM-dd").format(dateTimeIn),DateFormat("hh:mm a").format(dateTimeIn),DateFormat("yyyy-MM-dd").format(dateTimeIn.add(new Duration(days: 7))),plateData[index]['d_amount'],"ppd","12","location");
//                                          Navigator.push(
//                                             context,
//                                             MaterialPageRoute(builder: (context) => Reprint(id:plateData[index]["d_id"],fullName:widget.empNameFn,username:widget.name,uid:plateData[index]["d_uid"],plateNo:plateData[index]["d_Plate"])),
//                                          );
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
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
                                                  controller: _managerKeyUser,
                                                ),
                                                Divider(),
                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Password",
                                                  controller: _managerKeyUserPass,
                                                  obscureText: true,
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Proceed"),
                                                onPressed:(){
                                                  Navigator.of(context).pop();
                                                    managerLoginReprint(plateData[index]['uid'],plateData[index]["chekDigit"],plateData[index]["plateNumber"],plateData[index]['dateToday'],plateData[index]["dateTimeToday"],plateData[index]['dateUntil'],plateData[index]['amount'],plateData[index]["user"],plateData[index]['location']);
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
                                  ),
                                  new FlatButton(
                                    child: new Text("Cancellation"),
                                    onPressed: enabled ? () {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
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
                                                  controller: _managerKeyUser,
                                                ),
                                                Divider(),
                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Password",
                                                  controller: _managerKeyUserPass,
                                                  obscureText: true,
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Proceed"),
                                                onPressed:(){
                                                  Navigator.of(context).pop();
                                                  managerCancel(plateData[index]['plateNumber'],plateData[index]["id"]);
                                                },
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
                                    } : null,
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
                                title:Text('$f.Plt No : ${plateData2[index]["plateNumber"]}'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold, fontSize: width/20),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('     Time In : '+DateFormat("yyyy-MM-dd hh:mm a").format(dateTimeIn),style: TextStyle(fontSize: width/32),),
                                    Text('     Entrance Fee : '+oCcy.format(int.parse(plateData2[index]["amount"])),style: TextStyle(fontSize: width/32),),
                                    Text('     Time lapse : $timeAg',style: TextStyle(fontSize: width/32),),
                                    Text('     Charge : '+oCcy.format(penalty),style: TextStyle(fontSize: width/32),),
                                    Text('     Trans Code : '+plateData2[index]["checkDigit"],style: TextStyle(fontSize: width/32),),
                                    Text('     In By : '+plateData2[index]["fname"],style: TextStyle(fontSize: width/32),),
                                    Text('     Location : '+plateData2[index]["location"],style: TextStyle(fontSize: width/32),),
                                    Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/32),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ) //folded

                  :ListView.builder(
//                   physics: BouncingScrollPhysics(),
                    itemCount: plateData == null ? 0: plateData.length,
                    itemBuilder: (BuildContext context, int index) {
                      var f = index;
                      f++;
                      var trigger;
                      var penalty = 0;
                      String alertButton;
                      Color cardColor;
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
                      bool enabled = true;
                      if(difference >= 6){
                         enabled = false;
                      }
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
                        penalty = 10;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 240 && vType == '50'){
                        penalty = 20;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 300 && vType == '50'){
                        penalty = 30;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 360 && vType == '50'){
                        penalty = 40;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 420 && vType == '50'){
                        penalty = 50;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 480 && vType == '50'){
                        penalty = 60;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 540 && vType == '50'){
                        penalty = 70;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 600 && vType == '50'){
                        penalty = 80;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 660 && vType == '50'){
                        penalty = 90;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 720 && vType == '50'){
                        penalty = 100;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 780 && vType == '50'){
                        penalty = 110;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 840 && vType == '50'){
                        penalty = 120;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 900 && vType == '50'){
                        penalty = 130;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 960 && vType == '50'){
                        penalty = 140;
                        cardColor = Colors.redAccent.withOpacity(.3);
                      }
                      if(difference >= 1020 && vType == '50'){
                        penalty = 150;
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
                                title: new Text(plateData[index]["plateNumber"]),
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
                                            content: new Text("Do you want to log out this plate # ${plateData[index]["plateNumber"]}"),
                                            actions: <Widget>[
                                              // usually buttons at the bottom of the dialog
                                              new FlatButton(
                                                child: new Text("Yes"),
                                                onPressed:() {
                                                  if(trigger == 0){
                                                    passDataToHistoryWithOutPay(plateData[index]["id"],plateData[index]['uid'],plateData[index]["checkDigit"],plateData[index]["plateNumber"],dateTimeIn,DateTime.now(),plateData[index]["amount"],plateData[index]["empId"],plateData[index]["fname"],widget.empId,widget.empNameFn,plateData[index]["location"]);

                                                  }
                                                  if(trigger == 1){
                                                    passDataToHistoryWithPay(plateData[index]["id"],plateData[index]['uid'],plateData[index]["checkDigit"],plateData[index]["plateNumber"],dateTimeIn,DateTime.now(),plateData[index]["amount"],penalty,plateData[index]["empId"],plateData[index]['fname'],widget.empId,widget.empNameFn,plateData[index]["location"]);
                                                  }
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              new FlatButton(
                                                child: new Text("No"),
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
                                  new FlatButton(
                                    child: new Text("Edit"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                      print(plateData[index]["id"]);
                                      print(plateData[index]["plateNumber"]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => UpdateTrans(id:plateData[index]["id"],plateNo:plateData[index]["plateNumber"],username:widget.name)),
                                      );
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Escapee"),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
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
                                                  controller: _managerKeyUser,
                                                ),
                                                Divider(),
                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Password",
                                                  controller: _managerKeyUserPass,
                                                  obscureText: true,
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Proceed"),
                                                onPressed:() async{

                                                    var res = await db.olManagerLogin(_managerKeyUser.text,_managerKeyUserPass.text);
                                                    print(res);
                                                    if(res == 'true'){
                                                      _managerKeyUser.clear();
                                                      _managerKeyUserPass.clear();
                                                      Navigator.of(context).pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Delinquent(id:plateData[index]["id"],fullName:widget.empNameFn,username:widget.name,uid:plateData[index]["uid"],plateNo:plateData[index]["plateNumber"])),
                                                      );
                                                    }
                                                    if(res == 'false'){
                                                      _managerKeyUser.clear();
                                                      _managerKeyUserPass.clear();
                                                      Navigator.of(context).pop();
                                                      showDialog(
                                                        barrierDismissible: true,
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          // return object of type Dialog
                                                          return CupertinoAlertDialog(
                                                            title: new Text("Wrong credentials"),
                                                            content: new Text("Please check your username and password"),
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
                                                },
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
                                  ),
                                  new FlatButton(
                                    child: new Text("Reprint"),
                                    onPressed: (){
//                                        couponPrint.sample(plateData[index]["d_Plate"],DateFormat("yyyy-MM-dd").format(dateTimeIn),DateFormat("hh:mm a").format(dateTimeIn),DateFormat("yyyy-MM-dd").format(dateTimeIn.add(new Duration(days: 7))),plateData[index]['d_amount'],"ppd","12","location");
//                                          Navigator.push(
//                                             context,
//                                             MaterialPageRoute(builder: (context) => Reprint(id:plateData[index]["d_id"],fullName:widget.empNameFn,username:widget.name,uid:plateData[index]["d_uid"],plateNo:plateData[index]["d_Plate"])),
//                                          );
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          // return object of type Dialog
                                          return CupertinoAlertDialog(
                                            title: new Text("Manager's key"),
//                                            content: CupertinoTextField(
//                                              obscureText: true,
//                                              controller: _managerKey,
//                                              autofocus: true,
//                                            )
                                            content: new Column(
                                              children: <Widget>[

                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Username",
                                                  controller: _managerKeyUser,
                                                ),
                                                Divider(),
                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Password",
                                                  controller: _managerKeyUserPass,
                                                  obscureText: true,
                                                ),

                                              ],
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Proceed"),
                                                onPressed:(){
                                                  Navigator.of(context).pop();
                                                  managerLoginReprint(plateData[index]['uid'],plateData[index]["checkDigit"],plateData[index]["platenumber"],plateData[index]['dateToday'],plateData[index]["dateTimeToday"],plateData[index]['dateUntil'],plateData[index]['amount'],plateData[index]["empId"],plateData[index]['location']);
                                                },
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
                                  ),
                                  new FlatButton(
                                    child: new Text("Cancellation"),
                                    onPressed: enabled ? () {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        barrierDismissible: true,
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
                                                  controller: _managerKeyUser,
                                                ),
                                                Divider(),
                                                new CupertinoTextField(
                                                  autofocus: true,
                                                  placeholder: "Password",
                                                  controller: _managerKeyUserPass,
                                                  obscureText: true,
                                                ),

                                              ],
                                            ),
                                            actions: <Widget>[
                                              new FlatButton(
                                                child: new Text("Proceed"),
                                                onPressed:(){
                                                  Navigator.of(context).pop();
                                                  managerCancel(plateData[index]['plateNumber'],plateData[index]["d_id"]);
                                                },
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
                                    } : null,
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
                                title:Text('$f.Plt No : ${plateData[index]["plateNumber"]}'.toUpperCase(),style: TextStyle(fontWeight: FontWeight.bold, fontSize: width/20),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('     Time In : '+DateFormat("yyyy-MM-dd hh:mm a").format(dateTimeIn),style: TextStyle(fontSize: width/32),),
                                    Text('     Entrance Fee : '+oCcy.format(int.parse(plateData[index]["amount"])),style: TextStyle(fontSize: width/32),),
                                    Text('     Time lapse : $timeAg',style: TextStyle(fontSize: width/32),),
                                    Text('     Charge : '+oCcy.format(penalty),style: TextStyle(fontSize: width/32),),
                                    Text('     Trans Code : '+plateData[index]["checkDigit"],style: TextStyle(fontSize: width/32),),
                                    Text('     In By : '+plateData[index]["fname"],style: TextStyle(fontSize: width/32),),
                                    Text('     Location : '+plateData[index]["location"],style: TextStyle(fontSize: width/32),),
                                    Text('     Total : '+oCcy.format(totalAmount),style: TextStyle(fontSize: width/32),),
                                  ],
                                ),
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






