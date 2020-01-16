import 'package:blue_thermal_printer/blue_thermal_printer.dart';



class PenaltyPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample() async {
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
        bluetooth.printLeftRight("", "                      Date:" " @ ",3);
        bluetooth.printLeftRight("","            Validity:" ,3);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("                                               CONSUMABLE COUPON",3,0);
        bluetooth.printCustom("                                          Php "".00",3,0);
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