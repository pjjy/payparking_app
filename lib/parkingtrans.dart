import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:payparking_app/utils/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class ParkTrans extends StatefulWidget {
  final String empId;
  final String name;
  final String location;

  ParkTrans({Key key, @required this.empId, this.name, this.location}) : super(key: key);
  @override
  _ParkTrans createState() => _ParkTrans();
}
class _ParkTrans extends State<ParkTrans>{
  final db = PayParkingDatabase();
  File pickedImage;
  bool pressed = true;
  String locationA = "Add Location";
  var wheel = 0;
  Color buttonBackColorA;
  Color textColorA = Colors.black45;
  Color buttonBackColorB;
  Color textColorB = Colors.black45;
  Future setWheelA() async{

      setState(() {

        buttonBackColorA = Colors.lightBlue;
        buttonBackColorB = Colors.white;
        textColorA = Colors.black45;

        wheel = 50;
      });
  }

  Future setWheelB() async{

    setState(() {

      buttonBackColorB = Colors.lightBlue;
      buttonBackColorA = Colors.white;
      textColorB = Colors.black45;

      wheel = 100;
    });
  }

  Future addLocation() async{
    bool result = await DataConnectionChecker().hasConnection;
    if(result == true)
    {
//      setState(() {
//        locationA = "location A";
//        print(locationA);
//      });
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("Select Location"),
            actions: <Widget>[
              Radio(
                value: 100,
                groupValue: selectedRadio,
                activeColor: Colors.blue,
                onChanged:(val) {
                  setSelectedRadio(val);
                },
              ),
            ],
          );
        },
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

  Future pickImage() async{
    plateNoController.clear();
    String platePattern = r"([A-Z|\d]+[\s|-][A-Z\d]+)"; //platenumber regex
//    String platePattern =  r"([A-Z|\d]+[\s|-][0-9]+)";
    RegExp regEx = RegExp(platePattern);
    String platePatternNew;


    var _imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      pickedImage = _imageFile;
    });
    if(_imageFile!=null){
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: _imageFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.white,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
      );

      setState(() {
        _imageFile = croppedFile ?? _imageFile;
      });
      if(croppedFile!=null){
      final image = FirebaseVisionImage.fromFile(croppedFile);
        TextRecognizer recognizedText = FirebaseVision.instance.textRecognizer();
        VisionText readText = await recognizedText.processImage(image);
        if(regEx.hasMatch(readText.text)){
//          print(true);
          platePatternNew = readText.text;
          if(this.mounted){
            setState(() {
//              print(regEx.firstMatch(platePatternNew).group(0));
              plateNoController.text = regEx.firstMatch(platePatternNew).group(0);
              recognizedText.close();
            });
          }
        }
        else{
          print(false);
        }
      }else{
        print('No cropped image');
      }
    }else{
      print('No image');
    }

  }


  TextEditingController plateNoController = TextEditingController();

  void confirmed(){
    print(wheel);
    if(plateNoController.text == "" || locationA == "Add Location"){
//      var today = new DateTime.now();
//      var dateToday = DateFormat("yyyy-MM-dd").format(new DateTime.now());
//      var dateUntil = DateFormat("yyyy-MM-dd").format(today.add(new Duration(days: 7)));
//      print(dateToday);
//      print(dateUntil);
//      print(selectedRadio);
    }
    else {
      if(wheel == 0){

      }
      else{
        saveData();
       }
     }
   }

  void saveData() async{

      bool result = await DataConnectionChecker().hasConnection;
      String plateNumber = plateNoController.text;
      var today = new DateTime.now();
      var dateToday = DateFormat("yyyy-MM-dd").format(new DateTime.now());
      var dateTimeToday = DateFormat("H:mm").format(new DateTime.now());
      var dateUntil = DateFormat("yyyy-MM-dd").format(today.add(new Duration(days: 7)));
      String amount = wheel.toString();
      var stat = 1;
      var user = widget.empId;


//      print(plateNumber);
//      print(dateToday);
//      print(dateTimeToday);
//      print(dateUntil);
//      print(amount);
//      print(stat);
//      print(user);
    if(result == true){
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text(plateNoController.text),
            content: new Text("Successfully Added ,Printing the Receipt"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                  plateNoController.text = "";
                },
              ),
            ],
          );
        },
      );
      await db.olSaveTransaction(plateNumber,dateToday,dateTimeToday,dateUntil,amount,user,stat,widget.location);
//      await db.addTrans(plateNumber,dateToday,dateTimeToday,dateUntil,amount,user,stat);
      Fluttertoast.showToast(
          msg: "Successfully Added to Transactions",
          toastLength: Toast.LENGTH_LONG,
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

  int selectedRadio;
  String name;
  @override
  void initState(){
    super.initState();
    selectedRadio = 0;
    //mo prompt if na setupan na ug location or naay internet
  }

  void setSelectedRadio(int val){
    setState(() {
      selectedRadio = val;
    });
  }


  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Park Me',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {},
            child: Text(widget.name.toString(),style: TextStyle(fontSize: 14,color: Colors.black),),
          ),
        ],
        textTheme: TextTheme(
            title: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            )
        ),
      ),
      body: ListView(
//          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
//             child:NiceButton(
//                width: 255,
//                elevation: 0.0,
//                radius: 52.0,
//                fontSize: 18.0,
//                text: "Open Camera",
//                icon: Icons.camera_alt,
//                padding: const EdgeInsets.all(15),
//                background: Colors.blue,
//                onPressed:pickImage,
//             ),

              child: MaterialButton(
                minWidth: 100.0,
                height: 40.0,
                onPressed:pickImage,
                child:FlatButton.icon(
                  label: Text('Open Camera',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0, color: Colors.lightBlue),),
                  splashColor: Colors.lightBlue,
                  icon: Icon(Icons.camera_alt, color: Colors.lightBlue,),
                  padding: EdgeInsets.all(14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(35.0),
                      side: BorderSide(color: Colors.lightBlue)
                  ),
                  onPressed:(){
//
                  },
                ),
              ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
              child: new TextFormField(
               controller:plateNoController,
               autofocus: false,
//               enabled: false,
               style: TextStyle(fontSize: 70.0),
                    decoration: InputDecoration(
                    hintText: 'Plate Number',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 40.0, 40.0, 50.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                      suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 30.0),
                        child:  Icon(Icons.directions_car, color: Colors.grey,size: 40.0,),
                      ),
                  ),
            ),
         ),
          Divider(
            color: Colors.transparent,
            height: 25.0,
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child:Text('Vehicle Type',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.black),),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
           child: Row(
             children: <Widget>[
               FlatButton.icon(
                 label: Text('4 wheels'.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0, color: textColorA),),
                 splashColor: Colors.lightBlue,
                 color: buttonBackColorB,
                 icon: Icon(Icons.directions_car, color: textColorA,),
                 shape: RoundedRectangleBorder(
                     borderRadius: new BorderRadius.circular(18.0),
                     side: BorderSide(color: Colors.lightBlue)
                 ),
                 onPressed:(){
                   setWheelB();
                 },
               ),
               Text("   "),
               FlatButton.icon(
                 label: Text('2 wheels'.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0, color: textColorB),),
                 splashColor: Colors.lightBlue,
                 color: buttonBackColorA,
                 icon: Icon(Icons.motorcycle, color: textColorB,),
                 shape: RoundedRectangleBorder(
                     borderRadius: new BorderRadius.circular(18.0),
                     side: BorderSide(color: Colors.lightBlue)
                 ),
                 onPressed:(){
                    setWheelA();
                 },
               ),
               Text("   "),
//               Radio(
//                value: 100,
//                groupValue: selectedRadio,
//                activeColor: Colors.blue,
//                onChanged:(val) {
//                    setSelectedRadio(val);
//                },
//               ),
//               Text("2 Wheels(50)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
//               Radio(
//                 value: 50,
//                 groupValue: selectedRadio,
//                 activeColor: Colors.blue,
//                 onChanged:(val) {
//                   setSelectedRadio(val);
//                 },
//               ),
               FlatButton.icon(
                 label: Text(locationA.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0, color: Colors.black45),),
                 splashColor: Colors.lightBlue,
                 icon: Icon(Icons.location_on, color: Colors.black45,),
                 shape: RoundedRectangleBorder(
                     borderRadius: new BorderRadius.circular(18.0),
                     side: BorderSide(color: Colors.lightBlue)
                 ),
                 onPressed: addLocation,
               ),
             ]
            ),
          ),


          Padding( padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
           child: Container(
//              width: 400.0,
              child: ConfirmationSlider(
                shadow:BoxShadow(color: Colors.black38, offset: Offset(1, 0),blurRadius: 1,spreadRadius: 1,),
                foregroundColor:Colors.blue,
                height:170.0,
                width : width-60,
                onConfirmation: () => confirmed(),
            ),),
        ),
      ],
     ),
    );
  }
}