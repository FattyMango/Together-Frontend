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
import '../../deserializers/user.dart';
import '../../abstracts/abstract_state.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../misc/backend.dart';

mixin UserFtecherMixin on AbstractHomePageState {
  Future<UserDeserializer> init_user() async {
    await set_prefs();
    // prefs.remove('user');
    final String userJson = await prefs.getString('user') ?? '';

    if (userJson == '') Navigator.pushReplacementNamed(context, '/login');

    user = new UserDeserializer(userJson);

    var data = await get_request(
        url:  apiUrl+'/user/api/',
        headers: {"Authorization": "Token " + user.token});

    if (data["response"] == "Error")
      is_validated = false;
    else {
      await prefs.setString('user', json.encode(data));

      user = new UserDeserializer(json.encode(data));
      is_validated = user.is_validated;
    }
    is_online = user.is_online;

    return user;
  }
}
