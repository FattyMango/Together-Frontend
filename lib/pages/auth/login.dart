import 'dart:convert';
import 'dart:ffi' as size;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/mixins/prefs_mixin.dart';
import 'package:together/singeltons/user_singelton.dart';

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
            "You must be a volunteer or a special needs students to use this app.";
      });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      // Make the API request to authenticate the user

      var data = await post_request(
          url: 'http://143.42.55.127/user/api/login/',
          body: {
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

        UserDeserializer user = new UserDeserializer(response);
        UserDeserializerSingleton.setInstance(user);
        Navigator.pushReplacementNamed(context, '/loading');
      } else {
        // Registration failed, display an error message
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Login failed'),
            content: Text("Please make sure that your credentials are valid, and try again."),
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
        "Sign in to continue",
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
          if (value!.isEmpty) return 'Please enter JUST ID';

          // String pattern = r'^\d{6}$';
          // RegExp regExp = RegExp(pattern);

          // if (!regExp.hasMatch(value)) return 'JUST ID is invalid';
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
  Widget get SigninButton => ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading ? CircularProgressIndicator() : Text('Sign in'),
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

  Widget get SignupButton => Center(
          child: TextButton(
        style: TextButton.styleFrom(),
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/register");
        },
        child: Text(
          "Create a new account",
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
            padding: EdgeInsets.all(20),
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
                        SigninButton,
                        SizedBox(
                          height: 20,
                        ),
                        SeperatorLine,
                        SizedBox(
                          height: 20,
                        ),
                        SignupButton
                      ],
                    ),
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
