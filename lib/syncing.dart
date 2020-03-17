import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:data_connection_checker/data_connection_checker.dart';


class SyncingPage extends StatefulWidget{
  @override
  _SyncingPage createState() => new _SyncingPage();
}
class _SyncingPage extends State<SyncingPage>{
   List hisData;
   final db = PayParkingDatabase();
   String uid;
   String checkDigit;
   String plateNumber;
   String dateTimeIn;
   String dateTimeout;
   String amount;
   String penalty;
   String user;
   String empNameIn;
   String outBy;
   String empNameOut;
   String location;
   String statusNumber = "";
   String statusText = "";


   Future syncTransData() async{
    setState(() {
      statusNumber = "1/5";
      statusText = "Uploading data";
    });

     bool result = await DataConnectionChecker().hasConnection;
    var res = await db.fetchAllHistory();
    setState(() {
      hisData = res;
    });
     if(hisData.isEmpty){
       if(result==true){
         userDownLoad();
       }
       else{
         Fluttertoast.showToast(
             msg: "Please connect to a network",
             toastLength: Toast.LENGTH_LONG,
             gravity: ToastGravity.BOTTOM,
             timeInSecForIos: 2,
             backgroundColor: Colors.black54,
             textColor: Colors.white,
             fontSize: 16.0
         );
         Navigator.of(context).pop();
       }
     }else{
      if(result == true){
        for(int i = 0; i < hisData.length; i++){
          uid = hisData[i]['uid'];
          checkDigit = hisData[i]['checkDigit'];
          plateNumber = hisData[i]['plateNumber'];
          dateTimeIn = hisData[i]['dateTimein'];
          dateTimeout = hisData[i]['dateTimeout'];
          amount = hisData[i]['amount'];
          penalty = hisData[i]['penalty'];
          user = hisData[i]['user'];
          outBy = hisData[i]['outBy'];
          location = hisData[i]['location'];

          await http.post("http://172.16.46.130/e_parking/sync_data",body:{
            "uid":uid,
            "checkDigit":checkDigit,
            "plateNumber":plateNumber,
            "dateTimeIn":dateTimeIn,
            "dateTimeout":dateTimeout,
            "amount":amount,
            "penalty":penalty,
            "user":user,
            "outBy":outBy,
            "location":location
          });
          if(i == hisData.length-1){
            await db.emptyHistoryTbl();
           userDownLoad();
          }
        }
      }
      if(result == false){
        Fluttertoast.showToast(
            msg: "Please connect to a network",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 2,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future userDownLoad()async{

     setState(() {
       statusNumber = "2/5";
       statusText = "Updating users";
     });


    int count;
    int res = await db.countTblUser();
    count = res;
    await db.emptyUserTbl();
    for(int i = 0; i < count; i++){
      Map dataUser;
      List plateData;
      final response = await http.post("http://172.16.46.130/e_parking/app_downLoadUser",body:{
        "tohide":"tohide"
      });
      dataUser = jsonDecode(response.body);
      plateData = dataUser['user_details'];

      await db.ofSaveUsers(plateData[i]['d_user_id'],plateData[i]['d_emp_id'],plateData[i]['d_full_name'],plateData[i]['d_username'],plateData[i]['d_password'],plateData[i]['d_usertype'],plateData[i]['d_status']);
      if(i == count-1){
         downloadLocationUser();
      }
    }
  }

  Future downloadLocationUser() async{

    setState(() {
      statusNumber = "3/5";
      statusText = "Updating location user";
    });

    int count;
    int res = await db.countTblLocationUser();
    count = res;
    await db.emptyLocationUserTbl();
    for(int i = 0; i < count; i++) {
      Map dataUser;
      List plateData;
      final response1 = await http.post("http://172.16.46.130/e_parking/app_downLoadlocation_user", body: {
        "tohide": "tohide"
      });
      dataUser = jsonDecode(response1.body);
      plateData = dataUser['user_details'];
      await db.ofSaveLocationUsers(plateData[i]['d_loc_user_id'],plateData[i]['d_user_id'],plateData[i]['d_location_id'],plateData[i]['d_emp_id']);
      if(i == count-1){
        downloadManager();
      }
    }
  }

   Future downloadManager() async{
    setState(() {
      statusNumber = "4/5";
      statusText = "Updating managers";
    });


     int count;
     int res = await db.countTblManager();
     count = res;
     await db.emptyManagerTbl();
     for(int i = 0; i < count; i++) {
       Map dataUser;
       List plateData;
       final response1 = await http.post("http://172.16.46.130/e_parking/app_downLoadManager", body: {
         "tohide": "tohide"
       });
       dataUser = jsonDecode(response1.body);
       plateData = dataUser['user_details'];
       await db.ofSaveManagers(plateData[i]['d_emp_id'],plateData[i]['d_username'],plateData[i]['d_password'],plateData[i]['d_usertype'],plateData[i]['d_status']);
       if(i == count-1){
         downloadLocation();
       }
     }
   }

  Future downloadLocation() async{


    setState(() {
      statusNumber = "5/5";
      statusText = "Updating locations";
    });

    int count;
    int res = await db.countTblLocation();
    count = res;
    await db.emptyLocationTbl();
    for(int i = 0; i < count; i++) {
      Map dataUser;
      List plateData;
      final response1 = await http.post("http://172.16.46.130/e_parking/app_downLoadlocation", body: {
        "tohide": "tohide"
      });
      dataUser = jsonDecode(response1.body);
      plateData = dataUser['user_details'];
      await db.ofSaveLocation(plateData[i]['d_location_id'],plateData[i]['d_location'],plateData[i]['d_location_address'],plateData[i]['d_status']);
      if(i == count-1){
       Fluttertoast.showToast(
           msg: "Transactions are successfully uploaded",
           toastLength: Toast.LENGTH_LONG,
           gravity: ToastGravity.BOTTOM,
           timeInSecForIos: 2,
           backgroundColor: Colors.black54,
           textColor: Colors.white,
           fontSize: 16.0
       );
       Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState(){
    super.initState();
    syncTransData();
  }
  @override
  Widget build(BuildContext context) {
    double setHeight;
    double screenHeight = MediaQuery.of(context).size.height;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if(isPortrait == true){
      setHeight = screenHeight - 490;
    }else{
      setHeight = screenHeight - 280;
    }
    return new Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height:setHeight,
          ),
          GradientText('Syncing...',
          gradient: LinearGradient(colors: [Colors.deepOrangeAccent, Colors.blue, Colors.pink]),
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center),
          SizedBox(
            height: 40,
          ),
          Center(
            child:SpinKitRing(
              color: Colors.blue,
              size: 80,
            ),

          ),
          SizedBox(
            height: 40,
          ),
          GradientText(statusNumber,
              gradient: LinearGradient(colors: [Colors.deepOrangeAccent, Colors.blue, Colors.pink]),
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center),
          SizedBox(
            height: 20,
          ),
          GradientText(statusText,
              gradient: LinearGradient(colors: [Colors.black, Colors.blue, Colors.blueGrey]),
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}


