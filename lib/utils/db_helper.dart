import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'dart:convert';




class PayParkingDatabase {
  static final PayParkingDatabase _instance = PayParkingDatabase._();
  static Database _database;

  PayParkingDatabase._();

  factory PayParkingDatabase() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database;
    }
    _database = await init();
    return _database;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'payparking.db');
    var database = openDatabase(dbPath, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);

    return database;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE paypartrans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plateNumber TEXT,
        dateToday TEXT,
        dateTimeToday TEXT,
        dateUntil TEXT,
        amount TEXT,
        user TEXT,
        status TEXT)''');

    db.execute('''
      CREATE TABLE payparhistory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plateNumber TEXT,
        dateTimein TEXT,
        dateTimeout TEXT,
        amount TEXT,
        penalty TEXT,
        user TEXT,
        empNameIn TEXT,
        outBy TEXT,
        empNameOut TEXT,
        location TEXT
        )''');

    db.execute('''
      CREATE TABLE synchistory(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        syncDate TEXT
        )''');

    print("Database was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

  Future<int> addTrans(String plateNumber, String dateToday, String dateTimeToday, String dateUntil,String amount,String user,int stat) async {
    var client = await db;
    return client.insert('paypartrans', {'plateNumber':plateNumber,'dateToday':dateToday,'dateTimeToday':dateTimeToday,'dateUntil':dateUntil,'amount':amount,'user':user,'status':stat});
  }

  Future<List> fetchAll() async {
    var client = await db;
    return client.query('paypartrans Where status = 1');
    // where status = 1
  }

  Future<List> fetchSync() async{
    var client = await db;
    return client.query('synchistory ORDER BY id DESC LIMIT 1');
  }

  Future<int> insertSyncDate(String date) async{
    var client = await db;
    return client.insert('synchistory', {'syncDate':date});
  }


  Future<List> fetchAllHistory() async {
    var client = await db;
    var res = await client.query('payparhistory ORDER BY id DESC');
    if (res.isNotEmpty) {
      return client.query('payparhistory ORDER BY id DESC');
    }
    else{
      return [];
    }
  }

  Future<int> addTransHistory(String plateNumber,String dateIn,String dateNow,String amountPay,String penalty,String user,String empNameIn,String outBy, String empNameOut,String location) async {
    var client = await db;
    return client.insert('payparhistory', {'plateNumber':plateNumber,'dateTimein':dateIn,'dateTimeout':dateNow,'amount':amountPay,'penalty':penalty,'user':user,'empNameIn':empNameIn,'outBy':outBy,'empNameOut':empNameOut ,'location':location});
  }

  Future<int> updatePayTranStat(int id) async{
    var client = await db;
    return client.update('paypartrans', {'status': '0'}, where: 'id = ?', whereArgs: [id]);
  }

 //mysql query code

  Future mysqlLogin(username,password) async{
      final response = await http.post("http://172.16.46.130/e_parking/app_login",body:{
        "username": username,
        "password": password,
      });
      if(response.body.length >=1  && response.statusCode == 200){
        return response.body;
      }else{
        return 'error';
      }
  }

  Future olFetchUserData(userId) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/app_getUserData",body:{
      "userId": userId,
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olSaveTransaction(plateNumber,dateToday,dateTimeToday,dateUntil,amount,user,stat,location) async{
     await http.post("http://172.16.46.130/e_parking/olSaveTransaction",body:{
      'plateNumber':plateNumber.toString(),
      'dateToday':dateToday.toString(),
      'dateTimeToday':dateTimeToday.toString(),
      'dateUntil':dateUntil.toString(),
      'amount':amount.toString(),
      'user':user.toString(),
      'stat':stat.toString(),
      'location':location.toString(),
    });
  }

  Future olFetchAll(location) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/appGetTransaction",body:{
          'location':location.toString()
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olAddTransHistory(id,plateNumber,dateIn,dateNow,amountPay,penalty,user,outBy,location) async{
    await http.post("http://172.16.46.130/e_parking/appSaveToHistory",body:{
          'id':id.toString(),
          'plateNumber':plateNumber.toString(),
          'dateIn':dateIn.toString(),
          'dateNow':dateNow.toString(),
          'amountPay':amountPay.toString(),
          'penalty':penalty.toString(),
          'user':user.toString(),
          'outBy':outBy.toString(),
          'location':location.toString(),
    });
  }

  Future olUpdateTransaction(id,plateNumber,wheel,locationA) async{
    await http.post("http://172.16.46.130/e_parking/appUpdateTrans",body:{
          'id':id.toString(),
          'plateNumber':plateNumber.toString(),
          'wheel':wheel.toString(),
          'locationA':locationA.toString(),
    });
  }

  Future trapLocation(id) async{
    final response = await http.post("http://172.16.46.130/e_parking/trapLocation",body:{
      "id": id.toString(),
    });
    if(response.body.toString() == 'true'  ){
      return true;
    }else{
      return false;
    }
  }
  Future olFetchSearch(text,location) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/olFetchSearch",body:{
      "text": text.toString(),
      "location":location.toString(),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }

  Future olFetchSearchHistory(text,location) async{
    Map dataUser;
    final response = await http.post("http://172.16.46.130/e_parking/olFetchSearchHistory",body:{
      "text": text.toString(),
      "location":location.toString(),
    });
    dataUser = jsonDecode(response.body);
    return dataUser;
  }


//  Future<Car> fetchCar(int id) async {
//    var client = await db;
//    final Future<List<Map<String, dynamic>>> futureMaps = client.query('car', where: 'id = ?', whereArgs: [id]);
//    var maps = await futureMaps;
//
//    if (maps.length != 0) {
//      return Car.fromDb(maps.first);
//    }
//
//    return null;
//  }
//
//  Future<List<Car>> fetchAll() async {
//    var client = await db;
//    var res = await client.query('car');
//
//    if (res.isNotEmpty) {
//      var cars = res.map((carMap) => Car.fromDb(carMap)).toList();
//      return cars;
//    }
//    return [];
//  }
//
//  Future<int> updateCar(Car newCar) async {
//    var client = await db;
//    return client.update('car', newCar.toMapForDb(),
//        where: 'id = ?', whereArgs: [newCar.id], conflictAlgorithm: ConflictAlgorithm.replace);
//  }
//
//  Future<void> removeCar(int id) async {
//    var client = await db;
//    return client.delete('car', where: 'id = ?', whereArgs: [id]);
//  }
//
//  Future closeDb() async {
//    var client = await db;
//    client.close();
//  }
}
