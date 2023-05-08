import 'package:flutter/material.dart';

import '../../../deserializers/request.dart';
import '../../../deserializers/user.dart';

class SendRequestButton extends StatefulWidget {

   const SendRequestButton(
      {super.key});
      
    State<StatefulWidget> createState() => _SendRequestButtonState();
  
  
}
class _SendRequestButtonState extends State<SendRequestButton> {
  on_press(){}
  String get_text(){
    return "Request help!";
  }
  Color get_primary_color(){return Color.fromARGB(231, 5, 146, 171);}
  Color get_secondary_color(){return Color.fromARGB(231, 242, 253, 255);}
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