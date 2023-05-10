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
  final Position pos;
  SendRequestPage(
      {super.key, required this.submit_request, required this.user, required this.pos, });

  @override
  State<SendRequestPage> createState() => _SendRequestPageState();
}

class _SendRequestPageState extends State<SendRequestPage> {
  bool gender_constraint = false;
  late ValueNotifier<latLng.LatLng> pos;
  late String? special_request;
  late String help_type;
  var help_type_list = ["M","V","E"];
  @override
void initState()  {
    pos = new ValueNotifier<latLng.LatLng>(
        new latLng.LatLng(widget.pos.latitude, widget.pos.longitude));
        help_type = help_type_list.first;
    super.initState();
  }

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
            HelpTypeDropDownButton(
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

  Widget SpecialRequestField = Padding(
    padding: const EdgeInsets.all(20),
    child: SizedBox(
      height: 60,
      child: TextField(
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        decoration:
            InputDecoration(filled: true, hintText: 'I have a special request'),
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
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red),
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
                gender: gender_constraint?widget.user.gender[0]:"N",
                latlong: pos.value,
                help_type: help_type[0],
                ),true
                );
          }),
    ),
  );

  @override
  Widget build(BuildContext context) {

    return ThemeContainer(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [HelpTypeField, GenderField, SpecialRequestField, MapWidget, SubmitButton],
      ),
    ]);
    ;
  }
}
