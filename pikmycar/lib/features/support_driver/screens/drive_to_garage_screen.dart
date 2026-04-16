import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class DriveToGarageScreen extends StatefulWidget {
  const DriveToGarageScreen({Key? key}) : super(key: key);

  @override
  State<DriveToGarageScreen> createState() => _DriveToGarageScreenState();
}

class _DriveToGarageScreenState extends State<DriveToGarageScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isNavigating = false;
  Timer? _arrivalTimer;
  late AnimationController _badgeController;

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
    
    // Pulse animation for the "ACTIVE" badge
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Auto-navigate to Arrival screen after 20 seconds
    _arrivalTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/support_driver_arrived_at_garage');
      }
    });
  }

  @override
  void dispose() {
    _arrivalTimer?.cancel();
    _badgeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      _updateMapElements(position);
    });
  }

  void _updateMapElements(Position position) {
    _markers.clear();
    final userLatLng = LatLng(position.latitude, position.longitude);
    
    // Mock Garage Location (approx 8.4km away)
    final garageLatLng = LatLng(position.latitude + 0.055, position.longitude + 0.042);

    // Driver Marker (In Customer Car)
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_in_car'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Driving Customer Car'),
      ),
    );

    // Garage Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('garage_location'),
        position: garageLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Al Quoz Auto Service Center'),
      ),
    );

    if (_isNavigating) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_garage'),
          points: [userLatLng, garageLatLng],
          color: AppColors.designForestGreen,
          width: 6,
          patterns: [PatternItem.dash(20), PatternItem.gap(12)],
        ),
      );
    }
  }

  void _startNavigation() {
    setState(() {
      _isNavigating = true;
      if (_currentPosition != null) _updateMapElements(_currentPosition!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              color: AppColors.designForestGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "DRIVING CUSTOMER CAR",
                      style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    Text(
                      "En Route to\nGarage",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                  ],
                ),
                _buildActiveBadge(),
              ],
            ),
          ),

          // Map Section
          Expanded(
            child: Stack(
              children: [
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 13,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        onMapCreated: (controller) => _mapController = controller,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                      
                // Destination Floating Label
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.build, size: 16, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text("Al Quoz Auto Service", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
              ],
            ),
            child: Column(
              children: [
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("8.4", "km left"),
                    _buildStatDivider(),
                    _buildStatItem("18", "min ETA"),
                    _buildStatDivider(),
                    _buildStatItem("62", "km/h"),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Destination Address
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Al Quoz Auto Service Center — Drop-off Point",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isNavigating ? null : _startNavigation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.designForestGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isNavigating ? Icons.navigation : Icons.directions, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isNavigating ? "Delivering..." : "Navigate to Garage",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge() {
    return FadeTransition(
      opacity: _badgeController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: const [
            Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 18),
            SizedBox(width: 8),
            Text(
              "ACTIVE",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'Roboto', letterSpacing: -1),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade200);
  }
}
