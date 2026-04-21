import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';
import 'custom_top_header_bar.dart';
import '../../main_driver/transport_trip/bloc/trip_bloc.dart';
import '../../main_driver/transport_trip/bloc/trip_event.dart';
import '../../main_driver/transport_trip/bloc/trip_state.dart';
import '../../../core/models/trip_models.dart';
import '../../support_driver/widgets/support_request_popup.dart';
import '../../support_driver/screens/ticket_detail_screen.dart';
import '../../main_driver/widgets/main_driver_request_popup.dart';

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

  bool _showTripPopup = false;
  Map<String, dynamic>? _tripData;
  Timer? _tripTimer;
  int _tripSeconds = 30;
  bool _isExpandedRequest = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween(begin: 0.9, end: 1.15).animate(_pulseController);

    _loadRole();

    if (widget.isOnline) {
      _initLocation();
    }
  }

  void _loadSimulation() {
     if (_role == UserRole.mainDriver) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && context.read<TripBloc>().state.status == TripStatus.searching) {
            context.read<TripBloc>().add(SimulateRequest());
          }
        });
      } else {
        _simulateIncomingTrip();
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

  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream().listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _markers.clear();
        _markers.add(Marker(markerId: const MarkerId('driver'), position: LatLng(position.latitude, position.longitude)));
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

    if (widget.isOnline) _loadSimulation();
  });
}
  void _simulateIncomingTrip() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !widget.isOnline) return;
      setState(() {
        _isExpandedRequest = false;
        _tripData = {
          "pickup": "Dubai Marina, Tower B",
          "drop": "Al Quoz Auto Center",
          "distance": "3.2km",
          "eta": "12min",
          "priority": "HIGH",
        };
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
        if (_tripSeconds <= 0) _closeTrip();
      });
    });
  }

  void _closeTrip() {
    setState(() {
      _showTripPopup = false;
      _tripData = null;
    });
  }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: _currentPosition == null 
              ? const Center(child: CircularProgressIndicator()) 
              : GoogleMap(
                  style: isDark ? _darkMapStyle : null,
                  initialCameraPosition: CameraPosition(target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 15),
                  markers: _markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
          ),
          /// 🔥 SEARCH STATUS (FOR MAIN DRIVER)
          if (widget.isOnline && _role == UserRole.mainDriver)
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: BlocBuilder<TripBloc, TripState>(
              builder: (context, state) {
                return Material(
                  color: colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ScaleTransition(scale: _pulseAnimation, child: const Text("🎯")),
                        const SizedBox(width: 10),
                        Text(state.status == TripStatus.searching ? "Searching for trips..." : "Trip in progress...", 
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          /// 🔥 TRIP POPUPS
          BlocConsumer<TripBloc, TripState>(
            listener: (context, state) {
              if (state.status == TripStatus.accepted || 
                  state.status == TripStatus.navigatingToPickup ||
                  state.status == TripStatus.pickupReached ||
                  state.status == TripStatus.inTrip) {
                Navigator.pushReplacementNamed(context, '/main_driver_transport');
              }
            },
            builder: (context, state) {
              if (state.status == TripStatus.requestReceived && state.activeTrip != null && _role == UserRole.mainDriver) {
                final driversCount = state.activeTrip!.supportDrivers.length;
                if (driversCount > 0) {
                  return MainDriverRequestPopup(trip: state.activeTrip!);
                }
              }
              // Support driver specific popup
              if (_showTripPopup && _tripData != null && _role == UserRole.supportDriver) {
                 return SupportRequestPopup(
                   tripData: _tripData!,
                   secondsRemaining: _tripSeconds,
                   totalSeconds: 30,
                   isExpanded: _isExpandedRequest,
                   onAccept: () {
                     _closeTrip();
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketDetailScreen()));
                   },
                   onDecline: _closeTrip,
                 );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

}
