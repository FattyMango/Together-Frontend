import 'package:flutter/material.dart';

import '../../../deserializers/request.dart';
import '../../../deserializers/user.dart';

class SendRequestButton extends StatefulWidget {
  final Function submit_request;
  const SendRequestButton({super.key, required this.submit_request});

  @override
  State<SendRequestButton> createState() => _SendRequestButtonState();
}

class _SendRequestButtonState extends State<SendRequestButton> {
  Widget get get_button {
    return ElevatedButton(
      onPressed: () {
        widget.submit_request();
      },
      child: Text(
        "Request help!",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
          fixedSize: Size(150, 60), backgroundColor: Colors.blue.shade800),
    );
  }

  @override
  Widget build(BuildContext context) => get_button;
}
