import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:together/deserializers/request.dart';
import 'package:together/deserializers/user.dart';
import 'package:together/mixins/periodic_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/pages/theme_container.dart';
import 'package:together/specialneeds/buttons/finish_request.dart';
import 'package:together/specialneeds/classes/request.dart';
import 'package:together/specialneeds/home.dart';
import 'package:together/specialneeds/pages/waiting_accept_request.dart';
import 'package:together/specialneeds/widgets/volunteer_card.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../../request/requests.dart';
import '../buttons/send_request.dart';

class RequestAcceptedPage extends StatefulWidget {
  final RequestDeserializer request;
  final UserDeserializer user, volunteer;
  const RequestAcceptedPage({
    super.key,
    required this.request,
    required this.user,
    required this.volunteer,
  });

  @override
  State<RequestAcceptedPage> createState() => _RequestAcceptedPageState();
}

class _RequestAcceptedPageState extends State<RequestAcceptedPage>
    with WidgetsBindingObserver, PeriodicMixin, WebSocketMixin {
  bool is_dialog_opened = false;
  int distance = 500;
  late ValueNotifier<latLng.LatLng> latlong;
  late MapController controller = new MapController();
  @override
  void initState() {
    // TODO: implement initState
    init_conn();
    super.initState();

    controller = new MapController();
    latlong = new ValueNotifier<latLng.LatLng>(widget.request.latlong);
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

  calc_distance() {
    setState(() {
      distance = latLng.Distance()
          .distance(latlong.value, widget.request.latlong)
          .toInt();
    });
  }

  @override
  periodic_function() async {
    if (!waitingForResponse) {
      waitingForResponse = true;
      latLng.LatLng res = await fetch_location();
      if (res.latitude != 0) {
        latlong.value = res;
        calc_distance();
      }

      waitingForResponse = false;
    }
  }

  @override
  Map<String, dynamic> get ws_headers =>
      {"Authorization": "Token " + widget.user.token};
  @override
  String get get_ws_url => widget.request.request_websocket;

  Future<latLng.LatLng> fetch_location() async {
    var res = await get_request(
        url: "http://143.42.55.127/location/get/${widget.volunteer.justID}/",
        headers: {"Authorization": "Token " + widget.user.token});

    latLng.LatLng ll = new latLng.LatLng(0, 0);
    if (res["response"] == "success") {
      ll = new latLng.LatLng(
          double.parse(res["latitude"]), double.parse(res["longitude"]));
      if (controller != null) {
        controller.move(ll, 18);
      }
    }
    return ll;
  }

  Widget get MapWidget => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ValueListenableBuilder(
          valueListenable: latlong,
          builder: (context, value, child) => FlutterMap(
            mapController: controller,
            options: MapOptions(
              keepAlive: true,
              zoom: 18,
              maxZoom: 18,
              minZoom: 15,
              center: latlong.value,
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
        ),
      );

  Widget get FinishButton => FinishRequestButtom(submit_request: () async {
        await convert_to_Request(widget.request)
            .finish_request(widget.user.token, widget.request.id);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/specialneeds/home');
        });
      });

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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.9,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          border: Border.all(
                                              color: Colors.black
                                                  .withOpacity(0.2)),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0))),
                                      child: VolunteerCard(
                                        volunteer: widget.volunteer,
                                        CancelButton: FinishButton,
                                      ))
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

  dynamic dialog(String message) => showDialog(
        builder: (BuildContext context) => AlertDialog(
          title: Text('error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () async {
                is_dialog_opened = false;
                Navigator.pushReplacementNamed(context, '/specialneeds/home');
              },
              child: Text('OK'),
            ),
          ],
        ),
        context: context,
      );

  handle_ws_message(data) {
    print(1);
    print(data);
    var response = json.decode(data)["data"];
    if (response["response"] == "cancel") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        close_conn();
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
              settings:
                  const RouteSettings(name: '/specialneed/request/waiting'),
              builder: (context) => WaitingForVolunteerPage(
                    request: widget.request,
                    user: widget.user,
                  )),
        );
      });
      return;
    }
    if (response["response"] == "finish") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        close_conn();
        dialog("Request is finished.");
        Navigator.pushReplacementNamed(context, '/specialneeds/home');
      });
      return;
    }
  }
}
