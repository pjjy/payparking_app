import 'package:blue_thermal_printer/blue_thermal_printer.dart';





class CouponPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample(plateNumber,dateTodayP,dateTimeTodayP,dateUntilP,amount,user,stat,locationA) async {
//    String dateTodayf = DateFormat("yyyy-MM-dd").format(dateToday);
    bluetooth.isConnected.then((s) {
      if (s){
        bluetooth.printNewLine();
        bluetooth.printCustom("                     AGC SURFACE PAY PARKING",3,0);
//        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
        bluetooth.printLeftRight("", "     Ticket #: 001221",3);
        bluetooth.printLeftRight("", "                      Date:" +dateTodayP+" @ "+dateTimeTodayP,3);
        bluetooth.printLeftRight("","            Validity:" +dateUntilP,3);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("                                               CONSUMABLE COUPON",3,0);
        bluetooth.printCustom("                                          Php "+amount+".00",3,0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
//        bluetooth.paperCut();
      }
     }
    );
  }
}