import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/mixins/periodic_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/specialneeds/classes/request.dart';
import 'package:together/specialneeds/pages/specialneeds_request_accepted_page.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../pages/theme_container.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../request/requests.dart';

class WaitingForVolunteerPage extends StatefulWidget {
  final RequestDeserializer request;
  final UserDeserializer user;
  const WaitingForVolunteerPage(
      {super.key, required this.request, required this.user});

  @override
  State<WaitingForVolunteerPage> createState() =>
      _WaitingForVolunteerPageState();
}

class _WaitingForVolunteerPageState extends State<WaitingForVolunteerPage>
    with WidgetsBindingObserver, WebSocketMixin, PeriodicMixin {
  bool is_dialog_opened = false;
  @override
  void initState() {
    // TODO: implement initState
    init_conn();
    super.initState();
  }
  // @override
  // void dispose() {
  //   disposeTimer();
  //   close_conn();
  //   super.dispose();
  // }

  @override
  int get delaySeconds => 10;
  @override
  periodic_function() async {
    if (!waitingForResponse) {
      Request r = convert_to_Request(widget.request);
      await r.finish_request(widget.user.token, widget.request.id);
      CouldntFindVolunteerDialog;
      waitingForResponse = true;
      disposeTimer();
    }
  }

  @override
  String get get_ws_url {
    return widget.request.request_websocket;
  }

  @override
  Map<String, dynamic> get ws_headers {
    return {"Authorization": "Token " + widget.user.token};
  }

  dynamic get CouldntFindVolunteerDialog => showDialog(
        builder: (BuildContext context) => AlertDialog(
          title: Text('error'),
          content:
              Text("We couldn't find a volunteer for you, please try again."),
          actions: [
            TextButton(
              onPressed: () async {
                is_dialog_opened = false;
                waitingForResponse = false;
                Navigator.pushReplacementNamed(context, '/specialneeds/home');
              },
              child: Text('OK'),
            ),
          ],
        ),
        context: context,
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: channel.stream,
        builder: (context, wsData) {
          if (wsData.hasData) {
            handle_ws_message(wsData.requireData);
          }
          return ThemeContainer(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      "Hold on, we are looking for your hero!",
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                  SpinKitFadingCircle(
                    color: Colors.black,
                    size: 50.0,
                  )
                ],
              ),
            ],
          );
        });
  }

  Future<void> handle_ws_message(data) async {
    var response = json.decode(data)["data"];
    if (response["response"] == "Error") {
      waitingForResponse = false;
     
      Request r = convert_to_Request(widget.request);
      await r.finish_request(widget.user.token, widget.request.id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!is_dialog_opened) {
          
          CouldntFindVolunteerDialog;
          is_dialog_opened = true;
           disposeTimer();
      
        }
      });
      return;
    } else if (response["response"] == "accept") {
      UserDeserializer volunteer = UserDeserializer(response["volunteer"]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
              settings:
                  const RouteSettings(name: '/specialneed/request/accepted'),
              builder: (context) => RequestAcceptedPage(
                    request: widget.request,
                    user: widget.user,
                    volunteer: volunteer,
                  )),
        );
      });
    }
  }
}
