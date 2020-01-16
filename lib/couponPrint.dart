import 'package:blue_thermal_printer/blue_thermal_printer.dart';





class CouponPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample(uid,plateNumber,dateTodayP,dateTimeTodayP,dateUntilP,amount,user,stat,locationA) async {
//    String dateTodayf = DateFormat("yyyy-MM-dd").format(dateToday);v
    String type;
    bluetooth.isConnected.then((s) {
      if (s){
        if(amount==100){
          type="4 Wheeled";
        }
        if(amount==50){
          type="2 Wheeled";
        }
        bluetooth.printNewLine();
        bluetooth.printCustom("                     AGC SURFACE PAY PARKING",3,0);
//        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
        bluetooth.printLeftRight("", "  Ticket #  :"+uid,3);
        bluetooth.printLeftRight("", "                Date Issued   :" +dateTodayP+" @ "+dateTimeTodayP,3);
        bluetooth.printLeftRight("","   Valid Until   :"+dateUntilP,3);
        bluetooth.printLeftRight("","             Consumable Coupon  :"+amount+".00",3);
//        bluetooth.printLeftRight("","          Php "+amount+".00",1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();




//        bluetooth.printCustom("AGC SURFACE PAY PARKING",3,0);
//        bluetooth.printLeftRight("","PARKING TICKET",3);
//        bluetooth.printCustom("                                              PARKING TICKET",3,0);
//        bluetooth.printNewLine();
//        bluetooth.printNewLine();
//
//        bluetooth.printLeftRight("", "       Type        :""4 WHEELED",3);
//        bluetooth.printLeftRight("", "      Ticket No.   :""LTO 1234",3);
//        bluetooth.printLeftRight("", "  Transaction Code   :""LTO 1234",3);
//        bluetooth.printLeftRight("", "  Date   :""LTO 1234",3);
//        bluetooth.printLeftRight("", "  Time   :""LTO 1234",3);
//        bluetooth.printLeftRight("", "        Plate No.   :""LTO 12314",3);
//        bluetooth.printImage(pathImage);


//        bluetooth.printNewLine();
//        bluetooth.printNewLine();
//        bluetooth.printLeftRight("", "  Ticket #      :001221",3);
//        bluetooth.printLeftRight("", "                 Date          :" +dateTodayP+" @ "+dateTimeTodayP,3);
//        bluetooth.printLeftRight("","   Valid until   :"+dateUntilP,3);
//        bluetooth.printNewLine();
//        bluetooth.printNewLine();
      }
     }
    );
  }
}