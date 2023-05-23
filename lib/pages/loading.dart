import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/mixins/user_fetch_mixin.dart';

import '../abstracts/abstract_state.dart';



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

  navigate_user() {
    sleep(Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("called");
      if (user.is_volunteer)
      
        Navigator.pushReplacementNamed(context, "/volunteer/home");
      else if (user.is_specialNeeds)
        Navigator.pushReplacementNamed(context, "/specialneeds/home");
    });
  }
  Widget get LoadingContainer=>
  Scaffold(body:Container(
    height: double.infinity,
    width: double.infinity,
    color: Colors.blue.shade300,
    child: Center(child: Text("Loading Page")),
  ) ,);
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([ init_user()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) navigate_user();
          return LoadingContainer;
        });
  }
  
  @override
  handleNoUserData()=>Navigator.pushReplacementNamed(context, '/login');
}
