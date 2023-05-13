import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/pages/theme_container.dart';
import 'package:together/widgets/widgets/request_card.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart' as latLng;
class VolunteerRequestPage extends StatefulWidget {
  final RequestDeserializer request;
  final UserDeserializer user;
  const VolunteerRequestPage(
      {super.key, required this.request, required this.user});

  @override
  State<VolunteerRequestPage> createState() => _VolunteerRequestPageState();
}

class _VolunteerRequestPageState extends State<VolunteerRequestPage> {
  late WebSocketChannel channel;
  @override
  void initState() {
    // TODO: implement initState
    init_conn();
    super.initState();
    
  }

  @override
  void dispose() {
    close_conn();
    super.dispose();
  }

  close_conn() {
    channel != null ? channel.sink.close() : null;
  }

  init_conn() async {
    channel = IOWebSocketChannel.connect(
        Uri.parse(widget.request.request_websocket),
        headers: {"Authorization": "Token " + widget.user.token});
  }
Widget get MapWidget => Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 350, minHeight: 100, maxWidth: 600, minWidth: 200),
          child:  FlutterMap(

              options: MapOptions(
              enableMultiFingerGestureRace: false,
              enableScrollWheel: false,
              
                keepAlive: true,
                zoom: 18,
                maxZoom: 18,
                minZoom: 18,
                
                center: widget.request.latlong ,
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
            ),
          ),
        );



  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: channel.stream,
        builder: (context, wsData) {
          if (wsData.hasData) {
            handle_ws_message(wsData.requireData);
          }
          return ThemeContainer(
            children: [
              RequestCard(request: widget.request),
                  MapWidget,
            ],
          );
        });
  }
  
  void handle_ws_message(data) {
    
    print(data);
    var response = json.decode(data)["data"];
    if (response["response"] == "finish"){
      WidgetsBinding.instance.addPostFrameCallback((_) {Navigator.pushReplacementNamed(context, "/volunteer/home");});

    }
  }
}
