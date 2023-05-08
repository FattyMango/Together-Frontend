import 'package:flutter/material.dart';
import 'package:together/volunteer/buttons/request/request_button.dart';

import '../../../deserializers/request.dart';
import '../../../deserializers/user.dart';
import '../../../request/requests.dart';

class DeclineRequestButton extends AbstractRequestButton {
  DeclineRequestButton(
      {super.key,
      required super.user,
      required super.request,
      required super.set_accepted})
      : super();

  @override
  AbstractRequestButtonState createState() => _DeclineRequestButtonState();
}

class _DeclineRequestButtonState extends AbstractRequestButtonState {
  decline_request() async {
    Map<String, dynamic> res = await put_request(
        url: "http://localhost/request/api/cancel/" +
            widget.request.id.toString() +
            "/",
        body: {},
        headers: {"Authorization": "Token " + widget.user.token});
    if (res["response"] == "Error") widget.set_accepted(false);

    widget.set_accepted(true);
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
    return "Cancel request";
  }

  @override
  on_press() {
    decline_request();
  }
}
