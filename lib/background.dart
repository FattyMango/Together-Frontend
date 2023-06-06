import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:together/request/requests.dart';
import 'package:together/singeltons/user_singelton.dart';
import 'package:together/volunteer/home.dart';

import 'package:web_socket_channel/io.dart';

import 'deserializers/user.dart';

Future<void> initializeService(UserDeserializer s) async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.defaultImportance,
  );

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: false,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Together',
      initialNotificationContent: 'Waitng for requests',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  UserDeserializer user = await UserDeserializerSingleton.getInstance();

  if (UserDeserializerSingleton.is_instance && user.is_volunteer) {
    final channel = IOWebSocketChannel.connect(
        Uri.parse(
            "ws://143.42.55.127/ws/user/${UserDeserializerSingleton.instance.justID}/"),
        headers: {
          "Authorization": "Token ${UserDeserializerSingleton.instance.token}"
        });
    channel.stream.listen((event) {
      print(event);

      flutterLocalNotificationsPlugin.show(
          888,
          'Hurry up!',
          json.decode(event)["data"]["specialNeed"]["full_name"].toString() +
              " needs your help",
          NotificationDetails(
            android: AndroidNotificationDetails(
              'you_can_name_it_whatever1',
              'channel_name',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: "incoming_request");
    });
  }
}
