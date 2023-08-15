import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';

import 'package:together/deserializers/user.dart';
import 'package:together/volunteer/buttons/request/accept_request.dart';
import 'package:together/volunteer/buttons/request/decline_request.dart';
import 'package:together/pages/theme_container.dart';
import 'package:together/volunteer/pages/volunteer_request_accepted_page.dart';
import 'package:together/widgets/widgets/map.dart';

import '../../misc/backend.dart';
import '../../request/requests.dart';

class IncomingRequestPage extends StatefulWidget {
  final RequestDeserializer request;
  final UserDeserializer user;

  IncomingRequestPage({super.key, required this.request, required this.user});

  @override
  State<IncomingRequestPage> createState() => _IncomingRequestPageState();
}

class _IncomingRequestPageState extends State<IncomingRequestPage> {
  bool _is_accepted = false;

  ErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        builder: (BuildContext context) => AlertDialog(
          title: Text('error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
        context: context,
      );
    });
  }

  Widget get MapDisplay => Container(
      padding: EdgeInsets.all(0),
      height: MediaQuery.of(context).size.height / 2,
      child: MapWidget(
        request: widget.request,
      ));

  Widget get HeaderMessage => Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Container(
            child: Text(
              widget.request.specialNeed.full_name +
                  " needs your help! they are at ${widget.request.square}${widget.request.building ?? ""}.",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );

  Widget get DescriptionMessage => Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Container(
            child: Text(
              widget.request.description == "no data"?"":widget.request.description!,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return ThemeContainer(children: [
      SizedBox(height: 5),
      MapDisplay,
      SizedBox(height: 30),
      HeaderMessage,
      widget.request.description != null ? DescriptionMessage : Container(),
      SizedBox(height: 30),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                accept_request();
              },
              child: Text(
                "Accept",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(135, 55),
                  backgroundColor: Colors.blue.shade700),
            ),
            //  AcceptRequestButton(
            //     user: widget.user,
            //     request: widget.request,
            //     set_accepted: (is_accepted) => ,
            //     ErrorDialog: ErrorDialog)
            // ,
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                decline_request();
              },
              child: Text(
                "Decline",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(135, 55),
                  backgroundColor: Colors.red.shade600),
            )
          ],
        ),
      )
    ]);
  }

  decline_request() async {
    print("here");
    Map<String, dynamic> res = await get_request(
        url:
            apiUrl+"/request/api/decline/${widget.request.id.toString()}/",
        headers: {"Authorization": "Token " + widget.user.token});

    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/volunteer/home');
    });
  }

  accept_request() async {
    Map<String, dynamic> res = await put_request(
        url: apiUrl+"/request/api/accept/" +
            widget.request.id.toString() +
            "/",
        body: {},
        headers: {"Authorization": "Token " + widget.user.token});
    print(res);
    if (res["response"] == "Error")
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/volunteer/home');
      });
    else
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
