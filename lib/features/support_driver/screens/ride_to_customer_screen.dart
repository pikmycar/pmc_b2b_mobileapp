import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class RideToCustomerScreen extends StatefulWidget {
  const RideToCustomerScreen({super.key});

  @override
  State<RideToCustomerScreen> createState() => _RideToCustomerScreenState();
}

class _RideToCustomerScreenState extends State<RideToCustomerScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isNavigating = false;
  Timer? _arrivalTimer;

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
    
    // Auto-navigate to Arrival screen after 15 seconds
    _arrivalTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/support_driver_arrived_at_pickup');
      }
    });
  }

  @override
  void dispose() {
    _arrivalTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Trip?"),
        content: const Text("Are you sure you want to cancel this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return true;
      Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
      return true;
    }
    return false;
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

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
    
    // Mock Customer Location (approx 6km away)
    final customerLatLng = LatLng(position.latitude + 0.045, position.longitude + 0.032);

    // Driver Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: const InfoWindow(title: 'You (In Vehicle)'),
      ),
    );

    // Customer Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('customer_location'),
        position: customerLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: const InfoWindow(title: 'Customer Pickup'),
      ),
    );

    if (_isNavigating) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_customer'),
          points: [userLatLng, customerLatLng],
          color: colorScheme.primary,
          width: 6,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }
  }

  void _startNavigation() {
    if (_currentPosition == null) return;
    setState(() {
      _isNavigating = true;
      _updateMapElements(_currentPosition!);
    });
    
    // Zoom out to show both markers
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentPosition!.latitude < _currentPosition!.latitude + 0.045 
                ? _currentPosition!.latitude 
                : _currentPosition!.latitude + 0.045,
            _currentPosition!.longitude < _currentPosition!.longitude + 0.032
                ? _currentPosition!.longitude
                : _currentPosition!.longitude + 0.032,
          ),
          northeast: LatLng(
            _currentPosition!.latitude > _currentPosition!.latitude + 0.045
                ? _currentPosition!.latitude
                : _currentPosition!.latitude + 0.045,
            _currentPosition!.longitude > _currentPosition!.longitude + 0.032
                ? _currentPosition!.longitude
                : _currentPosition!.longitude + 0.032,
          ),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed(context);
      },
      child: Scaffold(
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
                        "STATUS",
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      Text(
                        "Riding to\nCustomer",
                        style: textTheme.displaySmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w900, height: 1.1),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "IN VEHICLE",
                          style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
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
                            zoom: 14,
                          ),
                          markers: _markers,
                          polylines: _polylines,
                          onMapCreated: (controller) => _mapController = controller,
                          myLocationEnabled: true,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                        
                  // Destination Label (Floating)
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
                      child: Text("Dubai Marina", style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                      _buildStatItem(context, "6.2", "km left"),
                      _buildStatDivider(context),
                      _buildStatItem(context, "14", "min ETA"),
                      _buildStatDivider(context),
                      _buildStatItem(context, "78", "km/h"),
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
                        Icon(Icons.location_on, color: AppColors.error, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Dubai Marina, Tower B — Customer Location",
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          Icon(_isNavigating ? Icons.navigation : Icons.location_on, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isNavigating ? "Navigating to Customer..." : "Navigate to Customer",
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
    return Container(
      height: 40,
      width: 1,
      color: colorScheme.outlineVariant,
    );
  }
}
