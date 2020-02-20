import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:data_connection_checker/data_connection_checker.dart';


class SyncingPage extends StatefulWidget{
  @override
  _SyncingPage createState() => new _SyncingPage();
}
class _SyncingPage extends State<SyncingPage>{
   List hisData;
   final db = PayParkingDatabase();

   var appId;
   String plateNumber;
   String dateTimeIn;
   String dateTimeout;
   var amount;
   var penalty;
   String user;
   String outBy;

   Future syncTransData() async{

    var res = await db.fetchAllHistory();

    setState(() {
      hisData = res;

    });
    if(hisData.isEmpty){
      Navigator.of(context).pop();
      print('wala pay sulod');
    }else{
      bool result = await DataConnectionChecker().hasConnection;
      if(result == true){
        print("Wifi Connected");
        for(int i = 0; i < hisData.length; i++){
          plateNumber = hisData[i]['plateNumber'];
          dateTimeIn = hisData[i]['dateTimein'];
          dateTimeout = hisData[i]['dateTimeout'];
          amount = hisData[i]['amount'];
          penalty = hisData[i]['penalty'];
          user = hisData[i]['user'];
          outBy = hisData[i]['outBy'];
          await http.post("http://172.16.46.130/e_parking/sync_data",body:{
            "plateNumber": plateNumber,
            "dateTimeIn": dateTimeIn,
            "dateTimeout": dateTimeout,
            "amount": amount,
            "penalty": penalty,
            "user": user,
            "outBy":outBy,
          });
          if(i == hisData.length-1){
            Fluttertoast.showToast(
                msg: "Data are synced successfully",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 2,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pop();
            print('Sync done');
          }
        }
      }
      else{
        print("No Wifi Connected");

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
      setHeight=screenHeight-490;
    }else{
      setHeight=screenHeight-280;
    }
    return new Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height:setHeight,
          ),
          GradientText("Syncing...",
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
        ],
      ),
    );
  }
}