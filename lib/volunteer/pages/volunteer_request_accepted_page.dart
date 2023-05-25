import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/mixins/location_mixin.dart';
import 'package:together/mixins/periodic_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/pages/theme_container.dart';
import 'package:together/volunteer/buttons/request/cancel_request_button.dart';
import 'package:together/widgets/widgets/request_card.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart' as latLng;

import '../../request/requests.dart';

class VolunteerRequestAcceptedPage extends StatefulWidget {
  final RequestDeserializer request;
  final UserDeserializer user;
  const VolunteerRequestAcceptedPage(
      {super.key, required this.request, required this.user});

  @override
  State<VolunteerRequestAcceptedPage> createState() =>
      _VolunteerRequestAcceptedPageState();
}

class _VolunteerRequestAcceptedPageState
    extends State<VolunteerRequestAcceptedPage>
    with
        WidgetsBindingObserver,
        LocationFetcherMixin,
        WebSocketMixin,
        PeriodicMixin {
  bool is_dialog_opened = false;
  late ValueNotifier<latLng.LatLng> latlong;
  MapController controller = new MapController();
  int distance = 500;
  @override
  void initState() {
    // TODO: implement initState
    init_conn();
    super.initState();
    
    var ll = new latLng.LatLng(
        widget.request.latlong.latitude, widget.request.latlong.longitude);
    latlong = new ValueNotifier<latLng.LatLng>(ll);
    periodic_function();
    calc_distance();
  }

  @override
  void dispose() {
    disposeTimer();
    close_conn();
    latlong.dispose();
    super.dispose();
  }

  @override
  cantFetchLocation() {}

  calc_distance() {
    setState(() {
      distance = latLng.Distance()
          .distance(latlong.value, widget.request.latlong)
          .toInt();
    });
  }

  periodic_function() async {
    var ll = await determinePosition();
    latlong.value.latitude = ll.latitude;
    latlong.value.longitude = ll.longitude;
    controller.move(latlong.value, 18);
    var res = await get_request(
        url:
            "http://143.42.55.127/location/update/volunteer/${ll.latitude}/${ll.longitude}/",
        headers: {"Authorization": "Token " + widget.user.token});
    calc_distance();
  }

  String get get_ws_url {
    return widget.request.request_websocket;
  }

  Map<String, dynamic> get ws_headers {
    return {"Authorization": "Token " + widget.user.token};
  }

  @override
  close_conn() {
    channel != null ? channel.sink.close() : null;
  }

  Widget get MapWidget => Container(
          child: ValueListenableBuilder(
        valueListenable: latlong,
        builder: (context, value, child) => FlutterMap(
          mapController: controller,
          options: MapOptions(
            enableMultiFingerGestureRace: false,
            enableScrollWheel: false,
            keepAlive: true,
            zoom: 18,
            maxZoom: 18,
            minZoom: 15,
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
                    Icons.accessible,
                    color: Colors.red.withOpacity(0.8),
                    size: 30,
                  ),
                ),
                Marker(
                  point: latlong.value,
                  width: 10,
                  height: 10,
                  builder: (context) => Icon(
                    Icons.person_pin_circle_sharp,
                    color: Colors.green.withOpacity(0.8),
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ));
  Widget get DisplayDistance => Padding(
        padding: EdgeInsets.only(right: 10),
        child: Container(
          height: 35,
          width: 75,
          color: Colors.white70.withOpacity(0.4),
          alignment: Alignment.center,
          child: Text(
            "${((distance / 100).floor() + 1).toString()} mins",
            style: TextStyle(fontSize: 16, color: Colors.black),
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
          return Scaffold(
            body: Stack(
              children: [
                MapWidget,
                SizedBox.expand(
                    child: DraggableScrollableSheet(
                        initialChildSize: 0.3,
                        minChildSize: 0.25,
                        maxChildSize: 0.4,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DisplayDistance,
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height /
                                        2.8,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.2)),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0))),
                                    child: RequestCard(
                                        request: widget.request,
                                        CancelButton: CancelRequestButton(
                                            user: widget.user,
                                            request: widget.request,
                                            set_accepted: () {},
                                            ErrorDialog: () {})),
                                  ),
                                ],
                              );
                            },
                          );
                        }))
              ],
            ),
          );
        });
  }

  setCanFetchLocation(value) {
    setState(() {
      canFetchLocation = value;
    });
  }

  dynamic dialog(String message) => !is_dialog_opened
      ? showDialog(
          builder: (BuildContext context) => AlertDialog(
            title: Text('error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () async {
                  is_dialog_opened = false;
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
          context: context,
        )
      : null;

  void handle_ws_message(data) {
    print(data);
    var response = json.decode(data)["data"];
    if (response["response"] == "finish") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/volunteer/home');
        dialog("Request is finished.");

        return;
      });
      return;
    }

    if (response["response"] == "cancel") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/volunteer/home');
        dialog("Request is canceled.");

        return;
      });
    }
  }
}
