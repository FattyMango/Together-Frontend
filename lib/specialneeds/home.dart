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
import 'package:together/specialneeds/pages/specialneeds_request_accepted_page.dart';
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
  late ValueNotifier<latLng.LatLng> pos;
  late Request request;
  late RequestDeserializer CurrentRequest;
  late UserDeserializer volunteer;
  late latLng.LatLng volunteer_location;

  @override
  void initState() {
    pos = ValueNotifier<latLng.LatLng>(new latLng.LatLng(31.988926, 35.946191));
    super.initState();
  }

  @override
  cantFetchLocation() {
    LocationErrorDialog();
  }

  LocationErrorDialog() => showDialog(
        builder: (BuildContext context) => AlertDialog(
          title: Text('error'),
          content: Text("Please enable the location service."),
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
  @override
  Map<String, dynamic> get ws_headers {
    return {"Authorization": "Token " + user.token};
  }

  @override
  String get get_ws_url =>
      "ws://143.42.55.127/ws/user/${user.justID.toString()}/";

  @override
  void dispose() {
    pos.dispose();
    close_conn();
    super.dispose();
  }

  Future<UserDeserializer> get_user() async {
    UserDeserializer user = await init_user();
    is_online ? await init_conn() : close_conn();
    return user;
  }

  setCanFetchLocation(value) {
    setState(() {
      canFetchLocation = value;
    });
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
                    handle_ws_message(wsData.requireData);
                  }
                  return SendRequestPage(
                    user: user,
                    submit_request: submit,
                    pos: snapshot.data![1],
                  );
                });
          }
          return ThemeContainer(isDrawer: true, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    "Please wait until we get you ready.",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Please make sure location service is enabled",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 5,
                ),
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

  submit(Request request) async {
    RequestDeserializer? r = await request.send_request(user.token);
    if (r == null) return CantCreateRequestDialog;

    // close_conn();
    Navigator.of(context).pushReplacement(
      new MaterialPageRoute(
          settings: const RouteSettings(name: '/specialneed/request/waiting'),
          builder: (context) => WaitingForVolunteerPage(
                request: r,
                user: user,
              )),
    );
    setState(() {
      this.request = request;
      CurrentRequest = r;
    });
    // init_conn();
  }

  handle_ws_message(data) async {
    print(data);
    var response = json.decode(data)["data"];
    if (response["response"] == "Error") {
      close_conn();

      await request.finish_request(user.token, CurrentRequest.id);

      return;
    } else if (response["response"] == "finish") {
    } else if (response["response"] == "accept") {
      this.volunteer = UserDeserializer(response["volunteer"]);

      try {
        this.volunteer_location = latLng.LatLng(
            double.parse(response["location"]["latitude"]),
            double.parse(response["location"]["longitude"]));
      } catch (e) {
        this.volunteer_location = latLng.LatLng(0, 0);
      }
    }
  }
}
