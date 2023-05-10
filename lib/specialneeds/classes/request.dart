import 'dart:convert';

import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/deserializers/request.dart';
import 'package:together/request/requests.dart';

class Request {

  latLng.LatLng latlong;
  String? special_request;
  String help_type,gender;
  Request(
      {required this.gender,
      required this.latlong,
      this.special_request,
      required this.help_type});

Future<RequestDeserializer?> send_request(String token) async {

  var response = await post_request(url: "http://143.42.55.127/request/api/create/", body: {
    "location": "${latlong.latitude},${latlong.longitude}",
    "help_type": help_type,
    "gender": gender
  },
  headers: {"Authorization":"Token ${token}"});
  if (response["response"]=="Error") return null;
  print(response);
  return RequestDeserializer( json.encode(response)); 

}
}


