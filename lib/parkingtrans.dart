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
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'couponPrint.dart';

class ParkTrans extends StatefulWidget {
  final String empId;
  final String name;
  final String location;

  ParkTrans({Key key, @required this.empId, this.name, this.location}) : super(key: key);
  @override
  _ParkTrans createState() => _ParkTrans();
}
class _ParkTrans extends State<ParkTrans>{

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;
  CouponPrint couponPrint;




  final db = PayParkingDatabase();
  File pickedImage;
  bool _isEnabled = true;
  String locationA = "Location";
  var wheel = 0;
  Color buttonBackColorA;
  Color textColorA = Colors.black45;
  Color buttonBackColorB;
  Color textColorB = Colors.black45;
   setWheelA() {
      setState(() {
        buttonBackColorA = Colors.lightBlue;
        buttonBackColorB = Colors.transparent;
        textColorA = Colors.black45;
        wheel = 50;
      });
  }

   setWheelB() {
    setState(() {
      buttonBackColorB = Colors.lightBlue;
      buttonBackColorA = Colors.transparent;
      textColorB = Colors.black45;
      wheel = 100;
    });
  }

  List<Widget> _getList() {
     String location = widget.location;
     var locCount = location.split(",").length;
     var locSplit = location.split(",");
     var counter  = locCount;

     counter = counter-1;

     List<Widget> temp = [];
    for(var q = 0; q < locCount; q++) {
      temp.add(
          FlatButton(
            child: new Text(locSplit[q]),
            onPressed: () {
              setState(() {
                Navigator.of(context, rootNavigator: true).pop();
                locationA = locSplit[q];
              });
            },
          ),
      );
      if(q >= counter){
        temp.add(
          FlatButton(
            child: new Text("Close "),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              locationA = 'Location';
            },
          ),
        );
      }
    }
    return temp;
  }

  Future trapLocation() async{
    var res = await db.trapLocation(widget.empId);
    if(res == true){
       _isEnabled = false;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return CupertinoAlertDialog(
            title: new Text("Location Problem"),
            content: new Text("This user has no location yet please contact your admin for location setup"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
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
    }
  }

   void addLocation() async{
       showDialog(
         barrierDismissible: true,
         context: context,
         builder: (BuildContext context) {
           // return object of type Dialog
           return CupertinoAlertDialog(
             title: Text('Add Location'),
             actions: _getList(),
           );
         },
       );
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

    if(plateNoController.text == "" || locationA == "Location"){
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
      if(_connected == false){
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return CupertinoAlertDialog(
              title: new Text("Connection Problem"),
              content: new Text("Plese turn the bluetooth on"),
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
      }
      else{
        saveData();
       }
     }
   }


  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItemsDropDown() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }



  void _connect() {
    if (_device == null) {
//      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
          print('wala');
        }
      });
      print('naa');
    }
  }


  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _pressed = true);
  }

  void saveData() async{

      var uid = DateFormat("yyMdHms").format(new DateTime.now());

      bool result = await DataConnectionChecker().hasConnection;
      String plateNumber = plateNoController.text;
      var today = new DateTime.now();
      var dateToday = DateFormat("yyyy-MM-dd").format(new DateTime.now());
      var dateTimeToday = DateFormat("H:mm").format(new DateTime.now());
      var dateUntil = DateFormat("yyyy-MM-dd").format(today.add(new Duration(days: 7)));
      String amount = wheel.toString();
      var stat = 1;
      var user = widget.empId;

      var dateTodayP = DateFormat("yyyy-MM-dd").format(new DateTime.now());
      var dateTimeTodayP = DateFormat("jm").format(new DateTime.now());
      var dateUntilP = DateFormat("yyyy-MM-dd").format(today.add(new Duration(days: 7)));
//      print(plateNumber);
//      print(dateToday);
//      print(dateTimeToday);
//      print(dateUntil);
//      print(amount);
//      print(stat);
//      print(user);
//        print(uid);
//        print(uid);
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
      couponPrint.sample(plateNumber,dateTodayP,dateTimeTodayP,dateUntilP,amount,user,stat,locationA);
      await db.olSaveTransaction(uid,plateNumber,dateToday,dateTimeToday,dateUntil,amount,user,stat,locationA);
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
      locationA = "Location";
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

  @override
  void initState(){
    super.initState();
    initPlatformState();
    trapLocation();
    couponPrint = CouponPrint();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text('Park Me',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/28, color: Colors.black),),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {},
            child: Text(widget.name.toString(),style: TextStyle(fontSize: width/36,color: Colors.black),),
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
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 30.0),
                child: MaterialButton(
                  height: 40.0,
                  onPressed:(){},
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
                      pickImage();
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 30.0),
//                child: MaterialButton(
//                  height: 40.0,
//                  onPressed:(){},
//                  child:FlatButton.icon(
//                    label: Text(btName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0, color: Colors.lightBlue),),
//                    splashColor: Colors.lightBlue,
//                    icon: Icon(Icons.local_printshop, color: Colors.lightBlue,),
//                    padding: EdgeInsets.all(14.0),
//                    shape: RoundedRectangleBorder(
//                        borderRadius: new BorderRadius.circular(35.0),
//                        side: BorderSide(color: Colors.lightBlue)
//                    ),
//                    onPressed:(){
//                      _getDeviceItems();
//                    },
//                  ),
//                ),
               child: DropdownButton(
                  items: _getDeviceItemsDropDown(),
                  onChanged: (value) => setState(() => _device = value),
                  value: _device,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 30.0),
                child: MaterialButton(
                  height: 40.0,
                  onPressed:(){},
                  child:FlatButton.icon(
                    label: Text(_connected ? 'Disconnect' : 'Connect',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0, color: Colors.lightBlue),),
                    splashColor: Colors.lightBlue,
                    icon: Icon(Icons.local_printshop, color: Colors.lightBlue,),
                    padding: EdgeInsets.all(14.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(35.0),
                        side: BorderSide(color: Colors.lightBlue)
                    ),
                    onPressed:
                    _pressed ? null : _connected ? _disconnect : _connect,
                  ),
                ),
              ),
            ],
        ),
      ),

          Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
              child: new TextFormField(
               controller:plateNoController,
               autofocus: false,
               enabled: _isEnabled,
               style: TextStyle(fontSize: width/15),
                    decoration: InputDecoration(
                    hintText: 'Plate Number',
                    contentPadding: EdgeInsets.all(width/15.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                      suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 30.0),
                        child:  Icon(Icons.format_list_numbered, color: Colors.grey,size: 40.0,),
                      ),
                  ),
            ),
         ),
          Divider(
            color: Colors.transparent,
            height: 15.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child:Text('Vehicle Type & Location',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black45),),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child:Column(
                children: <Widget>[
                  FlatButton.icon(
                    label: Text('4 wheels'.toString(),style: TextStyle(fontSize: width/33.0, color: textColorA),),
                    splashColor: Colors.lightBlue,
                    color: buttonBackColorB,
                    icon: Icon(Icons.directions_car, color: textColorA,size: width/20.0,),
                    padding: EdgeInsets.symmetric(horizontal: width/20.0,vertical: 15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(35.0),
                        side: BorderSide(color: Colors.lightBlue)
                    ),
                    onPressed:(){
                      setWheelB();
                    },
                  ),
                Text("   "),
                  FlatButton.icon(
                    label: Text('2 wheels'.toString(),style: TextStyle(fontSize: width/33.0, color: textColorB),),
                    splashColor: Colors.lightBlue,
                    color: buttonBackColorA,
                    icon: Icon(Icons.motorcycle, color: textColorB,size: width/20.0,),
                    padding: EdgeInsets.symmetric(horizontal:width/20.0,vertical: 15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(35.0),
                        side: BorderSide(color: Colors.lightBlue)
                    ),
                    onPressed:(){
                      setWheelA();
                    },
                  ),
                Text("   "),
                  FlatButton.icon(
                    label: Text(locationA.toString(),style: TextStyle(fontSize: width/33.0, color: Colors.black45),),
                    splashColor: Colors.lightBlue,
                    icon: Icon(Icons.location_on, color: Colors.black45,size: width/20.0,),
                    padding: EdgeInsets.symmetric(horizontal:width/20.0,vertical: 15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(35.0),
                        side: BorderSide(color: Colors.lightBlue)
                    ),
                    onPressed: addLocation,
                  ),
              ]),
            ),

            Padding( padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20.0),
              child: Container(
//              width: 400.0,
                child: ConfirmationSlider(
                  shadow:BoxShadow(color: Colors.black38, offset: Offset(1, 0),blurRadius: 1,spreadRadius: 1,),
                  foregroundColor:Colors.blue,
                  height: height/6,
                  width : width-50,
                  onConfirmation: () => confirmed(),
                ),),
            ),
       ],
      ),
     );
  }
}