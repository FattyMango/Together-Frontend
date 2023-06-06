import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/singeltons/user_singelton.dart';
import 'package:together/specialneeds/classes/request.dart';
import 'package:together/specialneeds/pages/waiting_accept_request.dart';
import 'package:together/volunteer/pages/volunteer_request_accepted_page.dart';

import '../abstracts/abstract_state.dart';
import '../background.dart';
import '../request/requests.dart';
import '../specialneeds/pages/specialneeds_request_accepted_page.dart';

class LoadingPage extends AbstractHomePage {
  const LoadingPage({super.key});

  @override
  AbstractHomePageState createState() => _LoadingPageState();
}

class _LoadingPageState extends AbstractHomePageState with UserFtecherMixin {
  String? data;

  @override
  void initState() {
    super.initState();
  }

  Future wait_five_seconds() async {
    return new Future.delayed(const Duration(seconds: 5), () => true);
  }

  Future<RequestDeserializer?> get_latest_request(bool isVolunteer) async {
    var data = await get_request(
        url:
            'http://143.42.55.127/request/api/${isVolunteer ? "volunteer" : "specialneeds"}/last/',
        headers: {"Authorization": "Token " + user.token});
    // print(data);
    if (data["response"] == "Error")
      return null;
    else {
      print(json.encode(data["data"]));
      return new RequestDeserializer(json.encode(data["data"]));
    }
  }

  navigate_specialneeds(RequestDeserializer request) {
    if (request.volunteer != null)
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
            settings:
                const RouteSettings(name: '/specialneed/request/accepted'),
            builder: (context) => RequestAcceptedPage(
                  request: request,
                  user: user,
                  volunteer: request.volunteer!,
                )),
      );
    else
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
            settings: const RouteSettings(name: '/specialneed/request/waiting'),
            builder: (context) => WaitingForVolunteerPage(
                  request: request,
                  user: user,
                )),
      );
    return true;
  }

  navigate_volunteer(RequestDeserializer request) {
    Navigator.of(context).pushReplacement(
      new MaterialPageRoute(
          settings: const RouteSettings(name: '/volunteerrequest/accepted'),
          builder: (context) => VolunteerRequestAcceptedPage(
                request: request,
                user: user,
              )),
    );
    return true;
  }

  Future<bool> check_last_request(UserDeserializer user) async {
    RequestDeserializer? request = await get_latest_request(user.is_volunteer);
    if (request != null && !request.is_finished) {
      if (user.is_specialNeeds)
        return navigate_specialneeds(request);
      else if (user.is_volunteer) return navigate_volunteer(request);
    }
    return false;
  }

  Future navigate_user() async {
    sleep(Duration(seconds: 3));
    await UserDeserializerSingleton.getInstance();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!UserDeserializerSingleton.is_instance) return handleNoUserData();
      user = UserDeserializerSingleton.instance;
      
      if (await check_last_request(user)) return;

      if (user.is_volunteer){

        initializeService(user);
        Navigator.pushReplacementNamed(context, "/volunteer/home");}
      else if (user.is_specialNeeds)
        Navigator.pushReplacementNamed(context, "/specialneeds/home");
      else
        Navigator.pushReplacementNamed(context, "/login");
    });
  }

  Widget get LoadingContainer => Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.blue.shade300,
          child: Center(child: Text("Loading Page")),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([navigate_user()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          return LoadingContainer;
        });
  }

  @override
  handleNoUserData() => Navigator.pushReplacementNamed(context, '/login');
}
