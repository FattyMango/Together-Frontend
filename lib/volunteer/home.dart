import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/pages/error_page.dart';
import 'package:together/request/requests.dart';
import 'package:together/volunteer/pages/home_container.dart';
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
import 'mixins/location_periodic_mixin.dart';
import '../mixins/websocket_mixin.dart';

class VolunteerHomePage extends AbstractHomePage {
  bool is_online = false;
  VolunteerHomePage({super.key}) {}

  @override
  AbstractHomePageState createState() {
    return _VolunteerHomePageState();
  }
}

class _VolunteerHomePageState extends AbstractHomePageState
    with
        LocationPeriodicMixin,
        LocationFetcherMixin,
        WebSocketMixin,
        UserFtecherMixin {
  @override
  void dispose() {
    super.dispose();
  }

  Future<UserDeserializer> get_user() async {
    UserDeserializer user = await init_user();

    user.is_online ? await init_conn() : null;
    return user;
  }

  set_online(res) async {
    await prefs.setString('user', json.encode(res));
    setState(() {
      is_online = res["is_online"];
      if (!is_online) {
        channel.sink.close();
      } else {
        init_conn();
        update_location();
      }
    });
  }

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
            if (!is_online)
              return VolunteerHomeContainer(
                user: user,
                set_online: set_online,
                is_validated: is_validated,
                is_online: false,
              );
            else
              return StreamBuilder(
                  stream: channel.stream,
                  builder: (context, wsData) {
                    if (wsData.hasData) {
                      return navigate_request(wsData.data);
                    }

                    return VolunteerHomeContainer(
                      user: user,
                      set_online: set_online,
                      is_validated: is_validated,
                      is_online: true,
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
    print("here");
    print(data);
    try{
    RequestDeserializer request =
        new RequestDeserializer(json.decode(data)["data"]);
    // channel.sink.close();
    return IncomingRequestPage(
      request: request,
      user: user,
    );}
    catch(e){}
  }
}
