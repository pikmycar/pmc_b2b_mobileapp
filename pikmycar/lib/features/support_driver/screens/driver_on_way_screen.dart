import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';

class DriverOnWayScreen extends StatefulWidget {
  const DriverOnWayScreen({super.key});

  @override
  State<DriverOnWayScreen> createState() => _DriverOnWayScreenState();
}

class _DriverOnWayScreenState extends State<DriverOnWayScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
    
    // Start 30-second timer to navigate to Arrived screen
    _navigationTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/support_driver_arrived');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
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
      _updateMarkers(position);
    });
  }

  void _updateMarkers(Position position) {
    _markers.clear();
    _polylines.clear();
    
    final userLatLng = LatLng(position.latitude, position.longitude);
    final driverLatLng = LatLng(position.latitude + 0.005, position.longitude + 0.005);
    final colorScheme = Theme.of(context).colorScheme;

    // User Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: userLatLng,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Mock Driver Marker (slightly offset)
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: driverLatLng,
        infoWindow: const InfoWindow(title: 'Khalid Al-Ameri'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    // Mock Polyline between User and Driver
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route_to_driver'),
        points: [userLatLng, driverLatLng],
        color: colorScheme.primary,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Driver On Way 🚕',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
                  _buildStatusBadge(context, "🚕 Main Driver Assigned", AppColors.success, textColor: Colors.white),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, "MAIN DRIVER DETAILS"),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context: context,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  "KA",
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Khalid Al-Ameri',
                                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      Expanded(
                                        child: Text(
                                          ' 4.9 · Main Driver · 620 trips',
                                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '2020 Toyota Camry · White',
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                _buildMiniCircleButton(Icons.phone, AppColors.success),
                                const SizedBox(height: 8),
                                _buildMiniCircleButton(Icons.chat_bubble_rounded, colorScheme.primary.withOpacity(0.1), iconColor: colorScheme.primary),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_filled, color: AppColors.success, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Arriving in approximately",
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                "4 min",
                                style: textTheme.headlineMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, "LIVE TRACKING"),
                  const SizedBox(height: 12),
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _currentPosition == null
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
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/support_driver_arrived');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.location_on, size: 20),
                          SizedBox(width: 8),
                          Text('Track on Map'),
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

  Widget _buildStatusBadge(BuildContext context, String text, Color bgColor, {Color textColor = Colors.white}) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title, 
      style: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold, 
        color: colorScheme.onSurface.withOpacity(0.5), 
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({required BuildContext context, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
