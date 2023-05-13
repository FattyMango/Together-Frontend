import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';

import 'package:together/deserializers/user.dart';
import 'package:together/volunteer/buttons/request/accept_request.dart';
import 'package:together/volunteer/buttons/request/decline_request.dart';
import 'package:together/pages/theme_container.dart';
import 'package:together/volunteer/pages/volunteer_request_page.dart';
import 'package:together/widgets/widgets/map.dart';

class IncomingRequestPage extends StatefulWidget {
  final RequestDeserializer request;
  final UserDeserializer user;

  IncomingRequestPage({super.key, required this.request, required this.user});

  @override
  State<IncomingRequestPage> createState() => _IncomingRequestPageState();
}

class _IncomingRequestPageState extends State<IncomingRequestPage> {
  bool _is_accepted = false;
  set_accepted(is_accepted) {
    if (is_accepted)
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
              settings: const RouteSettings(name: '/login'),
              builder: (context) => VolunteerRequestPage(
                    request: widget.request,
                    user: widget.user,
                  )),
        );
      });
    setState(() {
      _is_accepted = is_accepted;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return ThemeContainer(children: [
      SizedBox(
        height: 20,
      ),
      Container(
          padding: EdgeInsets.all(15),
          height: 350,
          width: 100,
          child: MapWidget(
            request: widget.request,
          )),
      SizedBox(height: 30),
      Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Container(
            child: Text(
              widget.request.specialNeed.full_name +
                  " needs your help. they are at ${widget.request.square}${widget.request.building??""}.",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
      ),
      SizedBox(height: 30),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !_is_accepted
                ? AcceptRequestButton(
                    user: widget.user,
                    request: widget.request,
                    set_accepted: (is_accepted) => set_accepted(is_accepted),
                    ErrorDialog: ErrorDialog)
                : Container(),
            SizedBox(
              width: 20,
            ),
            DeclineRequestButton(
              user: widget.user,
              request: widget.request,
              set_accepted: (is_accepted) => set_accepted(is_accepted),
              ErrorDialog: ErrorDialog,
            ),
          ],
        ),
      )
    ]);
  }
}
