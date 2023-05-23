import 'package:flutter/material.dart';
import 'package:together/mixins/prefs_mixin.dart';



class ThemeContainer extends StatefulWidget {
  final Function? onLogout;
  final isDrawer;
  List<Widget> children;
  ThemeContainer(
      {super.key,
      required this.children,
      this.onLogout,
      this.isDrawer = false});

  @override
  State<ThemeContainer> createState() => _ThemeContainerState();
}

class _ThemeContainerState extends State<ThemeContainer> with PrefsMixin {
  Widget get LogoutButton => Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Color.fromARGB(231, 242, 253, 255),
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            decoration:
                BoxDecoration(color: Color.fromARGB(231, 242, 253, 255)),
          ),
        ),
      );

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
      drawer: widget.isDrawer
          ? Drawer(
              backgroundColor:
                  Color.fromARGB(231, 242, 253, 255).withOpacity(0.6),
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      color: Colors.blue.shade300,
                      margin: EdgeInsets.only(),
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 35, left: 20),
                        child: Center(
                          child: Text(
                            "Options",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {await logout();},
                      child: Text("Logout"),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent.shade700),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }

   logout() async {
    await set_prefs();
    prefs.remove("user");

    Navigator.pushReplacementNamed(context, "/login");
  }
}
