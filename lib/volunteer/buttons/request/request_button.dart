import 'package:flutter/material.dart';

import '../../../deserializers/request.dart';
import '../../../deserializers/user.dart';

abstract class AbstractRequestButton extends StatefulWidget {
  final Function set_accepted;
final UserDeserializer user;
  final RequestDeserializer request;
   AbstractRequestButton(
      {super.key,
      required this.set_accepted, required this.user, required this.request});
  
  
}
abstract class AbstractRequestButtonState extends State<AbstractRequestButton> {
  on_press();
  String get_text();
  Color get_primary_color();
  Color get_secondary_color();
  Widget get_button(){
    return Container(
      decoration: BoxDecoration(
          color: get_secondary_color(),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: get_primary_color(), width: 1.25),
          boxShadow: [
            BoxShadow(
              color: get_primary_color(),
              blurRadius: 6.0,
              spreadRadius: 0.7,
            ), //BoxShadow
          ]),
      width: 145,
      height: 50,
      child: ElevatedButton(
        onPressed: () async => {await on_press()},
        child: Text(
          get_text(),
          style: TextStyle(color: get_primary_color()),
        ),
        style: ElevatedButton.styleFrom(
            fixedSize: Size(50, 35),
            backgroundColor: get_secondary_color()),
      ),
    );
  }
  @override
  Widget build(BuildContext context) => get_button();

}