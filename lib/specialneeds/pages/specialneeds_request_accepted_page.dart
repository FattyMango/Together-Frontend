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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  double rating = 5;
  String? description;
    List<Message> messages = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();
  late IOWebSocketChannel chatChannel;
  bool isChatOpened = false,  isNewMessage = false;
  @override
  void initState() {
    // TODO: implement initState
    init_conn();
    initChatWebSocket();
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
        chatChannel.sink.close();

    latlong.dispose();
    super.dispose();
  }
  void initChatWebSocket() {
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
            if (!isChatOpened) isNewMessage = true;
      });
      if (isChatOpened) {
        MessagesDialog;
      }
      ;
    });
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
  int calculate_time(Message message){
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

Widget get ChatButton => Stack(children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white54,shadowColor:Colors.white54 ,alignment: Alignment.center),
            onPressed: () { MessagesDialog;
            setState(() {
              isNewMessage = false;
            });},
            child: Container(
              margin: EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Icon(
                Icons.message_outlined,
                color: Colors.lightBlue.shade700,
              ),
            )),
        isNewMessage?Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Colors.red),
        ):Container()
      ]);


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
              calculate_time(message)==0?"now":"${calculate_time(message)} mins ago",
              style: TextStyle(fontSize: 8,color: Colors.black38),
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
              calculate_time(message)==0?"now":"${calculate_time(message)} mins ago",
              style: TextStyle(fontSize: 8,color: Colors.black38),
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
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [DisplayDistance, ChatButton],
                                    ),
                                  ),
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
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                'Thank you for using Together',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  overflow: TextOverflow.clip,
                ),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width - 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            margin: EdgeInsets.all(10),
                            child: Text(
                              "Please tell us how was your experience",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  overflow: TextOverflow.clip,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                    RatingBar.builder(
                      initialRating: rating,
                      itemCount: 5,
                      minRating: 0,
                      wrapAlignment: WrapAlignment.center,
                      maxRating: 5,
                      allowHalfRating: false,
                      glow: false,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_dissatisfied,
                              color: Colors.redAccent,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 3:
                            return Icon(
                              Icons.sentiment_satisfied,
                              color: Colors.lightGreen,
                            );
                          default:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                        }
                      },
                      onRatingUpdate: (value) {
                        rating = value;
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 100,
                      child: TextFormField(
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          filled: true,
                          hintText: 'Tell us what happened...',
                        ),
                        onChanged: (value) => description = value,
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      print(widget.request.id.toString());
                      print(widget.user.id);
                      print(rating);
                      print(description);
                      var res = await post_request(url: "http://143.42.55.127/report/create/", body: {
                        "request": widget.request.id.toString(),
                        "content" : description??"",
                        "rating": rating.toInt().toString(),
                        "is_resolved": (rating>=3?true:false).toString()
                      },headers: {"Authorization": "Token ${widget.user.token}" });
                      print(res);
                      
                      Navigator.pop(context);
                    },
                    child: Text("Submit"))
              ],
              actionsAlignment: MainAxisAlignment.center);
        },
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
        Navigator.pushReplacementNamed(context, '/specialneeds/home');
        dialog("message");
      });
      return;
    }
  }
}
class Message {
  final String text,date_created;
  final bool isUsersMessage;
  Message({
    required this.text,
    required this.isUsersMessage,
    required this.date_created,
  });
}