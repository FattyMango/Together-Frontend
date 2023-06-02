import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/mixins/prefs_mixin.dart';
import 'package:together/pages/auth/login.dart';
import 'package:together/request/requests.dart';

import '../../deserializers/user.dart';
import '../../singeltons/user_singelton.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with PrefsMixin {
  final _formKey = GlobalKey<FormState>();

  late int _justID;
  late String _password;
  late String _password2;

  bool _isSubmitting = false;
  String? errorMessage;

  void initState() {
    check_user();
    super.initState();
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

      setState(() {
        _isSubmitting = true;
        errorMessage = '';
      });
      Map<String, dynamic> data = await post_request(
          url: 'http://143.42.55.127/user/api/register/',
          body: {
            'justID': _justID.toString(),
            'password': _password,
            'password2': _password2,
          });
      // Send a request to register the user
      print(data);
      setState(() {
        _isSubmitting = false;
      });

      if (data['response'] != "Error") {
        final prefs = await SharedPreferences.getInstance();
        String response = json.encode(data);
        await prefs.setString('user', response);

        UserDeserializer user = new UserDeserializer(response);
        UserDeserializerSingleton.setInstance(user);
        Navigator.pushReplacementNamed(context, '/loading');
      } else {
        // Registration failed, display an error message
        if (data['error_message']["justID"][0] ==
            "base user with this university ID already exists.")
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
              settings: const RouteSettings(name: '/login'),
              builder: (context) => LoginPage(
                message:
                    "This account exists, please login or activate your account.",
              ),
            ),
          );
        else if (data['error_message']["justID"][0] ==
            "That justID is not valid.")
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Invalid Credentials'),
              content: Text("This JUST ID is not valid."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        else
          setState(() {
            errorMessage = data['error_message']["justID"][0];
          });
      }
    }
  }

  Widget get TitleText => Text(
        'Together',
        style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue.shade600),
      );
  Widget get LogoImage => Image.asset(
        "assets/images/group.png",
        width: 250,
        height: 175,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      );
  Widget get HelpText => Text(
        "Create a new account",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black26),
      );

  Widget get JustIDInputdField => TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'JUST ID',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.lightBlue.shade900),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) 
            return 'Please enter JUST ID';
          
        String pattern = r'^\d{6}$';
        RegExp regExp = RegExp(pattern);

        if (!regExp.hasMatch(value))
          return 'JUST ID is invalid';
          return null;
        },
        onSaved: (value) {
          _justID = int.parse(value!);
        },
      );

  Widget get PasswordField => TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.lightBlue.shade900),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) return 'Please enter your password';

        String pattern = r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$";
        RegExp regExp = RegExp(pattern);

        if (!regExp.hasMatch(value))
          return 'Password must be minimum 8 characters, at least one number';

        return null;
      },
      onSaved: (value) {
        _password = value!;
      },
      onChanged: (value) {
        _password = value;
      });

  Widget get ConfirmPassword => TextFormField(
        obscureText: true,
        decoration: InputDecoration(
            labelText: 'Confirm Password',
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 2, color: Colors.lightBlue.shade900),
            )),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please confirm your password';
          } else if (value != _password) {
            return 'Passwords do not match';
          }
          return null;
        },
        onChanged: (value) {
          _password2 = value;
        },
        onSaved: (value) {
          _password2 = value!;
        },
      );

  Widget get SignUpButton => ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        child: _isSubmitting ? CircularProgressIndicator() : Text('Sign up'),
        style: ElevatedButton.styleFrom(
            fixedSize: Size(double.maxFinite, 60),
            backgroundColor: Colors.lightBlue.shade700),
      );
  Widget get SeperatorLine => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width / 2.8,
            color: Colors.lightBlue.shade900,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "or",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black26),
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width / 2.8,
            color: Colors.lightBlue.shade900,
          )
        ],
      );

  Widget get SignInButton => Center(
          child: TextButton(
        style: TextButton.styleFrom(),
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: Text(
          "Already have an account?",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black38,
              decoration: TextDecoration.underline),
        ),
      ));

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
                TitleText,
                LogoImage,
                SizedBox(height: 30),
                HelpText,
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        JustIDInputdField,
                        SizedBox(height: 20),
                        PasswordField,
                        SizedBox(height: 20),
                        ConfirmPassword,
                        SizedBox(height: 20),
                        SignUpButton,
                        SizedBox(
                          height: 20,
                        ),
                        SeperatorLine,
                        SizedBox(
                          height: 20,
                        ),
                        SignInButton
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Form(
                //   key: _formKey,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.stretch,
                //     children: [

                //       SizedBox(height: 20),
                //       TextFormField(
                //         obscureText: true,
                //         decoration: InputDecoration(
                //           labelText: 'Password',
                //           border: OutlineInputBorder(),
                //         ),
                //         validator: (value) {
                //           if (value!.isEmpty) {
                //             return 'Please enter your password';
                //           }
                //           return null;
                //         },
                //         onChanged: (value) {
                //           _password = value;
                //         },
                //       ),
                //       SizedBox(height: 20),

                // ElevatedButton(
                //   onPressed: _isSubmitting ? null : _submitForm,
                //   child: _isSubmitting
                //       ? CircularProgressIndicator()
                //       : Text('Register'),
                // ),
                if (errorMessage != null)
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          )))
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
