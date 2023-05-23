import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/volunteer/pages/volunteer_request_accepted_page.dart';

import '../../../deserializers/user.dart';
import '../../../request/requests.dart';
import 'request_button.dart';

class AcceptRequestButton extends AbstractRequestButton {
    
   AcceptRequestButton({super.key, required super.user, required super.request,required super.set_accepted,required super.ErrorDialog}):super();

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
    if (res["response"] == "Error") {
      // widget.set_accepted(false);
    // widget.ErrorDialog(res["message"]);
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/volunteer/home');
    });
    }
    else{
    widget.set_accepted(true);
         Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
              settings: const RouteSettings(name: '/request_accepted'),
              builder: (context) => VolunteerRequestAcceptedPage(
                    request: widget.request,
                    user: widget.user,
                  )),
        );
      });
        }


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
    return "Accept";
  }
  
  @override
  on_press() {
  accept_request();
  }
}
