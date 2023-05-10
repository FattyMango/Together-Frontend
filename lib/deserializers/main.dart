import 'dart:convert';

import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';

void main() {
  // UserDeserializer user = UserDeserializer({
  //   'email': 'mhabdallah19@cit.just.edu.jo',
  //   'justID': 140296,
  //   'full_name': 'admin',
  //   'gender': 'M',
  //   'is_active': true,
  //   'is_admin': true,
  //   'is_online': false,
  //   'is_just_admin': false,
  //   'is_volunteer': true,
  //   'is_specialNeeds': false,
  //   "token": "dude"
  // });
  // print(user.token);

  var newdata = {
    "data": {
      "id": 3,
      "specialNeed": {
        "email": "mhabdallah195@cit.just.edu.jo",
        "justID": 6,
        "token": "30c3d8dec9559893b2b607e2fe4dc9f44a061570",
        "full_name": "salem",
        "gender": "M",
        "is_active": true,
        "is_admin": false,
        "is_online": true,
        "is_just_admin": false,
        "is_volunteer": false,
        "is_specialNeeds": true
      },
      "location": "32.494685,35.986186",
      "help_type": "E",
      "gender": "M",
      "request_websocket": "ws://143.42.55.127/ws/request/3/",
      "chatroom_websocket": "ws://143.42.55.127/ws/chatroom/3/"
    }
  };

  var request = RequestDeserializer(newdata["data"]);
  print(request.specialNeed.full_name);
}
