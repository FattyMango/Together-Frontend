import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> put_request({required String url,required Map<String, dynamic> body,Map<String, String>? headers}) async {

      final response = await http.put(
        Uri.parse(url),
        body:body??{},
        headers: headers??{}
      );

      return new Map<String, dynamic>.from(json.decode(response.body));
}
Future<Map<String, dynamic>> post_request({required String url,required Map<String, dynamic> body,Map<String, String>? headers}) async {

      final response = await http.post(
        Uri.parse(url),
        body:body??{},
        headers: headers??{}
      );

      return new Map<String, dynamic>.from(json.decode(response.body));
}
Future<Map<String, dynamic>> get_request({required String url,Map<String, String>? headers}) async {

      final response = await http.get(
        Uri.parse(url),
        headers: headers??{}
      );

      return new Map<String, dynamic>.from(json.decode(response.body));
}