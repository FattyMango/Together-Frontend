import 'package:flutter/material.dart';

import '../../deserializers/user.dart';
import '../buttons/set_online/setonline_button.dart';
import '../../pages/theme_container.dart';

class VolunteerHomeContainer extends StatefulWidget {
  final UserDeserializer user;
  final Function set_online;

  final bool is_validated, is_online;
  const VolunteerHomeContainer(
      {super.key,
      required this.user,
      required this.set_online,
      required this.is_validated,
      required this.is_online});

  @override
  State<VolunteerHomeContainer> createState() => _VolunteerHomeContainerState();
}

class _VolunteerHomeContainerState extends State<VolunteerHomeContainer> {
  @override
  Widget build(BuildContext context) {
    return ThemeContainer(
      children: [
        SizedBox(
          height: 40,
        ),
        Center(
          child: Text(
            "Hello " + widget.user.full_name.toString(),
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                decoration: TextDecoration.none),
          ),
        ),
        SetOnlineButton(
          user: widget.user,
          set_is_online: (res) => widget.set_online(res),
          is_online: widget.is_online,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.is_validated
                  ? "There is no request for you now."
                  : "You are not a valid volunteer, please ask your mentor for validation.",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  decoration: TextDecoration.none),
            ),
          )),
        ),
      ],
    );
    ;
  }
}
