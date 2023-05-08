import 'package:shared_preferences/shared_preferences.dart';

get_user(){

Future<String> get_user() async {
    final prefs = await SharedPreferences.getInstance();
    String res = prefs.getString('user') ?? '';
    print(res);
    return res;

  }
}