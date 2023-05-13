import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/pages/theme_container.dart';
import 'package:together/specialneeds/classes/request.dart';

import '../buttons/send_request.dart';

class RequestAcceptedPage extends StatefulWidget {
  final Request request;
  final UserDeserializer volunteer;
  final latLng.LatLng volunteer_location;
  final Function cancel_request;
  final String user_token;
  final int request_id;
  const RequestAcceptedPage(
      {super.key,
      required this.request,
      required this.volunteer,
      required this.volunteer_location, required this.cancel_request, required this.user_token, required this.request_id});

  @override
  State<RequestAcceptedPage> createState() => _RequestAcceptedPageState();
}

class _RequestAcceptedPageState extends State<RequestAcceptedPage> {
  Widget get MapWidget => Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
          constraints: BoxConstraints(
              maxHeight: 500, minHeight: 100, maxWidth: 600, minWidth: 200),
          child: FlutterMap(
            options: MapOptions(
              keepAlive: true,
              zoom: 18,
              maxZoom: 18,
              minZoom: 18,
              center: widget.request.latlong,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.request.latlong,
                    width: 10,
                    height: 10,
                    builder: (context) => Icon(
                      Icons.person_pin_circle,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          )));
  Widget get SubmitButton => Center(
        child: Container(
          child: SendRequestButton(submit_request: () async {
            return await widget.cancel_request(widget.user_token,widget.request_id) ;
          }),
        ),
      );
  @override
  Widget build(BuildContext context) {
    return ThemeContainer(children: [
      Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "${widget.volunteer.full_name} has accepted your request,",
              overflow: TextOverflow.clip,
              style: TextStyle(fontSize: 23),
            ),
            Text(
              "they are on their way.",
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(
              height: 20,
            ),
            MapWidget,
            SubmitButton
          ])
          )
    ]);
  }
}
