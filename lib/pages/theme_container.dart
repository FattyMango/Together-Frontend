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
          color: Color.fromARGB(231, 173, 205, 211),
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            decoration:
                BoxDecoration(color: Color.fromARGB(231, 242, 253, 255)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // widget.children.insert(
    //     0,
    //     Container(
    //       height: 40,
    //       decoration: BoxDecoration(
    //           color: Colors.blue.shade300,
    //           border: Border.all(color: Colors.blue.shade300),
    //           borderRadius: BorderRadius.only(
    //             bottomLeft: Radius.circular(50),
    //             bottomRight: Radius.circular(50),
    //           )),
    //     ));
    return Scaffold(
      appBar: AppBar(
        title: Text("Together",),
        titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 20,),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade800,
        toolbarHeight: 40,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
      ),
      body: Container(
          color: Color.fromARGB(231, 240, 253, 255),
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
                      alignment: Alignment.topCenter,
                      child: Center(
                        child: Text(
                          "Options",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height-150,),
                    ElevatedButton(
                      onPressed: () async {
                        await logout();
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 80),
                          backgroundColor: Colors.red.shade600),
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
