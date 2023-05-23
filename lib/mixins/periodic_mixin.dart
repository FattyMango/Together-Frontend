import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/request/requests.dart';
import 'package:together/volunteer/pages/home_page.dart';
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

mixin PeriodicMixin on WidgetsBindingObserver {
  late Timer _timer;
  bool waitingForResponse = false;
  int count = 0;
@override
void initState() {
  initTimer();
  
}
//   @override
// void dispose(){
//   disposeTimer();
// }
  void initTimer() {
    WidgetsBinding.instance.addObserver(this); // Adding an observer
    setTimer(true);
    // Setting a timer on init
  }

  void disposeTimer() {
    _timer.cancel(); // Cancelling a timer on dispose
    WidgetsBinding.instance.removeObserver(this);
    
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setTimer(state != AppLifecycleState.resumed);
  }

  int get delaySeconds => 5;
  void setTimer(bool isBackground) {
    int delaySeconds = this.delaySeconds;

    // Cancelling previous timer, if there was one, and creating a new one

    _timer = Timer.periodic(Duration(seconds: delaySeconds), (t) async {
      // Not sending a request, if waiting for response
      await periodic_function();
    });
  }

  periodic_function() async {
    return UnimplementedError();
  }
}
