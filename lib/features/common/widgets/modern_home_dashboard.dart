import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_theme.dart';
import 'custom_top_header_bar.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_event.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_state.dart';
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

  bool _hasAnimatedToUser = false;
  bool _isLocationStarted = false;

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

  @override
  void didUpdateWidget(covariant ModernHomeDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOnline && !oldWidget.isOnline) {
      _initLocation();
      _loadSimulation();
    }

    if (!widget.isOnline && oldWidget.isOnline) {
      _positionStream?.cancel();
      _positionStream = null;
      _isLocationStarted = false;
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

  /// 🔥 MANUAL + AUTO MOVE FUNCTION
  Future<void> _moveToCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (!mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;

        _markers.removeWhere((m) => m.markerId.value == 'driver');
        _markers.add(
          Marker(markerId: const MarkerId('driver'), position: latLng),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
    } catch (e) {
      print("Location error: $e");
    }
  }

  /// 🔥 LOCATION STREAM
  Future<void> _initLocation() async {
    if (_isLocationStarted) return;

    _isLocationStarted = true;

    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    _positionStream?.cancel();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (!mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;

        _markers.removeWhere((m) => m.markerId.value == 'driver');
        _markers.add(
          Marker(markerId: const MarkerId('driver'), position: latLng),
        );
      });

      /// 🔥 AUTO MOVE AFTER 2 SEC (ONLY FIRST TIME)
      if (!_hasAnimatedToUser) {
        _hasAnimatedToUser = true;

        Future.delayed(const Duration(seconds: 2), () {
          _moveToCurrentLocation();
        });
      }
    });
  }

  Future<void> _loadRole() async {
    final storage = context.read<SecureStorageService>();
    final roleStr = await storage.getUserRole();

    final role =
        (roleStr == "support_driver" ||
                roleStr == UserRole.supportDriver.toString())
            ? UserRole.supportDriver
            : UserRole.mainDriver;

    if (!mounted) return;

    setState(() {
      _role = role;
    });

    if (widget.isOnline) {
      _loadSimulation();
    }
  }

  void _loadSimulation() {
    if (_role == UserRole.mainDriver) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;

        final state = context.read<TripBloc>().state;

        if (state.status == TripStatus.searching) {
          context.read<TripBloc>().add(SimulateRequest());
        }
      });
    } else {
      _simulateIncomingTrip();
    }
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
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state.status == TripStatus.accepted ||
            state.status == TripStatus.navigatingToPickup ||
            state.status == TripStatus.pickupReached ||
            state.status == TripStatus.inTrip) {
          Navigator.pushReplacementNamed(
            context,
            '/main_driver_transport',
          );
        }
      },
      builder: (context, state) {
        final isMainDriverPopupVisible = state.status == TripStatus.requestReceived &&
            state.activeTrip != null &&
            _role == UserRole.mainDriver &&
            state.activeTrip!.supportDrivers.isNotEmpty;

        final isSupportPopupVisible = _showTripPopup &&
            _tripData != null &&
            _role == UserRole.supportDriver;

        final isPopupVisible = isMainDriverPopupVisible || isSupportPopupVisible;

        return WillPopScope(
          onWillPop: () async => !isPopupVisible,
          child: Stack(
            children: [
              Scaffold(
                appBar: CustomTopHeaderBar(
                  isOnline: widget.isOnline,
                  onMenuTap: widget.onMenuTap,
                  onOnlineStatusChanged: widget.onToggleOnline,
                ),
                body: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildMapSection()),
                  ],
                ),
              ),
              if (isPopupVisible) ...[
                // Black background overlay
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {}, // Block taps
                    onVerticalDragDown: (_) {}, // Block vertical swipes
                    onHorizontalDragDown: (_) {}, // Block horizontal swipes
                    child: Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
                // Popup widget layer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Material(
                      type: MaterialType.transparency,
                      child: isMainDriverPopupVisible
                          ? MainDriverRequestPopup(trip: state.activeTrip!)
                          : SupportRequestPopup(
                              tripData: _tripData!,
                              secondsRemaining: _tripSeconds,
                              totalSeconds: 30,
                              isExpanded: _isExpandedRequest,
                              onAccept: () {
                                _closeTrip();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TicketDetailScreen(),
                                  ),
                                );
                              },
                              onDecline: _closeTrip,
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            label: "Today's Earning",
            value: "₹820",
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF10B981), // Emerald/Green
            iconBgColor: const Color(0xFFDCFCE7), // Light green
            onTap: () {
              // Navigate to earnings
            },
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            label: "Trips",
            value: "31",
            icon: Icons.directions_car,
            iconColor: const Color(0xFF3B82F6), // Blue
            iconBgColor: const Color(0xFFDBEAFE), // Light blue
            onTap: () {
              Navigator.pushNamed(context, '/trip_history');
            },
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            label: "Rating",
            value: "4.9",
            icon: Icons.star,
            iconColor: const Color(0xFFF59E0B), // Amber/Orange
            iconBgColor: const Color(0xFFFEF3C7), // Light amber
            onTap: () {
              // Navigate to ratings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
                blurRadius: 10,
                spreadRadius: isDark ? 0.5 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? iconColor.withOpacity(0.2) : iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurface.withOpacity(0.3),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    const LatLng defaultLocation = LatLng(13.0827, 80.2707);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 15,
            spreadRadius: isDark ? 0.5 : 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;

                if (widget.isOnline && !_isLocationStarted) {
                  _initLocation();
                }
              },
              style: isDark ? _darkMapStyle : null,
              initialCameraPosition: CameraPosition(
                target:
                    _currentPosition != null
                        ? LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                        : defaultLocation,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
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
                  final isSearching = state.status == TripStatus.searching;
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        // Pulsing Green Radar Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        // Text Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isSearching ? "Searching for trips..." : "Trip in progress...",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSearching
                                    ? "We'll notify you when a new trip is available."
                                    : "Active navigation in progress.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Small Green Active Dot on right
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          /// 🔥 MANUAL BUTTON (Floating above overlay)
          Positioned(
            bottom: widget.isOnline && _role == UserRole.mainDriver ? 105 : 20,
            right: 20,
            child: GestureDetector(
              onTap: _moveToCurrentLocation,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location, color: Colors.black87, size: 20),
              ),
            ),
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
