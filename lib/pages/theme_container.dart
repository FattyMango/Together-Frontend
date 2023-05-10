import 'package:flutter/material.dart';

class ThemeContainer extends StatefulWidget {
   List<Widget> children;
  ThemeContainer({super.key, required this.children});

  @override
  State<ThemeContainer> createState() => _ThemeContainerState();
}

class _ThemeContainerState extends State<ThemeContainer> {
  @override
  Widget build(BuildContext context) {
    widget.children.insert(
        0,
        Container(
          height: 40,
          decoration: BoxDecoration(
              color: Colors.blue.shade300,
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ));
    return Scaffold(
      body: Container(
          color: Color.fromARGB(231, 242, 253, 255),
          child: ListView(
            
            children: widget.children,
          )),
    );
  }
}
