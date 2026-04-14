import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class DriverOnWayScreen extends StatefulWidget {
  const DriverOnWayScreen({Key? key}) : super(key: key);

  @override
  State<DriverOnWayScreen> createState() => _DriverOnWayScreenState();
}

class _DriverOnWayScreenState extends State<DriverOnWayScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
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
      _updateMarkers(position);
    });
  }

  void _updateMarkers(Position position) {
    _markers.clear();
    
    // User Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Mock Driver Marker (slightly offset)
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: LatLng(position.latitude + 0.005, position.longitude + 0.005),
        infoWindow: const InfoWindow(title: 'Khalid Al-Ameri'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Driver On Way 🚕',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        backgroundColor: AppColors.designYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge("🚕 Main Driver Assigned", const Color(0xFFE8F5E9), textColor: const Color(0xFF2E7D32)),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle("MAIN DRIVER DETAILS"),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  "KA",
                                  style: TextStyle(color: AppColors.designYellow, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Khalid Al-Ameri',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Icon(Icons.star, color: Colors.orange, size: 16),
                                      Text(' 4.9 · Main Driver · 620 trips', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                    ],
                                  ),
                                  const Text(
                                    '2020 Toyota Camry · White',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                _buildMiniCircleButton(Icons.phone, const Color(0xFF2E7D32)),
                                const SizedBox(height: 8),
                                _buildMiniCircleButton(Icons.chat_bubble_rounded, Colors.grey.shade100, iconColor: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_filled, color: Color(0xFF2E7D32), size: 24),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Arriving in approximately",
                                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Text(
                                "4 min",
                                style: TextStyle(color: Color(0xFF2E7D32), fontSize: 32, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // LIVE MAP SECTION
                  const Text(
                    "LIVE TRACKING",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _currentPosition == null
                          ? const Center(child: CircularProgressIndicator())
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                zoom: 14,
                              ),
                              markers: _markers,
                              onMapCreated: (controller) => _mapController = controller,
                              myLocationEnabled: true,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // Current Flow: Simulation
                        Navigator.pushReplacementNamed(context, '/support_driver_inspection');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.location_on, size: 20, color: Colors.pinkAccent),
                          SizedBox(width: 8),
                          Text('Track on Map', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bgColor, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2));
  }

  Widget _buildInfoCard({required Widget child, Color bgColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildMiniCircleButton(IconData icon, Color color, {Color iconColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
