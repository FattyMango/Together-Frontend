import 'package:flutter/material.dart';

import '../../pages/theme_container.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitingForVolunteerPage extends StatefulWidget {
  const WaitingForVolunteerPage({super.key});

  @override
  State<WaitingForVolunteerPage> createState() =>
      _WaitingForVolunteerPageState();
}

class _WaitingForVolunteerPageState extends State<WaitingForVolunteerPage> {
  @override
  Widget build(BuildContext context) {
    return ThemeContainer(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(height: MediaQuery.of(context).size.height/4,),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Text("Hold on, we are looking for your hero!",style: TextStyle(fontSize: 50),),
            ),
            SpinKitFadingCircle(
              color: Colors.black,
              size: 50.0,
            )
          ],
        ),
      ],
    );
  }
}
