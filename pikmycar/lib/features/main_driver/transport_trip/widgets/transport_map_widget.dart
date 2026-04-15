import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TransportMapWidget extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final LatLng initialPosition;
  final Function(GoogleMapController) onMapCreated;

  const TransportMapWidget({
    Key? key,
    required this.markers,
    required this.polylines,
    required this.initialPosition,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 14,
      ),
      onMapCreated: onMapCreated,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      style: null, // Always use light map for white background theme
    );
  }
}
