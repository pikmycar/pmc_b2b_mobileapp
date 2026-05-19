import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_event.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_state.dart';
import '../../../core/models/trip_models.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/trip_request_bottom_sheet.dart';

import 'widgets/transport_map_widget.dart';
import 'widgets/transport_header_widget.dart';
import 'widgets/transport_metrics_widget.dart';
import 'widgets/transport_bottom_ui_widget.dart';

class MainDriverTransportScreen extends StatefulWidget {
  const MainDriverTransportScreen({super.key});

  @override
  State<MainDriverTransportScreen> createState() => _MainDriverTransportScreenState();
}

class _MainDriverTransportScreenState extends State<MainDriverTransportScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isRequestSheetShown = false;

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
      // Optional: Call cancel API here
      Navigator.pushNamedAndRemoveUntil(context, '/driver_home', (route) => false);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state.status == TripStatus.completed) {
          Navigator.pushReplacementNamed(context, '/main_driver_trip_completion');
        }

        if (state.status == TripStatus.requestReceived && !_isRequestSheetShown) {
          _showTripRequestSheet(context, state.activeTrip!);
        }
        
        if (state.status != TripStatus.requestReceived && _isRequestSheetShown) {
          Navigator.pop(context);
          _isRequestSheetShown = false;
        }

        if (state.activeTrip != null) {
          _updateMapMarkers(state);
        }
      },
      builder: (context, state) {
        final trip = state.activeTrip;
        final bool isTripActive = state.status != TripStatus.searching && state.status != TripStatus.requestReceived;

        return PopScope(
          canPop: !isTripActive,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _onBackPressed(context);
            if (shouldPop && context.mounted) {
              // Navigation handled inside _onBackPressed
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                // Google Map
                TransportMapWidget(
                  markers: _markers,
                  polylines: _polylines,
                  initialPosition: _getInitialPosition(state),
                  onMapCreated: (controller) => _mapController = controller,
                ),

                // Header Overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TransportHeaderWidget(
                    title: _getTitle(state.status),
                    subtitle: state.status == TripStatus.searching ? "Online & Ready" : null,
                    showBackButton: !isTripActive,
                    onBackTap: () async {
                      if (isTripActive) {
                        await _onBackPressed(context);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),

                // Metrics Overlay (Floating)
                if (state.status == TripStatus.navigatingToPickup || state.status == TripStatus.inTrip)
                  const Positioned(
                    top: 120,
                    left: 16,
                    right: 16,
                    child: TransportMetricsWidget(
                      distance: "2.1 km",
                      eta: "6 mins",
                      speed: "58 km/h",
                    ),
                  ),

                // Bottom UI
                if (state.status != TripStatus.requestReceived && trip != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TransportBottomUIWidget(
                      driverName: _getCurrentTarget(trip).name,
                      driverPhoto: _getCurrentTarget(trip).photo ?? "",
                      locationLabel: state.status == TripStatus.inTrip ? "Dropping at" : "Pickup from",
                      locationAddress: state.status == TripStatus.inTrip ? _getCurrentTarget(trip).dropLocation : _getCurrentTarget(trip).pickupLocation,
                      buttonText: _getActionText(state.status),
                      onActionPressed: () => _handleMainAction(context, state, _getCurrentTarget(trip)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  SupportDriver _getCurrentTarget(Trip trip) {
    return trip.supportDrivers.firstWhere(
      (d) => d.id == trip.currentTargetDriverId,
      orElse: () => trip.supportDrivers.first,
    );
  }

  String _getTitle(TripStatus status) {
    if (status == TripStatus.navigatingToPickup) return "Navigating to Pickup";
    if (status == TripStatus.pickupReached) return "Wait for Support Driver";
    if (status == TripStatus.inTrip) return "In Trip";
    return "Searching for trips...";
  }

  void _handleMainAction(BuildContext context, TripState state, SupportDriver driver) {
    if (state.status == TripStatus.navigatingToPickup) {
      context.read<TripBloc>().add(MarkArrivedAtPickup());
    } else if (state.status == TripStatus.pickupReached) {
      context.read<TripBloc>().add(StartTripToCustomer());
    } else if (state.status == TripStatus.inTrip) {
      context.read<TripBloc>().add(MarkDropComplete(driver.id));
    }
  }

  String _getActionText(TripStatus status) {
    switch (status) {
      case TripStatus.navigatingToPickup:
        return "Arrived at Pickup";
      case TripStatus.pickupReached:
        return "Start Trip";
      case TripStatus.inTrip:
        return "Complete Trip";
      default:
        return "Accept Trip";
    }
  }

  LatLng _getInitialPosition(TripState state) {
    LatLng initialPosition = const LatLng(25.1972, 55.2744); // Burj Khalifa
    if (state.activeTrip != null) {
       final currentTarget = state.activeTrip!.supportDrivers.firstWhere(
        (d) => d.id == state.activeTrip!.currentTargetDriverId,
        orElse: () => state.activeTrip!.supportDrivers.first,
      );
      initialPosition = LatLng(currentTarget.pickupLat ?? initialPosition.latitude, 
                               currentTarget.pickupLng ?? initialPosition.longitude);
    }
    return initialPosition;
  }

  void _showTripRequestSheet(BuildContext context, Trip trip) {
    _isRequestSheetShown = true;
    final currentTarget = trip.supportDrivers.firstWhere(
      (d) => d.id == trip.currentTargetDriverId,
      orElse: () => trip.supportDrivers.first,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => TripRequestBottomSheet(
        customerName: currentTarget.name,
        pickupLocation: currentTarget.pickupLocation,
        destinationLocation: currentTarget.dropLocation,
        fare: trip.totalEarnings,
        onAccept: () {
          context.read<TripBloc>().add(AcceptRequest());
        },
        onReject: () {
          context.read<TripBloc>().add(DeclineRequest());
        },
      ),
    ).then((_) => _isRequestSheetShown = false);
  }

  void _updateMapMarkers(TripState state) async {
    final trip = state.activeTrip!;
    final currentTarget = trip.supportDrivers.firstWhere(
      (d) => d.id == trip.currentTargetDriverId,
      orElse: () => trip.supportDrivers.first,
    );

    final Set<Marker> newMarkers = {};
    final Set<Polyline> newPolylines = {};

    if (currentTarget.pickupLat != null && currentTarget.pickupLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(currentTarget.pickupLat!, currentTarget.pickupLng!),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      );
    }

    if (currentTarget.dropLat != null && currentTarget.dropLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: LatLng(currentTarget.dropLat!, currentTarget.dropLng!),
          infoWindow: const InfoWindow(title: 'Drop-off Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Add polyline between pickup and drop
    if (currentTarget.pickupLat != null && currentTarget.dropLat != null) {
      newPolylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(currentTarget.pickupLat!, currentTarget.pickupLng!),
            LatLng(currentTarget.dropLat!, currentTarget.dropLng!),
          ],
          color: AppColors.primary,
          width: 5,
          geodesic: true,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
        _polylines.clear();
        _polylines.addAll(newPolylines);
      });
    }

    // Zoom to fit bounds
    if (_mapController != null && newMarkers.isNotEmpty) {
      final bounds = _calculateBounds(newMarkers);
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
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
