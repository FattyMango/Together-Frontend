import 'dart:collection';
import 'dart:convert';

class UserDeserializer {
  late Map<String, dynamic> _data;
  late String _email, _full_name, _gender, _token,_phone_number;
  late int _justID,_id;
  late bool _is_active,
      _is_admin,
      _is_online,
      _is_just_admin,
      _is_specialNeeds,
      _is_validated,
      _is_volunteer;
  UserDeserializer(userJson) {
    if (userJson.runtimeType == String){
      _data = new Map<String, dynamic>.from(json.decode(userJson));
      }
    else
      try {
        _data = userJson;
      } catch (e) {
        throw FormatException("userJson must be either a String or a Map.");
      }

    deserialize();
  }

  void deserialize() {
    _phone_number = _data['phone_number'];
    _email = _data['email'];
    _full_name = _data['full_name'];
    _gender = _data['gender'];
    _token = _data['token'];
    _justID = _data['justID'];
    _id = _data['id'];
    _is_active = _data['is_active'];
    _is_admin = _data['is_admin'];
    _is_online = _data['is_online'];
    _is_just_admin = _data['is_just_admin'];
    _is_specialNeeds = _data['is_specialNeeds'];
    _is_volunteer = _data['is_volunteer'];
    _is_validated = _data['is_validated'];
  }

  int get justID {
    return _justID;
  }
 int get id {
    return _id;
  }
  String get full_name {
    return _full_name;
  }
  String get phone_number {
    return _phone_number;
  }
  String get email {
    return _email;
  }

  String get gender {
    return _gender;
  }

  String get token {
    return _token;
  }

  bool get is_volunteer {
    return _is_volunteer;
  }

  bool get is_specialNeeds {
    return _is_specialNeeds;
  }

  bool get is_online {
    return _is_online;
  }

  bool get is_validated {
    return _is_validated;
  }
}
