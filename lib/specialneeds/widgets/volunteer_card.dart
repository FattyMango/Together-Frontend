import 'package:flutter/material.dart';
import 'package:together/deserializers/user.dart';

class VolunteerCard extends StatelessWidget {
  final UserDeserializer volunteer;
  final Widget CancelButton;
  const VolunteerCard(
      {super.key, required this.volunteer, required this.CancelButton});
  Widget get VolunteerName => Container(
        margin: const EdgeInsets.only(top: 10),
        width: 250,
        child: Text(
          "${volunteer.full_name} has accepted your request, they are on their way.",
          overflow: TextOverflow.clip,
          style: TextStyle(
              fontSize: 23, backgroundColor: Colors.white.withOpacity(0.05)),
        ),
      );
  Widget get VolunteerPhone => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.phone,
            size: 30,
          ),
          SizedBox(width: 10,),
          Container(
            margin: EdgeInsets.only(top:10) ,
            width: 200,
            child: Text(
              "${volunteer.phone_number}",
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontSize: 23,
                  backgroundColor: Colors.white.withOpacity(0.05)),
            ),
          )
        ],
      );

  Widget get UserInfo => Padding(
        padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10,),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                    child:Image.asset(
                      "assets/images/default_img.jpg",
                      width: 100,
                      height: 100,
                    )),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              children: [VolunteerName, VolunteerPhone],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      
      child: Column(
        children: [
          UserInfo,
          SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CancelButton,
            ],
          )
        ],
      ),
    );
  }
}
