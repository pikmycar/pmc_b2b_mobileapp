import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class DriveToGarageScreen extends StatefulWidget {
  const DriveToGarageScreen({super.key});

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
    final colorScheme = Theme.of(context).colorScheme;
    
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
          color: colorScheme.primary,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DRIVING CUSTOMER CAR",
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    Text(
                      "En Route to\nGarage",
                      style: textTheme.displaySmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                  ],
                ),
                _buildActiveBadge(context),
              ],
            ),
          ),

          // Map Section
          Expanded(
            child: Stack(
              children: [
                _currentPosition == null
                    ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.build, size: 16, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text("Al Quoz Auto Service", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, -5)),
              ],
            ),
            child: Column(
              children: [
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, "8.4", "km left"),
                    _buildStatDivider(context),
                    _buildStatItem(context, "18", "min ETA"),
                    _buildStatDivider(context),
                    _buildStatItem(context, "62", "km/h"),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Destination Address
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blueAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Al Quoz Auto Service Center — Drop-off Point",
                          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isNavigating ? null : _startNavigation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isNavigating ? Icons.navigation : Icons.directions, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isNavigating ? "Delivering..." : "Navigate to Garage",
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

  Widget _buildActiveBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: _badgeController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.onPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.gps_fixed, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(
              "ACTIVE",
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(height: 40, width: 1, color: colorScheme.outlineVariant);
  }
}
