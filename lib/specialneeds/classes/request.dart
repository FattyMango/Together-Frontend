import 'dart:convert';

import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/deserializers/request.dart';
import 'package:together/request/requests.dart';

import '../../misc/backend.dart';

class Request {

  latLng.LatLng? latlong;

  String? help_type, gender,description,square,building;
  Request(
      { this.gender,
       this.latlong,
       this.description,
       this.help_type,
       this.square,
       this.building,});

  Future<RequestDeserializer?> send_request(String token) async {
    var response = await post_request(
        url: apiUrl+"/request/api/create/",
        body: {
          "location": "${latlong!.latitude},${latlong!.longitude}",
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
   
    return RequestDeserializer(json.encode(response));
  }

  Future<bool> finish_request(String token, int id) async {
    http: //{{host}}/request/api/finish/53/
    var response = await put_request(
        url: apiUrl+"/request/api/finish/${id.toString()}/",
        headers: {"Authorization": "Token ${token}"}, body: {});
    if (response["response"] == "Error") return false;
    
    return true;
  }
}

Request convert_to_Request(RequestDeserializer request){
return Request(gender: request.gender, latlong: request.latlong, description: request.description??"", help_type: request.help_type, square: request.square??"", building: request.building??"");


}