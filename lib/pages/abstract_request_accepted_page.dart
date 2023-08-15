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
import 'package:auto_size_text/auto_size_text.dart';
import '../../request/requests.dart';
import '../misc/backend.dart';

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
  List<Message> messages = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();
  late IOWebSocketChannel chatChannel;

  bool isChatOpened = false;
  @override
  void initState() {
    // TODO: implement initState
    init_conn();
    chatChannel = IOWebSocketChannel.connect(
        Uri.parse(widget.request.chatroom_websocket),
        headers: ws_headers);
    chatChannel.stream.listen((data) {
      Map<String, dynamic> message = json.decode(data);

      print(message);
      if (isChatOpened) Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        this.messages.add(Message(
            text: message["data"]["message"],
            isUsersMessage: widget.user.full_name == message["data"]["author"]
                ? true
                : false,
            date_created: message["data"]["date_created"]));
      });
      if (isChatOpened) {
        MessagesDialog;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      ;
    });
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
             apiUrl+"/location/update/volunteer/${ll.latitude}/${ll.longitude}/",
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
  void _sendMessage(String text, bool isUsersMessage) {
    // messages.add(Message(text: text, isUsersMessage: isUsersMessage));
    _textEditingController.clear();
    chatChannel.sink.add(json.encode({
      "data": {"message": text}
    }));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  int calculate_time(Message message) {
    DateTime dateTime = DateTime.parse(message.date_created).toLocal();

    String time = "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
    return DateTime.now().difference(dateTime).inMinutes;
  }

  Future get MessagesDialog {
    return showDialog(
      builder: (BuildContext context) {
        isChatOpened = true;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            titlePadding: EdgeInsets.zero,

            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.black12.withOpacity(0.2),
                    width: 1,
                    strokeAlign: StrokeAlign.outside),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Container(
                alignment: Alignment.center,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.lightBlue.shade700.withOpacity(0.95),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0))),
                child: Text(
                  'Chat',
                  style: TextStyle(color: Colors.white),
                )),
            content: Container(
              height: MediaQuery.of(context).size.height / 2.5,
              width: MediaQuery.of(context).size.width - 50,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      width: MediaQuery.of(context).size.width - 50,
                      // Set the desired height for the chat window
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          String msgText = messages[index].text;
                          bool msgIsUsersmessage =
                              messages[index].isUsersMessage;
                          return msgIsUsersmessage
                              ? myMessasge(messages[index])
                              : OthersMessage(messages[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // actionsAlignment: MainAxisAlignment.end,
            actionsPadding: EdgeInsets.zero,

            actions: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        decoration:
                            InputDecoration(hintText: 'Type your message'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        setState(() {
                          if (!_textEditingController.text.isEmpty)
                            _sendMessage(_textEditingController.text, true);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      context: context,
    ).then((val) {
      isChatOpened = false;
    });
  }

  Widget get ChatButton => ElevatedButton(
      onPressed: () {
        MessagesDialog;
      },
      child: Icon(
        Icons.message_outlined,
        color: Colors.lightBlue,
      ));

  Widget myMessasge(Message message) => Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                  width: message.text.length * 19 + 20,
                  constraints:
                      BoxConstraints(maxWidth: 200, minWidth: 40, minHeight: 5),
                  alignment: Alignment.center,
                  child: ListTile(
                    tileColor: Colors.greenAccent.shade700.withBlue(150),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    title: Text(
                      message.text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  )),
            ]),
            Text(
              textAlign: TextAlign.end,
              calculate_time(message) == 0
                  ? "now"
                  : "${calculate_time(message)} mins ago",
              style: TextStyle(fontSize: 8, color: Colors.black38),
            )
          ],
        ),
      );

  Widget OthersMessage(Message message) => Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: message.text.length * 19 + 20,
                  constraints: BoxConstraints(
                    maxWidth: 200,
                    minWidth: 40,
                    minHeight: 5,
                  ),
                  alignment: Alignment.center,
                  child: ListTile(
                    tileColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    title: Text(
                      message.text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.9)),
                    ),
                  )),
            ]),
            Text(
              textAlign: TextAlign.start,
              calculate_time(message) == 0
                  ? "now"
                  : "${calculate_time(message)} mins ago",
              style: TextStyle(fontSize: 8, color: Colors.black38),
            )
          ],
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
              children: [MapWidget, DraggableCard],
            ),
          );
        });
  }

  Widget get Card => throw UnimplementedError();

  Widget get DraggableCard => SizedBox.expand(
      child: DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.25,
          maxChildSize: 0.4,
          builder: (BuildContext context, ScrollController scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [DisplayDistance, ChatButton],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 2.8 - 5,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.2)),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0))),
                      child: Card,
                    ),
                  ],
                );
              },
            );
          }));

  void handle_ws_message(data) => throw UnimplementedError();
}

class Message {
  final String text, date_created;
  final bool isUsersMessage;
  Message({
    required this.text,
    required this.isUsersMessage,
    required this.date_created,
  });
}
