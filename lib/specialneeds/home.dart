import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:together/abstracts/abstract_state.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/pages/error_page.dart';
import 'package:together/mixins/location_mixin.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/specialneeds/buttons/send_request.dart';
import 'package:together/specialneeds/classes/request.dart';
import 'package:together/specialneeds/pages/send_request_page.dart';
import 'package:together/pages/theme_container.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/specialneeds/pages/waiting_accept_request.dart';
import '../deserializers/user.dart';
import 'buttons/drop_down_button.dart';

class SpecialNeedsHomePage extends AbstractHomePage {
  SpecialNeedsHomePage({super.key});
  @override
  AbstractHomePageState createState() {
    return SpecialNeedsHomePageState();
  }
}

class SpecialNeedsHomePageState extends AbstractHomePageState
    with WebSocketMixin, UserFtecherMixin, LocationFetcherMixin {
  bool gender_constraint = false,
      is_request_sent = false,
      is_request_accepted = false;
  late ValueNotifier<latLng.LatLng> pos;
  late String? special_request;
  late String help_type;
  late Request request;
  String? request_websocket_url;
  @override
  void initState() {
    pos = ValueNotifier<latLng.LatLng>(new latLng.LatLng(31.988926, 35.946191));
    super.initState();
  }

  @override
  String get get_ws_url =>
      !is_request_sent ? super.get_ws_url : request_websocket_url!;

  @override
  void dispose() {
    pos.dispose();
    super.dispose();
  }

  Future<UserDeserializer> get_user() async {
    UserDeserializer user = await init_user();
    is_online ? await init_conn() : close_conn();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([get_user(), determinePosition()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            UserDeserializer user = snapshot.data![0];
            if (!user.is_specialNeeds)
              return show_error_page(
                  context, prefs, "You are not a special needs student.");

            return StreamBuilder(
                stream: channel.stream,
                builder: (context, wsData) {
                  if (wsData.hasData) {
                    handle_ws_message(wsData.data);
                  }
                  if (!is_request_sent) {
                    return snapshot.data![1] != null
                        ? SendRequestPage(
                            user: user,
                            submit_request: submit,
                            pos: snapshot.data![1],
                          )
                        : Container();
                  } else {
                    return WaitingForVolunteerPage();
                  }
                });
          }
          return ThemeContainer(children: [
           Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(height: MediaQuery.of(context).size.height/3,),
            SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Text("Please wait until we get you ready.\nPlease make sure location service is enabled",style: TextStyle(fontSize: 20),),
            ),
            SizedBox(height: 10,),
            SpinKitFadingCircle(
              color: Colors.black,
              size: 75.0,
            )
          ],
        ),

          ]);
        });
  }

  Future get CantCreateRequestDialog => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('error'),
          content: Text("An error has occurd please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );

  dynamic get CouldntFindVolunteerDialog => showDialog(
        builder: (BuildContext context) => AlertDialog(
          title: Text('error'),
          content:
              Text("We couldn't find a volunteer for you, please try again."),
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

  submit(Request request, is_request_sent) async {
    print("called");

    RequestDeserializer? r = await request.send_request(user.token);
    if (r == null) return CantCreateRequestDialog;

    close_conn();
    setState(() {
      this.request = request;
      this.is_request_sent = true;
      request_websocket_url = r.request_websocket;
    });
    print(r.latlong);
  }

  handle_ws_message(data) {
    print(data);
    var response = json.decode(data)["data"];
    if (response["response"] == "Error") {
      print("here");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        close_conn();

        is_request_sent = false;
        is_request_accepted = false;
        CouldntFindVolunteerDialog;
      });
    }
  }

  void finish_request() {}
}
