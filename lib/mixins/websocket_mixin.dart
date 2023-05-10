import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/request/requests.dart';
import 'package:together/volunteer/pages/home_container.dart';
import 'package:together/volunteer/pages/incoming_request.dart';
import 'package:together/volunteer/buttons/set_online/setonline_button.dart';
import 'package:together/pages/theme_container.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../deserializers/user.dart';
import '../abstracts/abstract_state.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:async';
import 'package:geolocator/geolocator.dart';

mixin WebSocketMixin on AbstractHomePageState {
  late WebSocketChannel channel;
  @override
  void dispose() {
    close_conn();
    super.dispose();
  }
  String get get_ws_url{

    return "ws://143.42.55.127/ws/user/"+user.justID.toString()+"/";
  }
  switch_conn(String url,Map<String,dynamic>headers){
    close_conn();
    channel = IOWebSocketChannel.connect(Uri.parse(url),
        headers: headers);
  }
  close_conn(){
    channel!=null?channel.sink.close():null;
  }
  init_conn() async {

    channel = IOWebSocketChannel.connect(Uri.parse(get_ws_url),
        headers: {"Authorization": "Token " + user.token});

  }
}
