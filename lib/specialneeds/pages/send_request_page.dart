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

  late String help_type, square, building, description;
  var help_type_list = ["M", "V", "E"];
  var square_list = ["A", "G", "C", "M", "N", "D", "PH", "CH"];
  var building_list = ["", "1", "2", "3", "4"];
  final myController = TextEditingController();
  @override
  void initState() {
    pos = new ValueNotifier<latLng.LatLng>(
        new latLng.LatLng(widget.pos.latitude, widget.pos.longitude));
    help_type = help_type_list.first;
    square = square_list.first;
    building = building_list.first;
    description = "no data";
    super.initState();
  }

  @override
  void dispose(){
    pos.dispose();
    super.dispose();
  }

  Widget get LocationField => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            Text("i'm in",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    decoration: TextDecoration.none)),
            SizedBox(
              width: 15,
            ),
            ListDropDownButton(
                list: square_list,
                onChanged: (String value) {
                  setState(() {
                    square = value;
                  });
                }),
            SizedBox(
              width: 5,
            ),
            ListDropDownButton(
                list: building_list,
                onChanged: (String value) {
                  setState(() {
                    building = value;
                  });
                }),
          ],
        ),
      );

  Widget get HelpTypeField => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          children: [
            Text("I need help in :",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    decoration: TextDecoration.none)),
            SizedBox(
              width: 15,
            ),
            ListDropDownButton(
                list: help_type_list,
                onChanged: (String value) {
                  setState(() {
                    help_type = value;
                  });
                }),
          ],
        ),
      );

  Widget get GenderField => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Text("I need a ${widget.user.gender == "M" ? "male" : "female"}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    decoration: TextDecoration.none)),
            SizedBox(
              width: 15,
            ),
            Switch(
              value: gender_constraint,
              onChanged: (bool value) {
                setState(() {
                  gender_constraint = value;
                });
              },
            ),
          ],
        ),
      );

  Widget DescriptionField = Padding(
    padding: const EdgeInsets.all(20),
    child: SizedBox(
      height: 60,
      child: TextFormField(
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          filled: true,
          hintText: 'I have a special request',
        ),
      ),
    ),
  );

  Widget get MapWidget => Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 350, minHeight: 100, maxWidth: 600, minWidth: 200),
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
        child: Container(
          child: SendRequestButton(submit_request: () {
            return widget.submit_request(new Request(
                gender: gender_constraint ? widget.user.gender[0] : "N",
                latlong: pos.value,
                help_type: help_type[0],
                building: building,
                description: description,
                square: square));
          }),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ThemeContainer(
        isDrawer: true,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpTypeField,
              LocationField,
              GenderField,
              Padding(
                padding: const EdgeInsets.all(20),
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
                      hintText: 'describe your need...',
                    ),
                  ),
                ),
              ),
              MapWidget,
              SubmitButton
            ],
          ),
        ]);
    ;
  }
}
