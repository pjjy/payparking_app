import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'parkingtrans.dart';
import 'parkingTransList.dart';
import 'history.dart';
import  'settings.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'dart:async';
import 'dart:io';

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
  String empNameFn;
  String location;
  String userImage;

  String data;



  Future<File> getUserData() async{
    var res =  await db.olFetchUserData(widget.logInData);
    setState((){
      userData = res["user_details"];
      empId = userData[0]["emp_id"];
      name = userData[0]["emp_name"];
      empNameFn = userData[0]["emp_namefn"];
      location = userData[0]["location"];
      userImage = userData[0]["user_image"];
    });

  }

  @override
  void initState(){
    super.initState();

//    writeContent();
    if(empId == null || name == null || location == null || empNameFn == null || userImage == null)
    {
      empId = "";
      name = "";
      empNameFn = "";
      location = "";
      userImage = "";
    }else{
      empId = empId;
      name = name;
      empNameFn = empNameFn;
      location = location;
      userImage = userImage;
    }
    getUserData();
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    var  defFontSize = 12.0;
    if(width <= 400){
      defFontSize = 10.0;
    }
    else{
      defFontSize = 12.0;
    }
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home,size: 25.0),
            title: Text('Park me',style: TextStyle(
              fontSize: defFontSize, // insert your font size here
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.collections,size: 25.0),
            title: Text('Transactions',style: TextStyle(
              fontSize:  defFontSize, // insert your font size here
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.share_up,size: 25.0),
            title: Text('History',style: TextStyle(
              fontSize: defFontSize, // insert your font size here
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person,size: 25.0),
            title: Text('User',style: TextStyle(
              fontSize: defFontSize, // insert your font size here
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
                child: ParkTransList(empId:empId, name:name, location:location, empNameFn:empNameFn),
              );
            });
          break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: HistoryTransList(location:location),
              );
            });
          break;
          case 3:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: Settings(empNameFn:empNameFn, userImage:userImage, location:location),
              );
            });
          break;
        }
        return returnValue;
      },
    );
  }
}



