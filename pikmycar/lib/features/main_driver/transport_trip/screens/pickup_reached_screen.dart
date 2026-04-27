import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/transport_map_widget.dart';
import '../widgets/transport_header_widget.dart';
import '../widgets/transport_metrics_widget.dart';
import '../widgets/transport_bottom_ui_widget.dart';
import 'in_trip_screen.dart';

class PickupReachedScreen extends StatelessWidget {
  const PickupReachedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pickupPos = LatLng(25.0972, 55.1744);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          TransportMapWidget(
            markers: {
              const Marker(
                markerId: MarkerId('pickup'),
                position: pickupPos,
                infoWindow: InfoWindow(title: 'Pickup reached'),
              ),
            },
            polylines: const {},
            initialPosition: pickupPos,
            onMapCreated: (controller) {},
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TransportHeaderWidget(
              title: "Customer Waiting",
              subtitle: "You have arrived at the location",
              onBackTap: () => Navigator.pop(context),
            ),
          ),

          // Bottom UI
          Align(
            alignment: Alignment.bottomCenter,
            child: TransportBottomUIWidget(
              driverName: "John Doe",
              driverPhoto: "", 
              locationLabel: "At Pickup Location",
              locationAddress: "Mall of the Emirates, Entrance 3",
              buttonText: "START TRIP",
              onActionPressed: () {
                Navigator.pushNamed(context, '/in_trip');
              },
            ),
          ),
        ],
      ),
    );
  }
}
