import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PayParkingFileCreator {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get transactionType async {
    final path = await _localPath;
    return File('$path/transaction_type.txt');
  }


  Future<File> get transactions async {
    final path = await _localPath;
    return File('$path/transactions.txt');
  }

  Future<String> readContent() async {
    try {
      final file = await transactions;
      // Read the file
      String contents = await file.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return 'Error!';
    }
  }

  Future<File> transactionTypeFunc(text) async {
    final file = await transactionType;
    // Write the file
    return file.writeAsString(text);
  }

  Future<File> transactionsFunc(String uid,String checkDigitResult,String plateNumber,String dateToday,String dateTimeToday,String dateUntil,String amount,String empId,String locationAnew) async {
    final file = await transactions;
    // Write the file
    String text = uid+"\n"+checkDigitResult+"\n"+plateNumber+"\n"+dateToday+"\n"+dateTimeToday+"\n"+dateUntil+"\n"+amount+"\n"+empId+"\n"+locationAnew;
    return file.writeAsString(text);
  }

  Future<File> transPenaltyFunc(uid,checkDigit,plateNumber,dateIn,dateNow,amountPay,penalty,user,empNameIn,outBy,empNameOut,location) async{
    final file = await transactions;
    String text = dateNow+"\n"+plateNumber+"\n"+amountPay+"\n"+checkDigit+"\n"+dateIn+"\n"+dateNow+"\n"+penalty;
    return file.writeAsString(text);
  }
}