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
   int progress = 1;

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

//          print(uid);
//          print(checkDigit);
//          print(plateNumber);
//          print(dateTimeIn);
//          print(dateTimeout);
//          print(amount);
//          print(penalty);
//          print(user);
//          print(empNameIn);
//          print(outBy);
//          print(empNameOut);
//          print(location);

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
          }
        }
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
        ],
      ),
    );
  }
}