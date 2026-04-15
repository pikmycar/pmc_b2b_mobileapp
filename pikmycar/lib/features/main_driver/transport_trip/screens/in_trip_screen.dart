import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/transport_map_widget.dart';
import '../widgets/transport_header_widget.dart';
import '../widgets/transport_metrics_widget.dart';
import '../widgets/transport_bottom_ui_widget.dart';
import 'trip_completed_screen.dart';
import '../../../../core/theme/app_theme.dart';

class InTripScreen extends StatelessWidget {
  const InTripScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const endPos = LatLng(25.0772, 55.1344); // Sample Dubai Marina Mall

    return Scaffold(
      body: Stack(
        children: [
          // Map
          TransportMapWidget(
            markers: {
              const Marker(
                markerId: MarkerId('drop'),
                position: endPos,
                infoWindow: InfoWindow(title: 'Drop-off location'),
              ),
            },
            polylines: {
               Polyline(
                polylineId: const PolylineId('route'),
                points: const [
                  LatLng(25.0972, 55.1744),
                  LatLng(25.0772, 55.1344),
                ],
                color: AppColors.primary,
                width: 5,
              ),
            },
            initialPosition: endPos,
            onMapCreated: (controller) {},
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TransportHeaderWidget(
              title: "Heading to Destination",
              subtitle: "Dropping in 12 mins",
              onBackTap: () => Navigator.pop(context),
            ),
          ),

          // Metrics
          const Positioned(
            top: 130,
            left: 16,
            right: 16,
            child: TransportMetricsWidget(
              distance: "4.8 km",
              eta: "12 mins",
              speed: "52 km/h",
            ),
          ),

          // Bottom UI
          Align(
            alignment: Alignment.bottomCenter,
            child: TransportBottomUIWidget(
              driverName: "John Doe",
              driverPhoto: "", 
              locationLabel: "Dropping at",
              locationAddress: "Dubai Marina Mall, Main Gate",
              buttonText: "COMPLETE TRIP",
              onActionPressed: () {
                Navigator.pushReplacementNamed(context, '/trip_completed');
              },
            ),
          ),
        ],
      ),
    );
  }
}
