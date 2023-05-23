import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';


import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class UserWebSocketSingleton {
  static UserWebSocketSingleton? _instance;
  static WebSocketChannel? _webSocketChannel;

  UserWebSocketSingleton._();

  static UserWebSocketSingleton getInstance(String get_ws_url, Map<String,dynamic> ws_headers) {
    _instance ??= UserWebSocketSingleton._();
    _instance!._initWebSocket( get_ws_url, ws_headers);
    return _instance!;
  }

  void _initWebSocket(String get_ws_url, Map<String,dynamic> ws_headers) {
    _webSocketChannel = IOWebSocketChannel.connect(Uri.parse(get_ws_url), headers: ws_headers);
  }
  
  WebSocketChannel get channel {
    return _webSocketChannel!;
  }

}

