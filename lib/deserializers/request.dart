import 'dart:convert';

import 'package:together/deserializers/user.dart';
import 'package:latlong2/latlong.dart' as latLng;
class RequestDeserializer {
  late Map<String, dynamic> _data;
  late int _id;
  late String _help_type,_request_websocket,_chatroom_websocket,_gender;
  late latLng.LatLng _latlong;
  late UserDeserializer _specialNeed;
  RequestDeserializer(requestJson) {

    if (requestJson.runtimeType == String)
      _data = new Map<String, dynamic>.from(json.decode(requestJson));
    else
    try {
      _data = requestJson;
    } catch (e) {
      throw FormatException("requestJson must be either a String or a Map.");
    }
    deserialize();
  }
// {'id': 32, 'specialNeed': {'email': 'mhabdallah195@cit.just.edu.jo', 'justID': 6, 'token': 'b8c8bb4a14acebf1e1af69442cfe757269d2aa45', 
//'full_name': 'salem', 'gender': 'M', 'is_active': True, 'is_admin': False, 'is_online': True, 'is_just_admin': False,
// 'is_volunteer': False, 'is_specialNeeds': True}, 'location': '32.494685,35.986186', 'help_type': 'M', 'gender': 'N'}

  
  void set_long_lat(String location){
    List<String> latlong = location.split(",");
    _latlong = new latLng.LatLng(double.parse(latlong[0]) , double.parse(latlong[1]) );
  }
  void deserialize() {
    set_long_lat(_data["location"]);
    _help_type = _data["help_type"];
    _id= _data["id"];
    _request_websocket= _data["request_websocket"];
    _chatroom_websocket= _data["chatroom_websocket"];
    _gender= _data["gender"];
    _specialNeed= new UserDeserializer(json.encode(_data["specialNeed"]));


  }
  latLng.LatLng get latlong{
    return _latlong;
  }
  String get help_type{
    return _help_type;}

  String get request_websocket{
    return _request_websocket;}

  String get chatroom_websocket{
    return  _chatroom_websocket;}
  String get gender{
    return  _gender;}
  
  int get id{
    return _id;
  }
  UserDeserializer get specialNeed{
    return _specialNeed;
  }

  }

  

