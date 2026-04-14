import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';
import '../screens/triprequest_screen.dart';
import 'custom_top_header_bar.dart';
import '../../support_driver/widgets/support_request_popup.dart';
import '../../support_driver/screens/ticket_detail_screen.dart';

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

class _ModernHomeDashboardState extends State<ModernHomeDashboard>
    with SingleTickerProviderStateMixin {
  UserRole? _role;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  final Set<Marker> _markers = {};

  /// 🔥 TRIP POPUP
  bool _showTripPopup = false;
  Map<String, dynamic>? _tripData;
  Timer? _tripTimer;
  int _tripSeconds = 30;
  bool _isExpandedRequest = false;

  /// 🔥 ANIMATION
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween(begin: 0.9, end: 1.15).animate(_pulseController);

    _loadRole();

    if (widget.isOnline) {
      _initLocation();
      _simulateIncomingTrip(); // 🔥 AUTO RIDE
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionStream?.cancel();
    _mapController?.dispose();
    _tripTimer?.cancel();
    super.dispose();
  }

  /// ================= LOCATION =================

  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream().listen((position) {
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: LatLng(position.latitude, position.longitude),
          ),
        );
      });
    });
  }

  Future<void> _loadRole() async {
    final storage = context.read<SecureStorageService>();
    final roleStr = await storage.getUserRole();

    setState(() {
      _role = roleStr == UserRole.supportDriver.toString()
          ? UserRole.supportDriver
          : UserRole.mainDriver;
    });
  }

  /// ================= TRIP =================

  void _simulateIncomingTrip() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !widget.isOnline) return;

      setState(() {
        _isExpandedRequest = false;
        if (_role == UserRole.supportDriver) {
          _tripData = {
            "pickup": "Dubai Marina, Tower B",
            "drop": "Al Quoz Auto Center",
            "distance": "3.2km",
            "eta": "12min",
            "priority": "HIGH",
          };
        } else {
          _tripData = {
            "pickup": "Triplicane",
            "drop": "T Nagar",
            "name": "Rahul",
            "rating": "4.6",
            "fare": "₹240"
          };
        }
        _showTripPopup = true;
      });

      _startTripTimer();
    });
  }

  void _startTripTimer() {
    _tripTimer?.cancel();
    _tripSeconds = 30;

    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _tripSeconds--;

        if (_tripSeconds <= 0) {
          // If first phase (5km) is finished, expand to 10km phase
          if (_role == UserRole.supportDriver && !_isExpandedRequest) {
            _isExpandedRequest = true;
            _tripSeconds = 30; // Reset timer for the expanded phase
            _tripData = {
              "pickup": "Jumeirah Beach Road, Villa 12",
              "drop": "Al Quoz Auto Center",
              "distance": "8.1km",
              "eta": "22min",
              "priority": "MED",
            };
          } else {
            // If already expanded or not Support Driver, close the popup
            _closeTrip();
          }
        }
      });
    });
  }

  void _acceptTrip() {
    _tripTimer?.cancel();
    _closeTrip();

    if (_role == UserRole.supportDriver) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TicketDetailScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trip Accepted ✅")),
      );
    }
  }

  void _rejectTrip() {
    _tripTimer?.cancel();
    _closeTrip();
  }

  void _closeTrip() {
    setState(() {
      _showTripPopup = false;
      _tripData = null;
    });
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopHeaderBar(
        isOnline: widget.isOnline,
        onMenuTap: widget.onMenuTap,
        onOnlineStatusChanged: widget.onToggleOnline,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildStatsRow(),
          const SizedBox(height: 12),
          Expanded(child: _buildMapSection()),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _card("₹820", "Today"),
          const SizedBox(width: 8),
          _card("31", "Trips"),
          const SizedBox(width: 8),
          _card("4.9", "Rating"),
        ],
      ),
    );
  }

  Widget _card(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                  ),
          ),

          /// 🔥 SEARCH BAR
          if (widget.isOnline)
          Positioned(
  bottom: 15,
  left: 15,
  right: 15,
  child: Material(
    borderRadius: BorderRadius.circular(20),
    elevation: 4,

    /// 🔥 ADD CLICK HERE
    child: InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TripRequestScreen(),
          ),
        );
      },

      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: const Text("🎯"),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Searching for trips...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    ),
  ),
),
          /// 🔥 TRIP POPUPS
          if (_showTripPopup && _tripData != null)
             _role == UserRole.supportDriver 
                ? SupportRequestPopup(
                    tripData: _tripData!,
                    secondsRemaining: _tripSeconds,
                    totalSeconds: 30,
                    isExpanded: _isExpandedRequest,
                    onAccept: _acceptTrip,
                    onDecline: _rejectTrip,
                  )
                : _buildTripPopup(),
        ],
      ),
    );
  }

  Widget _buildTripPopup() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 100.0, end: 0.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: Material(
          borderRadius: BorderRadius.circular(24),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("New Ride Request",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$_tripSeconds s",
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 10),

                Text(_tripData!["pickup"]),
                Text(_tripData!["drop"]),

                const SizedBox(height: 10),

                Text(_tripData!["name"]),
                Text("⭐ ${_tripData!["rating"]}"),

                Text(_tripData!["fare"],
                    style: TextStyle(
                        color: AppColors.designForestGreen,
                        fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _rejectTrip,
                        child: const Text("Reject"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _acceptTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.designForestGreen,
                        ),
                        child: const Text("Accept"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}