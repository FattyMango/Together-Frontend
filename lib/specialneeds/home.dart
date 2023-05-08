import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:together/abstracts/abstract_state.dart';
import 'package:together/pages/error_page.dart';
import 'package:together/mixins/location_mixin.dart';
import 'package:together/mixins/user_fetch_mixin.dart';
import 'package:together/mixins/websocket_mixin.dart';
import 'package:together/specialneeds/buttons/send_request.dart';
import 'package:together/specialneeds/pages/send_request_page.dart';
import 'package:together/pages/theme_container.dart';
import 'package:latlong2/latlong.dart' as latLng;
import '../deserializers/user.dart';
import 'buttons/drop_down_button.dart';

class SpecialNeedsHomePage extends AbstractHomePage {
  bool is_request_sent = false, is_request_accepted = false;
  SpecialNeedsHomePage({super.key});
  @override
  AbstractHomePageState createState() {
    
    return SpecialNeedsSendRequestPageState();}
}

