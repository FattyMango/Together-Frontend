import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:together/abstracts/abstract_state.dart';
import 'package:together/pages/error_page.dart';
import 'package:together/mixins/location_mixin.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/specialneeds/buttons/send_request.dart';
import 'package:together/pages/theme_container.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/specialneeds/classes/request.dart';

import '../../deserializers/user.dart';
import '../buttons/drop_down_button.dart';

class SendRequestPage extends StatefulWidget {
  final Function submit_request;
  final UserDeserializer user;
  final latLng.LatLng pos;

  SendRequestPage({
    super.key,
    required this.submit_request,
    required this.user,
    required this.pos,
  });

  @override
  State<SendRequestPage> createState() => _SendRequestPageState();
}

class _SendRequestPageState extends State<SendRequestPage> {
  bool gender_constraint = false;
  late ValueNotifier<latLng.LatLng> pos;

  late String square, building, description;

  var square_list = ["A", "G", "C", "M", "N", "D", "PH", "CH"];
  var building_list = ["", "1", "2", "3", "4"];
  final myController = TextEditingController();
  @override
  void initState() {
    pos = new ValueNotifier<latLng.LatLng>(
        new latLng.LatLng(widget.pos.latitude, widget.pos.longitude));

    square = square_list.first;
    building = building_list.first;
    description = "no data";
    super.initState();
  }

  @override
  void dispose() {
    pos.dispose();
    super.dispose();
  }

  Widget get LocationField => Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Square: ",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                width: 70,
                child: ListDropDownButton(
                    list: square_list,
                    onChanged: (String value) {
                      setState(() {
                        square = value;
                      });
                    }),
              ),
              SizedBox(
                width: 10,
              ),
              Text("Building: ",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                width: 70,
                child: ListDropDownButton(
                    list: building_list,
                    onChanged: (String value) {
                      setState(() {
                        building = value;
                      });
                    }),
              ),
            ],
          ),
        ),
      );

  Widget get GenderField => Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10, left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
              activeColor: Colors.greenAccent.shade700,
              checkColor: Colors.white,
              value: gender_constraint,
              onChanged: (bool? value) {
                setState(() {
                  gender_constraint = value!;
                });
              },
            ),

            Text(
                "${gender_constraint ? "Yes i need a ${widget.user.gender == "M" ? "male" : "female"}" : "No it does not matter"} ",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    decoration: TextDecoration.none)),
          ],
        ),
      );

  Widget get DescriptionField => Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        child: SizedBox(
          height: 60,
          child: TextFormField(
            onChanged: (value) {
              setState(() {
                description = value;
              });
            },
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              filled: true,
              hintText: 'I need to go to my class...',
            ),
          ),
        ),
      );

  Widget get MapWidget => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 300, minHeight: 100, maxWidth: 600, minWidth: 200),
          child: ValueListenableBuilder(
            valueListenable: pos,
            builder: (context, value, child) => FlutterMap(
              options: MapOptions(
                onPositionChanged: (ll, bool) {
                  pos.value = ll.center!;
                },
                keepAlive: true,
                zoom: 18,
                maxZoom: 18,
                minZoom: 18,
                center: pos.value,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pos.value,
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
            ),
          ),
        ),
      );

  Widget get SubmitButton => Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: SendRequestButton(submit_request: () {
              return widget.submit_request(new Request(
                  gender: gender_constraint ? widget.user.gender[0] : "N",
                  latlong: pos.value,
                  help_type: "M",
                  building: building,
                  description: description,
                  square: square));
            }),
          ),
        ),
      );
  Widget HeaderText(String text) => Text(text,
      style: TextStyle(
        color: Colors.blueGrey.shade800,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ));
  @override
  Widget build(BuildContext context) {
    return ThemeContainer(isDrawer: true, children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderText("Set your location"),
            MapWidget,
            HeaderText("Where are you?"),
            LocationField,
            HeaderText(
                "Do you need a ${widget.user.gender == "M" ? "male" : "female"}?"),
            GenderField,
            HeaderText("Describe your need"),
            DescriptionField,
            SubmitButton
          ],
        ),
      ),
    ]);
    ;
  }

  Color? getColor(Set<MaterialState> states) {
    print(states);
    return Colors.red;
  }
}
