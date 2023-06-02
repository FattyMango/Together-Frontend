import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../deserializers/request.dart';

class MapWidget extends StatelessWidget {
  final RequestDeserializer request;
  const MapWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        zoom: 18,
        maxZoom: 19,
        minZoom: 16,
        center: request.latlong,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: request.latlong,
              width: 10,
              height: 10,
              builder: (context) =>Icon(
                      Icons.person_pin_circle,
                      size: 30,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
