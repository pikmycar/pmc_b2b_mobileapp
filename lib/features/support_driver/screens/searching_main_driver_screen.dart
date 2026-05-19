import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import 'driver_accepted_screen.dart';

class SearchingMainDriverScreen extends StatefulWidget {
  const SearchingMainDriverScreen({super.key});

  @override
  State<SearchingMainDriverScreen> createState() => _SearchingMainDriverScreenState();
}

class _SearchingMainDriverScreenState extends State<SearchingMainDriverScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  Timer? _searchTimer;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _initLocationTracking();

    _searchTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverAcceptedScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _searchTimer?.cancel();
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
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );
    });
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Searching for Driver...',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Radar Section
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // LIVE MAP BACKGROUND
                    if (_currentPosition != null)
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 15,
                        ),
                        markers: _markers,
                        onMapCreated: (controller) => _mapController = controller,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      )
                    else
                      Center(child: CircularProgressIndicator(color: colorScheme.primary)),

                    // RADAR RIPPLE OVERLAY
                    IgnorePointer(
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ...List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _radarController,
                                builder: (context, child) {
                                  double progress = (_radarController.value + index / 3) % 1.0;
                                  return Container(
                                    width: progress * 600,
                                    height: progress * 600,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.primary.withOpacity((1 - progress) * 0.5),
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    
                    // Pulse Center
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.my_location, color: colorScheme.onPrimary, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // Details Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(context, "Pickup Accepted", AppColors.success),
                    const SizedBox(height: 16),
                    Text(
                      "Searching for Main Driver...",
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connecting you with a nearby driver for your pickup.",
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, "TRIP DETAILS"),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context: context,
                      child: Column(
                        children: [
                          _buildDetailRow(context, Icons.my_location, colorScheme.primary, "Your Location", "Support Driver Location"),
                          const Divider(height: 24),
                          _buildDetailRow(context, Icons.person, colorScheme.secondary, "Ahmed Al-Rashid", "Customer · +971 50 123 4567"),
                          const Divider(height: 24),
                          _buildLocationRow(context, Icons.location_on, AppColors.error, "Dubai Marina, Tower B", "Pickup · Today 10:30 AM"),
                          const SizedBox(height: 12),
                          _buildLocationRow(context, Icons.factory_outlined, colorScheme.onSurface.withOpacity(0.5), "Al Quoz Auto Service", "Drop-off"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, "CAR DETAILS"),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context: context,
                      bgColor: colorScheme.primary.withOpacity(0.05),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car, color: AppColors.error, size: 36),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("BMW 3 Series · Blue", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                Text("M72528 · 2022", style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
                              ],
                            ),
                          ),
                          _buildPlateBox(context, "M72528"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatusBox(
                      context: context,
                      emoji: "⏳",
                      text: "Pick Me request sent! Waiting for a Main Driver to confirm and pick you up from your location",
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildActionButton(context, "Call Customer", Icons.phone)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionButton(context, "Message", Icons.message)),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String text, Color bgColor) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildInfoCard({required BuildContext context, required Widget child, Color? bgColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle.isNotEmpty) 
              Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle.isNotEmpty) 
              Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ],
    );
  }

  Widget _buildPlateBox(BuildContext context, String plate) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.onSurface, width: 1.5),
      ),
      child: Text(plate, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBox({required BuildContext context, required String emoji, required String text}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(label, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
