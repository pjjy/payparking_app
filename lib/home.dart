import 'package:flutter/cupertino.dart';
import 'parkingtrans.dart';
import 'parkingTransList.dart';
import 'history.dart';
import  'settings.dart';
import 'package:payparking_app/utils/db_helper.dart';
import 'dart:async';
import 'package:flutter/material.dart';


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
  String loc;
  String data;
  Timer timer;
  int counter;

  Future getCounter() async {
    var res = await db.getCounter();
    setState(() {
      if (counter == null) {
        counter = 0;
      } else {
        counter = res;
      }
    });

  }

  Future getUserData() async{
//    var res = await db.olFetchUserData(widget.logInData);
    var count = await db.ofCountFetchUserData(widget.logInData);
    var res = await db.ofFetchUserData(widget.logInData);
    setState((){

      for(var q= 0; q < count; q++){
       userData = res;
       loc = userData[q]['location'];

      }
//      name = userData[0]['fullname'];
      print(loc);

//      userData = count;
//      print(userData[1]['location']);
//      empId = userData[0]["empid"];
//      name = userData[0]["username"];
//      empNameFn = userData[0]["emp_namefn"];
//      location = userData[0]["location"];
//      userImage = userData[0]["user_image"];
    });
  }



  @override
  void initState(){
    super.initState();
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
    super.initState();
    getCounter();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getCounter());

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
            icon: new Stack(
              children: <Widget>[
                new Icon(Icons.notifications),
                new Positioned(
                  right: 0,
                  child: new Container(
                    padding: EdgeInsets.all(3),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: new Text(
                      '$counter',
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
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
                child: ParkTrans(empId:empId, name:name, empNameFn:empNameFn, location:location),
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
                child: HistoryTransList(empId:empId,location:location),
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



