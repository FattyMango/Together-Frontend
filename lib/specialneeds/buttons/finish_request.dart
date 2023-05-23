import 'package:flutter/material.dart';

import '../../../deserializers/request.dart';
import '../../../deserializers/user.dart';

class FinishRequestButtom extends StatefulWidget {
final Function submit_request;
   const FinishRequestButtom(
      {super.key, required this.submit_request});

  @override
  State<FinishRequestButtom> createState() => _FinishRequestButtomState();
}

class _FinishRequestButtomState extends State<FinishRequestButtom> {
  String get_text(){
    return "Finish request";
  }

  Color get_primary_color(){return Color.fromARGB(255, 240, 54, 25);}

  Color get_secondary_color(){return Color.fromARGB(231, 242, 253, 255);}

  Widget get get_button{
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
      width: 175,
      height: 60,
      child: ElevatedButton(
        onPressed: (){widget.submit_request();},
        child: Text(
          get_text(),
          style: TextStyle(color: get_primary_color(),fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
            fixedSize: Size(50, 35),
            backgroundColor: get_secondary_color()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => get_button;
}