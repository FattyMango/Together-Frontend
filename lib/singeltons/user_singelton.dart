import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/mixins/prefs_mixin.dart';

import '../deserializers/user.dart';
import '../request/requests.dart';

class UserDeserializerSingleton {
  static UserDeserializer? _instance;
  static bool _is_instance = false;
  UserDeserializerSingleton._internal();

  static Future<UserDeserializer> getInstance() async {
    if (_instance == null) _instance = await init_user();

    return _instance!;
  }

  static UserDeserializer get instance {
    return _instance!;
  }

  static bool get is_instance {
    return _is_instance;
  }

  static void setInstance(UserDeserializer instance) {
    _is_instance=true;
    _instance = instance;
  }
  static Future<void> removeInstance() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    _is_instance=false;
    _instance = dummy;
  }
   static UserDeserializer get dummy{
    return UserDeserializer(json.encode({
        "email": "nodata",
        "justID": 0,
        "token": "nodata",
        "full_name": "nodata",
        "gender": "nodata",
        "is_active": false,
        "is_validated": false,
        "is_admin": false,
        "is_online": false,
        "is_just_admin": false,
        "is_volunteer": false,
        "is_specialNeeds": false,
        "phone_number": "nodata",
        "response": "nodata"
      }));
  }
  static Future<UserDeserializer?> init_user() async {
    
    UserDeserializer user;
    var prefs = await SharedPreferences.getInstance();

    final String userJson = await prefs.getString('user') ?? '';
    print("userJson${userJson}");
    if (userJson == ''){
      _is_instance = false;
      return dummy;}
    else {
      user = new UserDeserializer(userJson);

      var data = await get_request(
          url: 'http://143.42.55.127/user/api/',
          headers: {"Authorization": "Token " + user.token});

      if (data["response"] == "Error" ||data["detail"]=="User inactive or deleted.")
        return user;
      else {
        await prefs.setString('user', json.encode(data));

        user = new UserDeserializer(json.encode(data));
      }
      _is_instance = true;
      return user;
    }
  }
}
