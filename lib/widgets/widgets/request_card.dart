import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';

class RequestCard extends StatelessWidget {
  final RequestDeserializer request;
    final Widget CancelButton;
  const RequestCard({super.key, required this.request, required this.CancelButton});
//  Center(child: Text(widget.request.description??"No data")),
  // Center(child: Text("Location : ${((widget.request.square??"A") + (widget.request.building??"1"))}")),

  Widget get NameRow => Row(
    children: [

      SizedBox(
        width: 5,
      ),
      Column(
        children: [
          Container(
            width: 200,
            child: Text(
              "${request.specialNeed.full_name} is waiting for you.",
              style: TextStyle(fontSize: 22),
            ),
          )
        ],
      )
    ],
  );
  Widget get PhoneNumberRow => Row(
        children: [
          Column(
            children: [
              Icon(
                Icons.phone,
                size: 25,
              ),
            ],
          ),
          SizedBox(
            width: 5,
          ),
          Column(
            children: [
              Text(
                request.specialNeed.phone_number.isNotEmpty
                    ? request.specialNeed.phone_number
                    : "Xxxxxxxxxx",
                style: TextStyle(fontSize: 18),
              )
            ],
          )
        ],
      );
  Widget get DescriptionRow => Container(
    
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.black87.withOpacity(0.2), width: 0.5)),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.message_outlined,
                size: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                width: 250,
                child: Text(
                  request.description ?? "I want to reach my exam, and i cant!",
                  
                ),
              ),
            ],
          ),
        ),
      );

  Widget get LocationRow => Container(
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.black87.withOpacity(0.2), width: 0.5)),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 25,
              ),
              SizedBox(
                width: 5,
              ),
              Text("${((request.square ?? "A") + (request.building ?? ""))}"),
            ],
          ),
        ),
      );
  Widget get UserInfo => Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Image.asset(
                      "assets/images/default_img.jpg",
                      width: 75,
                      height: 75,
                    )),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NameRow,
                
                
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Wrap(  
      alignment: WrapAlignment.start,
      children: [
        UserInfo,
        PhoneNumberRow,
        DescriptionRow,
        LocationRow,
        SizedBox(height: 60),
        Center(child: CancelButton)
      ],
    );
  }
}
