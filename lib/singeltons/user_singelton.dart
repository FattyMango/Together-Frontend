import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/mixins/prefs_mixin.dart';

import '../deserializers/user.dart';
import '../misc/backend.dart';
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
    _is_instance = true;
    _instance = instance;
  }

  static Future<void> removeInstance() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    _is_instance = false;
    _instance = UserDeserializer.dummy;
  }



  static Future<UserDeserializer> init_user() async {
    UserDeserializer user;
    var prefs = await SharedPreferences.getInstance();

    final String userJson = await prefs.getString('user') ?? '';
    print("userJson${userJson}");
    if (userJson == '') {
      _is_instance = false;
      return UserDeserializer.dummy;
    } else {
      try {
        user = new UserDeserializer(userJson);

        var data = await get_request(
            url:  apiUrl+'/user/api/',
            headers: {"Authorization": "Token " + user.token});

        if (data["response"] == "Error" ||
            data["detail"] == "User inactive or deleted.")
          return user;
        else {
          await prefs.setString('user', json.encode(data));

          user = new UserDeserializer(json.encode(data));
        }
        _is_instance = true;
        return user;
      } catch (e) {
        _is_instance = false;

        return UserDeserializer.dummy;
      }
    }
  }
}
