import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/places_data.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(7.8731, 80.7718),
          initialZoom: 7,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.tourist_guide',
          ),
          MarkerLayer(
            markers: seedPlaces.map((p) {
              return Marker(
                point: LatLng(p.lat, p.lng),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
