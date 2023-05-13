import 'package:flutter/material.dart';
import 'package:together/deserializers/request.dart';

class RequestCard extends StatelessWidget {
  final RequestDeserializer request;
  const RequestCard({super.key, required this.request});
//  Center(child: Text(widget.request.description??"No data")),
  // Center(child: Text("Location : ${((widget.request.square??"A") + (widget.request.building??"1"))}")),

  Widget get NameRow => Container(
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.black87.withOpacity(0.2), width: 0.5)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Column(
                children: [
                  Icon(
                    Icons.person_outline_outlined,
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
                    request.specialNeed.full_name,
                    style: TextStyle(fontSize: 18),
                  )
                ],
              )
            ],
          ),
        ),
      );
  Widget get PhoneNumberRow=>Container(
        decoration: BoxDecoration(
            border:
                Border.all(color: Colors.black87.withOpacity(0.2), width: 0.5)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
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
                    request.specialNeed.phone_number.isNotEmpty?request.specialNeed.phone_number:"Xxxxxxxxxx",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              )
            ],
          ),
        ),
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
              Text(
                request.description ?? "I want to reach my exam, and i cant!",
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
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
              Text(
                  "${((request.square ?? "A") + (request.building ?? ""))}"),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
            maxWidth: 400, maxHeight: 400,),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300, width: 3)),
        child: Wrap(
          alignment: WrapAlignment.start,
          children: [NameRow,PhoneNumberRow ,DescriptionRow, LocationRow],
        ),
      ),
    );
  }
}
