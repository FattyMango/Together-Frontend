import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:together/abstracts/abstract_state.dart';
import 'package:together/pages/error_page.dart';
import 'package:together/mixins/location_mixin.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/specialneeds/buttons/send_request.dart';
import 'package:together/pages/theme_container.dart';
import 'package:latlong2/latlong.dart' as latLng;

import '../../deserializers/user.dart';
import '../buttons/drop_down_button.dart';

class SpecialNeedsSendRequestPageState extends AbstractHomePageState
    with WebSocketMixin, UserFtecherMixin, LocationFetcherMixin {
  bool gender_constraint = false;
  late ValueNotifier<latLng.LatLng> pos;
  @override
  void initState() {
    pos = ValueNotifier<latLng.LatLng>(new latLng.LatLng(31.988926, 35.946191));
    super.initState();
  }

  Future<UserDeserializer> get_user() async {
    UserDeserializer user = await init_user();

    is_online ? await init_conn() : channel.sink.close();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([get_user()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            UserDeserializer user = snapshot.data![0];
            if (!user.is_specialNeeds)
              return show_error_page(
                  context, prefs, "You are not a special needs student.");
            return ThemeContainer(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("I need help in :",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                decoration: TextDecoration.none)),
                        SizedBox(
                          width: 20,
                        ),
                        HelpTypeDropDownButton(
                          list: ['One', 'Two', 'Three', 'Four'],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "I need a ${user.gender == "M" ? "male" : "female"}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                decoration: TextDecoration.none)),
                        SizedBox(
                          width: 30,
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
                  ),
                  // SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 60,
                      child: TextField(
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            filled: true, hintText: 'I have a special request'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: 350,
                          minHeight: 100,
                          maxWidth: 600,
                          minWidth: 200),
                      child: ValueListenableBuilder(
                        valueListenable: pos,
                        builder: (context, value, child) => FlutterMap(
                          
                          options: MapOptions(
                            onPositionChanged: (ll,bool) {
                              pos.value = ll.center!;
                            },
                            keepAlive: true ,
                            zoom: 18,
                            maxZoom: 18,
                            minZoom: 18,
                            center: pos.value,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  ),
                  SendRequestButton()
                ],
              ),
            ]);
          }
          return ThemeContainer(children: []);
        });
  }

  @override
  void dispose() {
    pos.dispose();
    super.dispose();
  }
}
