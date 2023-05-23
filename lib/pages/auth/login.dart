import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/mixins/prefs_mixin.dart';

import '../../request/requests.dart';

class LoginPage extends StatefulWidget {
  String? message;
  LoginPage({String? this.message});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with PrefsMixin {
  final _formKey = GlobalKey<FormState>();

  late int _justID;
  late String _password;
  
  bool _isLoading = false;
  void initState() {

   
    super.initState();
     check_user();
  }

  Future<void> check_user() async {
    
    await set_prefs();
    
    final String userJson = await prefs.getString('user') ?? '';
    if (userJson != '') {
      UserDeserializer user = new UserDeserializer(userJson);
      navigate_user(user);
    }
  }

  void navigate_user(UserDeserializer user) {
    if (user.is_volunteer)
      Navigator.pushReplacementNamed(context, '/volunteer/home');
    else if (user.is_specialNeeds)
      Navigator.pushReplacementNamed(context, '/specialneeds/home');
    else
      setState(() {
        widget.message =
            "You must be a valid volunteer or a special needs students to use this app.";
      });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      // Make the API request to authenticate the user

      var data =
          await post_request(url: 'http://143.42.55.127/user/api/login/', body: {
        'username': _justID.toString(),
        'password': _password,
      });
      // Send a request to register the user

      setState(() {
        _isLoading = false;
      });

      if (data['response'] != "Error") {
        final prefs = await SharedPreferences.getInstance();
        String response = json.encode(data);
        await prefs.setString('user', response);

// Login successful, navigate to the home page

        UserDeserializer user = new UserDeserializer(response);

        navigate_user(user);
      } else {
        // Registration failed, display an error message
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text(jsonEncode(data)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(
                  size: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(widget.message ?? 'no data'),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'JUST ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter JUST ID';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _justID = int.parse(value!);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Log in'),
                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pushReplacementNamed(context, "/register");
                          },
                          child: Container(
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  decoration: TextDecoration.none),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
