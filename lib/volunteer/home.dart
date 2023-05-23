import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/pages/error_page.dart';
import 'package:together/request/requests.dart';
import 'package:together/volunteer/pages/home_page.dart';
import 'package:together/volunteer/pages/incoming_request.dart';
import 'package:together/volunteer/buttons/set_online/setonline_button.dart';
import 'package:together/pages/theme_container.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../deserializers/user.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../abstracts/abstract_state.dart';
import '../mixins/location_mixin.dart';
import '../mixins/periodic_mixin.dart';
import '../mixins/websocket_mixin.dart';
import '../singeltons/user_websocket_singelton.dart';

class VolunteerHomePage extends AbstractHomePage {
  bool is_online = false;
  VolunteerHomePage({super.key});

  @override
  AbstractHomePageState createState() {
    return _VolunteerHomePageState();
  }
}

class _VolunteerHomePageState extends AbstractHomePageState
    with PeriodicMixin, LocationFetcherMixin, UserFtecherMixin,WebSocketMixin {
  bool request_recieved = false;
  String latest_data = "";
   
  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    get_user();
  }

  // @override
  // void dispose() {
  //   disposeTimer();
    
  //   close_conn();
  //   print("disposed");
  //   super.dispose();
  // }

  @override
  Map<String, dynamic> get ws_headers =>
      {"Authorization": "Token " + user.token};

  @override
  String get get_ws_url =>
      "ws://143.42.55.127/ws/user/${user.justID.toString()}/";

  Future<UserDeserializer> get_user() async {
    user = await init_user();
       init_conn();
    return user;
  }

  update_online() async {
    Map<String, dynamic> res = await put_request(
        url: "http://143.42.55.127/user/api/volunteer/setonline/",
        body: {"is_online": is_online.toString()},
        headers: {"Authorization": "Token " + user.token});

    if (res["response"] != "Error")
      setState(() {
        is_online = false;
      });
    else
      set_online(res);
  }

  @override
  periodic_function() async {
    if (!waitingForResponse) {
      if (count == 5) {
        await update_online();
        count = 0;
      }
      waitingForResponse = true;
      await update_location();
      waitingForResponse = false;
      count++;
    }
  }

  update_location() async {
    if (is_online) {
      Position pos = await determinePosition();
      var res = await get_request(
          url:
              "http://143.42.55.127/location/update/volunteer/${pos.latitude}/${pos.longitude}/",
          headers: {"Authorization": "Token " + this.user.token});
    }
  }

  @override
  cantFetchLocation() {
    setState(() {
      is_online = false;
    });
    update_online();
    LocationErrorDialog();
  }

  set_online(res) async {
    await prefs.setString('user', json.encode(res));
    if (is_online != res["is_online"])
      setState(() {
        is_online = res["is_online"];
      });
    if (is_online) {
      update_location();
    }
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
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([get_user()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            UserDeserializer user = snapshot.data![0];
            if (!user.is_volunteer)
              return show_error_page(
                  context, prefs, "You are not a volunteer.");
                  if(channel != null)
             return StreamBuilder(
                stream: channel!.stream,
                builder: (context, wsData) {
                  if (wsData.hasData) navigate_request(wsData.data);

                  return VolunteerHomeContainer(
                    user: user,
                    set_online: set_online,
                    is_validated: is_validated,
                    is_online: is_online,
                  );
                });
          }

          return ThemeContainer(
            children: [
              Center(
                child: Container(
                  child: Text("An error has occured.",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          decoration: TextDecoration.none)),
                ),
              ),
              Center(
                child: GestureDetector(
                    onTap: () {
                      prefs.remove('user');
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: Container(
                      child: Text(
                        "Please Login again.",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            decoration: TextDecoration.none),
                      ),
                    )),
              )
            ],
          );
        });
  }

  navigate_request(data) {
    if (latest_data == data) {print("same data!");return;}
    latest_data = data;
    print(data);
    try {
      RequestDeserializer request =
          new RequestDeserializer(json.decode(data)["data"]);

      if (!request_recieved) {
        request_recieved = true;
        disposeTimer();
    
    close_conn();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                settings: const RouteSettings(
                    name: '/volunteer/request/incoming_request'),
                builder: (context) => IncomingRequestPage(
                      request: request,
                      user: user,
                    )),
          );

          return;
        });
      }
    } catch (e) {}
  }
}
