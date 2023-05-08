import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/pages/auth/login.dart';
import 'package:together/request/requests.dart';

import '../../deserializers/user.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late String _justID;
  late String _password;
  late String _password2;

  bool _isSubmitting = false;
  String? errorMessage;
  void initState() {
    check_user();
  }

  Future<void> check_user() async {
    super.initState();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
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
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(
          settings: const RouteSettings(name: '/login'),
          builder: (context) => LoginPage(
            message:
                "You must be a valid volunteer or a special needs students to use this app.",
          ),
        ),
      );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_password != _password2) {
        setState(() {
          errorMessage = 'Passwords do not match';
        });
        return;
      }

      setState(() {
        _isSubmitting = true;
        errorMessage = '';
      });
      var data = await post_request(
        url: 'http://localhost/user/api/register/',
        body: {
          'justID': _justID,
          'password': _password,
          'password2': _password2,
        }
        );
      // Send a request to register the user


      setState(() {
        _isSubmitting = false;
      });


      if (data['response'] != "Error") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(data));

        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
            settings: const RouteSettings(name: '/login'),
            builder: (context) => LoginPage(
              message:
                  "Registered successfully, please login or activate your account.",
            ),
          ),
        );
      } else {
        // Registration failed, display an error message
        setState(() {
          errorMessage = data['response'];
          Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
            settings: const RouteSettings(name: '/login'),
            builder: (context) => LoginPage(
              message:
                  "This account exists, please login or activate your account.",
            ),
          ),
        );
        });
      }
    }
  }

  @override
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
                Text(
                  'Create an account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
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
                        onChanged: (value) {
                          _justID = value;
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
                        onChanged: (value) {
                          _password = value;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                         
                          if (value!.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password2 = value!;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? CircularProgressIndicator()
                            : Text('Register'),
                      ),
                      if (errorMessage != null)
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ))),
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
