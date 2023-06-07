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
import 'package:together/specialneeds/pages/send_request_pages/set_constraints.dart';

import '../../../deserializers/user.dart';
import '../../buttons/drop_down_button.dart';

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
  late ValueNotifier<latLng.LatLng> pos;

  late String square, building;

  var square_list = ["A", "G", "C", "M", "N", "D", "PH", "CH"];
  var building_list = ["", "1", "2", "3", "4"];
  final myController = TextEditingController();
  @override
  void initState() {
    pos = new ValueNotifier<latLng.LatLng>(
        new latLng.LatLng(widget.pos.latitude, widget.pos.longitude));

    square = square_list.first;
    building = building_list.first;

    super.initState();
  }

  @override
  void dispose() {
    pos.dispose();
    super.dispose();
  }

  Widget get SquareField => Row(
        children: [
          Icon(Icons.location_pin),
          SizedBox(
            width: 5,
          ),
          Text("Square: ",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          SizedBox(
            width: 31,
          ),
          SizedBox(
            width: 80,
            child: ListDropDownButton(
                list: square_list,
                onChanged: (String value) {
                  setState(() {
                    square = value;
                  });
                }),
          ),
        ],
      );

  Widget get BuildingField => Row(
  
        children: [
          Icon(Icons.location_city_rounded),
          SizedBox(
            width: 5,
          ),
          Text("Building: ",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
                  SizedBox(width: 20,),
          SizedBox(
            width: 80,
            child: ListDropDownButton(
                list: building_list,
                onChanged: (String value) {
                  setState(() {
                    building = value;
                  });
                }),
          ),
        ],
      );
  Widget get LocationField => Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SquareField,
              SizedBox(
                height: 10,
              ),
              BuildingField
            ],
          ),
        ),
      );

  Widget get MapWidget => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          height: MediaQuery.of(context).size.height / 1.8,
          constraints: BoxConstraints(maxWidth: 600, minWidth: 200),
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

  Widget HeaderText(String text) => Text(text,
      style: TextStyle(
        color: Colors.blueGrey.shade800,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ));

  Widget get NextButton => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size(125, 50),backgroundColor: Colors.lightBlue.shade700),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SetConstraints(
                          submit_request: widget.submit_request,
                          user: widget.user,
                          request: new Request(
                              latlong: pos.value,
                              help_type: "M",
                              building: building,
                              square: square),
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Next",style: TextStyle(fontSize: 20),),
                    Icon(Icons.arrow_forward_ios_outlined,size: 20,)
                  ],
                )),
          ],
        ),
      );
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
            NextButton
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
