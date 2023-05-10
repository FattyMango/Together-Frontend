import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_container.dart';

Widget show_error_page(context, SharedPreferences? prefs, String message) {
  return ThemeContainer(
    children: [
      Center(
        child: Container(
          child: Text(message,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  decoration: TextDecoration.none)),
        ),
      ),
      Center(
        child: GestureDetector(
            onTap: () {
            
              prefs!=null?
              prefs.remove('user'):null;
              Navigator.pushReplacementNamed(context, "/login");
            },
            child: Container(
              child: Text(
                "Please Login again.",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    decoration: TextDecoration.none),
              ),
            )),
      )
    ],
  );
}
