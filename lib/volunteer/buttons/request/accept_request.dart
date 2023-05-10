import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';

import '../../../deserializers/user.dart';
import '../../../request/requests.dart';
import 'request_button.dart';

class AcceptRequestButton extends AbstractRequestButton {
  
   AcceptRequestButton({super.key, required super.user, required super.request,required super.set_accepted}):super();

  @override
  _AcceptRequestButtonState createState() => _AcceptRequestButtonState();
  
  
}

class _AcceptRequestButtonState extends AbstractRequestButtonState{

  accept_request() async {
    Map<String, dynamic> res = await put_request(
        url: "http://143.42.55.127/request/api/accept/" + widget.request.id.toString() + "/",
        body: {},
        headers: {"Authorization": "Token " + widget.user.token});
        print(res);
    if (res["response"] == "Error") widget.set_accepted(false);
    else
    widget.set_accepted(true);


  }


  
  @override
  Color get_primary_color() {
    return Color.fromARGB(255, 51, 192, 211);
  }
  
  @override
  Color get_secondary_color() {
    return Color.fromARGB(231, 242, 253, 255);
  }
  
  @override
  String get_text() {
    return "Accept request";
  }
  
  @override
  on_press() {
  accept_request();
  }
}
