import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class RideToCustomerScreen extends StatefulWidget {
  const RideToCustomerScreen({Key? key}) : super(key: key);

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
          color: AppColors.designForestGreen,
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
                      "STATUS",
                      style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    Text(
                      "Riding to\nCustomer",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "IN VEHICLE",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
                    ? const Center(child: CircularProgressIndicator())
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Text("Dubai Marina", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    _buildStatItem("6.2", "km left"),
                    _buildStatDivider(),
                    _buildStatItem("14", "min ETA"),
                    _buildStatDivider(),
                    _buildStatItem("78", "km/h"),
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
                      const Icon(Icons.location_on, color: Colors.pink, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Dubai Marina, Tower B — Customer Location",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
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
                        Icon(_isNavigating ? Icons.navigation : Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isNavigating ? "Navigating to Customer..." : "Navigate to Customer",
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto', // Ensuring bold Roboto look
            letterSpacing: -1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
    );
  }
}
