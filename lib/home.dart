import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'parkingtrans.dart';
import 'parkingTransList.dart';
import 'history.dart';
import 'package:payparking_app/utils/db_helper.dart';

class HomeT extends StatefulWidget {
  final logInData;
  HomeT({Key key, @required this.logInData}) : super(key: key);
  @override
  _Home createState() => _Home();
}

class _Home extends State<HomeT> {
  final db = PayParkingDatabase();
  List userData;
  String empId;
  String name;
  String location;
  Future getUserData() async{
    var res =  await db.olFetchUserData(widget.logInData);
    setState((){
      userData = res["user_details"];
      empId = userData[0]["emp_id"];
      name = userData[0]["emp_name"];
      location = userData[0]["location"];
    });
  }

  @override
  void initState(){
    super.initState();
    if(empId == null || name == null || location == null)
    {
      empId = "";
      name = "";
      location = "";
    }else{
      empId = empId;
      name = name;
      location = location;
    }
    getUserData();
  }

  @override
  Widget build(BuildContext context){
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            title: Text('Park me',style: TextStyle(
              fontSize: 13.0, // insert your font size here
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.collections),
            title: Text('Transactions',style: TextStyle(
              fontSize: 13.0, // insert your font size here
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.share_up),
            title: Text('History',style: TextStyle(
              fontSize: 13.0, // insert your font size here
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear_big),
            title: Text('Setting',style: TextStyle(
              fontSize: 13.0, // insert your font size here
            ),),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
//                child: ParkTrans(id:id,nameL:nameL,nameF:nameF,location:location),
                child: ParkTrans(empId:empId, name:name, location:location),
              );
            });
          break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: ParkTransList(name:name,location:location),
              );
            });
          break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: HistoryTransList(),
              );
            });
          break;
          case 3:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Text("settings ne"),
              );
            });
          break;
        }
        return returnValue;
      },
    );
  }
}



