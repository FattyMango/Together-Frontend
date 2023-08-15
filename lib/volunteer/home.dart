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
import '../misc/backend.dart';
import '../mixins/location_mixin.dart';
import '../mixins/periodic_mixin.dart';
import '../mixins/prefs_mixin.dart';
import '../mixins/websocket_mixin.dart';
import '../singeltons/user_singelton.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class VolunteerHomePage extends StatefulWidget {
  VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() {
    return _VolunteerHomePageState();
  }
}

class _VolunteerHomePageState extends State<VolunteerHomePage>
    with
        WidgetsBindingObserver,
        PeriodicMixin,
        LocationFetcherMixin,
        WebSocketMixin,
        PrefsMixin {
  bool request_recieved = false;
  String latest_data = "";
  late bool is_validated, is_online;
  late UserDeserializer user;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    is_online = false;
    Noti.initialize(flutterLocalNotificationsPlugin);
    handle_user_changes(UserDeserializerSingleton.instance);
    set_prefs();
    super.initState();
    initTimer();
    init_conn();
  }

  handle_user_changes(UserDeserializer user) {
    is_validated = user.is_validated;

    is_online = is_validated ? user.is_online : false;
    this.user = user;
    UserDeserializerSingleton.setInstance(user);
  }

  @override
  void dispose() {
    disposeTimer();

    close_conn();
    print("disposed");
    super.dispose();
  }

  @override
  Map<String, dynamic> get ws_headers =>
      {"Authorization": "Token " + user.token};

  @override
  String get get_ws_url =>
       websocketUrl+"/ws/user/${user.justID.toString()}/";

  update_online() async {
    Map<String, dynamic> res = await put_request(
        url: apiUrl+"/user/api/volunteer/setonline/",
        body: {"is_online": is_online.toString()},
        headers: {"Authorization": "Token " + user.token});

    if (res["response"] == "Error")
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
              apiUrl+"/location/update/volunteer/${pos.latitude}/${pos.longitude}/",
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

    UserDeserializer u = new UserDeserializer(json.encode(res));

    UserDeserializerSingleton.setInstance(u);
    if (is_online != res["is_online"])
      setState(() {
        handle_user_changes(u);
      });
    if (is_online) {
      update_location();
    }
  }

  LocationErrorDialog() => showDialog(
        barrierDismissible: false,
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
    if (!user.is_volunteer)
      return show_error_page(context, prefs, "You are not a volunteer.");
    if (channel != null)
      return StreamBuilder(
          stream: channel!.stream,
          builder: (context, wsData) {
            if (wsData.hasData) if (latest_data != wsData.data) {
              latest_data = wsData.data.toString();
              navigate_request(wsData.data);
            }

            return VolunteerHomeContainer(
              user: user,
              set_online: set_online,
              is_validated: is_validated,
              is_online: is_online,
            );
          });

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
  }

  navigate_request(data) async {
    latest_data = data;
    print(data);
    try {
      RequestDeserializer request =
          new RequestDeserializer(json.decode(data)["data"]);

      if (!request_recieved) {
        request_recieved = true;
        // Noti.showBigTextNotification(
        //     title: "Hurry Up!",
        //     body: "${request.specialNeed.full_name} needs your help at ${request.square}${request.building}",
        //     fln: flutterLocalNotificationsPlugin);
            dispose();
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
        });
      }
    } catch (e) {}
  }
}

class Noti {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationsSettings = new InitializationSettings(
      android: androidInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showBigTextNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
      'you_can_name_it_whatever1',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var not = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await fln.show(0, title, body, not);
  }
}
