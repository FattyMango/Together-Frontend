// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:together/pages/auth/login.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/pages/loading.dart';
import 'package:together/specialneeds/home.dart';
import 'package:together/volunteer/pages/alt.dart';
import 'package:together/volunteer/home.dart';
import 'package:together/volunteer/pages/incoming_request.dart';
import 'package:together/volunteer/pages/volunteer_request_accepted_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import 'pages/auth/register.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      routes: {
        '/volunteer/home': (context) => VolunteerHomePage(),

        '/specialneeds/home': (context) => SpecialNeedsHomePage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(
              message: "error eccourd",
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  MyHomePageState createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoadingPage();
  }
}
