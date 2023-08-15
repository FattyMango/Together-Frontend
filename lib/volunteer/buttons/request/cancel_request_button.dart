import 'package:flutter/material.dart';
import 'package:together/volunteer/buttons/request/request_button.dart';

import '../../../deserializers/request.dart';
import '../../../deserializers/user.dart';
import '../../../misc/backend.dart';
import '../../../request/requests.dart';

class CancelRequestButton extends AbstractRequestButton {
  CancelRequestButton(
      {super.key,
      required super.user,
      required super.request,
      required super.set_accepted,
      required super.ErrorDialog})
      : super();

  @override
  AbstractRequestButtonState createState() => _CancelRequestButtonState();
}

class _CancelRequestButtonState extends AbstractRequestButtonState {
  decline_request() async {
    Map<String, dynamic> res = await put_request(
        url: apiUrl+"/request/api/cancel/${widget.request.id.toString() }/" 
            ,

        headers: {"Authorization": "Token " + widget.user.token}, body: {});
    // if (res["response"] == "Error") widget.ErrorDialog(res["message"]);

    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/volunteer/home');
    });


  }



  @override
  Color get_primary_color() {
    return Color.fromARGB(255, 240, 54, 25);
  }

  @override
  Color get_secondary_color() {
    return Color.fromARGB(231, 242, 253, 255);
  }

  @override
  String get_text() {
    return "Cancel Request";
  }

  @override
  on_press() {
    decline_request();
  }
}
