import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class myDateUtil{
  static String getFormattedTime(
  {required BuildContext context, required String time})
  {
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time,bool showYear =false})
  {
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now= DateTime.now();

    if(now.day==sent.day&&now.month==sent.month&&now.year==sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }else
      return showYear?'${sent.day} ${_getMonth(sent)} ${sent.year}':'${sent.day} ${_getMonth(sent)}';

    //return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive})
  {
    final int i = int.tryParse(lastActive)??-1;

    if(i==-1) return 'last seen not available';
    final DateTime time = DateTime.fromMicrosecondsSinceEpoch(i);
    final DateTime now= DateTime.now();

    String formattedTime=TimeOfDay.fromDateTime(time).format(context);

    if(now.day==time.day&&now.month==time.month&&now.year==time.year){
      return 'Last seen today at $formattedTime';
    }

    if((now.difference(time).inHours/24).round()==1){
      return 'Last seen yesterday at $formattedTime';
    }

    String month= _getMonth(time);
    return 'Last seen on ${time.day} $month on $formattedTime';
    //return TimeOfDay.fromDateTime(date).format(context);
  }

  static String _getMonth(DateTime date){
    switch(date.month){
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';

      case 7:
        return 'Jul';
      case 8:
        return 'Oct';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }

}