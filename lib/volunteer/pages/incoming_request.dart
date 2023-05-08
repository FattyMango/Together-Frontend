import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';

import 'package:together/deserializers/user.dart';
import 'package:together/volunteer/buttons/request/accept_request.dart';
import 'package:together/volunteer/buttons/request/decline_request.dart';
import 'package:together/pages/theme_container.dart';
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
    setState(() {
      _is_accepted = is_accepted;
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
            child: Text(widget.request.specialNeed.full_name +
                " needs your help. they are at A2."
                ,style: TextStyle(fontSize: 15,color: Colors.black,decoration: TextDecoration.none),),
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
                  )
                : Container(),
            SizedBox(
              width: 20,
            ),
            DeclineRequestButton(
              user: widget.user,
              request: widget.request,
              set_accepted: (is_accepted) => set_accepted(is_accepted),
            ),
          ],
        ),
      )
    ]);
  }
}
