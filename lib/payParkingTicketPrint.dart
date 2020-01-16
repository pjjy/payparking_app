import 'package:blue_thermal_printer/blue_thermal_printer.dart';





class PayParkingTicketPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample(uid,plateNumber,dateTodayP,dateTimeTodayP,dateUntilP,amount,user,stat,locationA) async {
//    String dateTodayf = DateFormat("yyyy-MM-dd").format(dateToday);
    String type;
    bluetooth.isConnected.then((s) {
      if (s){
        if(amount==100){
          type="4 WHEELED";
        }
        if(amount==50){
          type="2 WHEELED";
        }
        bluetooth.printNewLine();
        bluetooth.printCustom("                     AGC SURFACE PAY PARKING",3,0);
//        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
        bluetooth.printLeftRight("", "  Plate No. #      :001221",3);
        bluetooth.printLeftRight("", "           Type          :"+type,3);
        bluetooth.printLeftRight("","   Ticket No.   :"+uid,3);
        bluetooth.printLeftRight("","   Trans. Code   :"+uid,3);
        bluetooth.printLeftRight("","   Date   :"+dateTodayP,3);
        bluetooth.printLeftRight("","   Time   :"+dateTimeTodayP,3);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    }
    );
  }
}