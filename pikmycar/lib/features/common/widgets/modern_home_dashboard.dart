import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';

class ModernHomeDashboard extends StatefulWidget {
  final bool isOnline;
  final Function(bool) onToggleOnline;
  final VoidCallback onMenuTap;

  const ModernHomeDashboard({
    super.key,
    required this.isOnline,
    required this.onToggleOnline,
    required this.onMenuTap,
  });

  @override
  State<ModernHomeDashboard> createState() => _ModernHomeDashboardState();
}

class _ModernHomeDashboardState extends State<ModernHomeDashboard> {
  UserRole? _role;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};
  bool _hasLocationError = false;
  String? _errorMessage;

  final String _mapStyle = """
  [
    {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
    {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
    {"elementType": "labels.text.stroke", "stylers": [{"color": "#f5f5f5"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#c9c9c9"}]}
  ]
  """;

  @override
  void initState() {
    super.initState();
    _loadRole();

    // 📍 Start location tracking immediately if we are born in 'Online' state (e.g. from toggle)
    if (widget.isOnline) {
      _initLocation();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Starts location tracking and returns true if authorized/successful
  Future<bool> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    if (!mounted) return false;
    setState(() => _hasLocationError = false);

    try {
      print("📍 GPS: Checking services...");
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("📍 GPS: Location services disabled.");
        _showLocationError("GPS is disabled. Please turn it on.");
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print("📍 GPS: Requesting permissions...");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("📍 GPS: Permission denied.");
          _showLocationError("Location permission denied.");
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("📍 GPS: Permission blocked forever.");
        _showLocationError("Location blocked. Please enable in Settings.");
        return false;
      }

      print("📍 GPS: Authorized. Starting track...");
      _errorMessage = null;

      // 🔄 START STREAM IMMEDIATELY
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen(
        (Position position) {
          print(
            "📍 GPS: Live fix: ${position.latitude}, ${position.longitude}",
          );
          if (mounted) {
            bool isFirstFix = _currentPosition == null;
            setState(() {
              _currentPosition = position;
              _hasLocationError = false;
              _updateMarker(LatLng(position.latitude, position.longitude));
            });

            if (isFirstFix) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(position.latitude, position.longitude),
                  15,
                ),
              );
            }
          }
        },
        onError: (e) {
          print("📍 GPS: Stream error: $e");
          if (mounted) setState(() => _hasLocationError = true);
        },
      );

      // Also try a quick one-time fetch to speed things up
      final fastPosition = await Geolocator.getLastKnownPosition();
      if (fastPosition != null && mounted && _currentPosition == null) {
        setState(() {
          _currentPosition = fastPosition;
          _updateMarker(LatLng(fastPosition.latitude, fastPosition.longitude));
        });
      }
      return true;
    } catch (e) {
      print("📍 GPS: Error: $e");
      return false;
    }
  }

  /// High-level handler for toggling online status with permission checks
  Future<void> _handleToggleOnline(bool targetOnline) async {
    if (targetOnline) {
      // 📍 GOING ONLINE: We need GPS
      final success = await _initLocation();
      if (success) {
        widget.onToggleOnline(true);
      }
    } else {
      // 📍 GOING OFFLINE: Stop tracking
      await _positionStream?.cancel();
      _positionStream = null;
      if (mounted) {
        setState(() {
          _currentPosition = null;
          _hasLocationError = false;
        });
      }
      widget.onToggleOnline(false);
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _hasLocationError = true;
      _errorMessage = message;
    });
    // ✅ Only show Snackbar if user is actively Online
    if (widget.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: "Fix",
            onPressed: () async {
              await Geolocator.openLocationSettings();
              _initLocation();
            },
          ),
        ),
      );
    }
  }

  void _setFallbackLocation() {
    // 🔥 NO LONGER USING SILENT FALLBACK TO DUBAI
    // Map will show a loading indicator or 'Enable GPS' prompt instead
  }

  void _updateMarker(LatLng position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('driver_car'),
        position: position,
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  Future<void> _loadRole() async {
    final storage = context.read<SecureStorageService>();
    final roleStr = await storage.getUserRole();
    if (mounted) {
      setState(() {
        if (roleStr == UserRole.supportDriver.toString()) {
          _role = UserRole.supportDriver;
        } else {
          _role = UserRole.mainDriver;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Container(
            color: AppColors.designSurface,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildMapSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.designForestGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              GestureDetector(
                onTap: widget.onMenuTap,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.designYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "AR",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User Info (Expanded to take available space)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hello,",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Abdul",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          const Text("👋 ", style: TextStyle(fontSize: 16)),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isOnline ? "Online •" : "Offline",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          if (widget.isOnline) ...[
                            const SizedBox(width: 4),
                            const Text(
                              "Ready to accept",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Toggle Button
              GestureDetector(
                onTap: () => _handleToggleOnline(!widget.isOnline),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.isOnline ? "Go Offline" : "Go Online",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildEarningsCard(),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.designDarkGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.payments, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Today's",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    "Earnings",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: const [
              Text(
                "AED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "320",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard("8", "Today"),
          const SizedBox(width: 8),
          _buildStatCard("31", "This Week"),
          const SizedBox(width: 8),
          _buildStatCard("4.9", "Rating", showStar: true),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, {bool showStar = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.designDarkGreen,
                  ),
                ),
                if (showStar) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 22),
                ],
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child:
                _hasLocationError
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Icon(Icons.location_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _errorMessage ?? "Location access required",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initLocation,
                            child: const Text("Retry GPS"),
                          ),
                        ],
                      ),
                    )
                    : _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      key: const ValueKey('google_map_dashboard'),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        print("🗺️ Map Created Successfully");
                        _mapController = controller;
                        _mapController!.setMapStyle(_mapStyle);
                      },
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
          ),
          // You're here label (Keep overlay)
          Positioned(
            top: 40,
            left: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: const Text(
                "You're here",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          // Search Badge
          if (widget.isOnline)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    const Text("🎯", style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _role == UserRole.mainDriver
                            ? "Searching for Support Driver requests..."
                            : "Searching for customer trips...",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
