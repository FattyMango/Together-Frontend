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
import '../../deserializers/user.dart';
import '../../abstracts/abstract_state.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:async';
import 'package:geolocator/geolocator.dart';

mixin LocationPeriodicMixin on AbstractHomePageState {
  late Timer _timer;
  bool _waitingForResponse = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Adding an observer
    setTimer(false); // Setting a timer on init
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelling a timer on dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setTimer(state != AppLifecycleState.resumed);
  }

  void setTimer(bool isBackground) {
    int delaySeconds = isBackground ? 60 : 120;

    // Cancelling previous timer, if there was one, and creating a new one

    _timer = Timer.periodic(Duration(seconds: delaySeconds), (t) async {
      // Not sending a request, if waiting for response
      if (!_waitingForResponse) {
        _waitingForResponse = true;
        await update_location();
        _waitingForResponse = false;
      }
    });
  }

  update_location() async {
    if (is_online)
      await get_request(
          url:
              "http://143.42.55.127/location/update/volunteer/32.494685/35.986186/",
          headers: {"Authorization": "Token " + this.user.token});
  }
}
