import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/transport_map_widget.dart';
import '../widgets/transport_header_widget.dart';
import '../widgets/transport_metrics_widget.dart';
import '../widgets/transport_bottom_ui_widget.dart';
import 'pickup_reached_screen.dart';

class NavigateToPickupScreen extends StatelessWidget {
  const NavigateToPickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pickupPos = LatLng(25.0972, 55.1744); // Sample Dubai Marina

    return Scaffold(
      body: Stack(
        children: [
          // Map
          TransportMapWidget(
            markers: {
              const Marker(
                markerId: MarkerId('pickup'),
                position: pickupPos,
                infoWindow: InfoWindow(title: 'Pickup point'),
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
              title: "Navigating to Pickup",
              subtitle: "Arriving in 6 mins",
              onBackTap: () => Navigator.pop(context),
            ),
          ),

          // Metrics
          const Positioned(
            top: 130,
            left: 16,
            right: 16,
            child: TransportMetricsWidget(
              distance: "2.5 km",
              eta: "6 mins",
              speed: "45 km/h",
            ),
          ),

          // Bottom UI
          Align(
            alignment: Alignment.bottomCenter,
            child: TransportBottomUIWidget(
              driverName: "John Doe",
              driverPhoto: "", // Dummy
              locationLabel: "Pickup from",
              locationAddress: "Mall of the Emirates, Entrance 3",
              buttonText: "ARRIVED AT PICKUP",
              onActionPressed: () {
                Navigator.pushNamed(context, '/pickup_reached');
              },
            ),
          ),
        ],
      ),
    );
  }
}
