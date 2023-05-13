import 'dart:convert';

import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/deserializers/request.dart';
import 'package:together/request/requests.dart';

class Request {

  latLng.LatLng latlong;

  String help_type, gender,description,square,building;
  Request(
      {required this.gender,
      required this.latlong,
      required this.description,
      required this.help_type,
      required this.square,
      required this.building,});

  Future<RequestDeserializer?> send_request(String token) async {
    var response = await post_request(
        url: "http://143.42.55.127/request/api/create/",
        body: {
          "location": "${latlong.latitude},${latlong.longitude}",
          "help_type": help_type,
          "gender": gender,
          "square":square,
          "building":building,
          "description":description
        },
        headers: {
          "Authorization": "Token ${token}"
        });
    if (response["response"] == "Error") return null;
    print(response);
    return RequestDeserializer(json.encode(response));
  }

  Future<bool> finish_request(String token, int id) async {
    http: //{{host}}/request/api/finish/53/
    var response = await put_request(
        url: "http://143.42.55.127/request/api/finish/${id.toString()}/",
        headers: {"Authorization": "Token ${token}"}, body: {});
    if (response["response"] == "Error") return false;
    print(response);
    return true;
  }
}
