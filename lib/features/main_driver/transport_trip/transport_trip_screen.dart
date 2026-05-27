import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_bloc.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_event.dart';
import '../../auth/bloc/commonScreen/driver_location/trip_state.dart';
import '../../../core/models/trip_models.dart';
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
      Navigator.pushNamedAndRemoveUntil(context, '/driver_home', (route) => false);
      return true;
    }
    return false;
  }

  SupportDriver _getCurrentTarget(Trip trip) {
    final N = trip.supportDrivers.length;
    int index = trip.currentStep ~/ 2;
    if (index >= N) {
      index = N - 1;
    }
    if (index < 0) index = 0;
    return trip.supportDrivers[index];
  }

  LatLng? _getPickupLatLng(TripState state) {
    if (state.activeTrip == null) return null;
    final currentTarget = _getCurrentTarget(state.activeTrip!);
    if (currentTarget.pickupLat == null || currentTarget.pickupLng == null) return null;
    return LatLng(currentTarget.pickupLat!, currentTarget.pickupLng!);
  }

  LatLng? _getDropLatLng(TripState state) {
    if (state.activeTrip == null) return null;
    final currentTarget = _getCurrentTarget(state.activeTrip!);
    if (currentTarget.dropLat == null || currentTarget.dropLng == null) return null;
    return LatLng(currentTarget.dropLat!, currentTarget.dropLng!);
  }

  String _calculateArrivalTime(String? eta) {
    if (eta == null) return "--:--";
    final match = RegExp(r'(\d+)').firstMatch(eta);
    if (match == null) return "--:--";
    final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
    final arrivalTime = DateTime.now().add(Duration(minutes: minutes));
    
    final hour = arrivalTime.hour > 12 
        ? arrivalTime.hour - 12 
        : (arrivalTime.hour == 0 ? 12 : arrivalTime.hour);
    final minuteStr = arrivalTime.minute.toString().padLeft(2, '0');
    final period = arrivalTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minuteStr $period";
  }

  String _getTitle(TripStatus status) {
    if (status == TripStatus.accepted) return "Navigating to Pickup";
    if (status == TripStatus.support_driver_pickup) return "In Trip to Destination";
    if (status == TripStatus.support_driver_drop) return "Navigating to Next Step";
    if (status == TripStatus.completed) return "Trip Completed";
    return "Searching for trips...";
  }

  void _handleMainAction(BuildContext context, TripState state) {
    context.read<TripBloc>().add(NextTripStep());
  }

  String _getActionText(TripState state) {
    final trip = state.activeTrip;
    if (trip == null) return "Accept Trip";
    final N = trip.supportDrivers.length;
    final step = trip.currentStep;
    final index = step ~/ 2;

    if (step >= 2 * N) {
      return "Completed";
    }

    if (step % 2 == 0) {
      return N > 1 ? "Support Driver Pickup ${index + 1}" : "Support Driver Pickup";
    } else {
      return N > 1 ? "Support Driver Drop ${index + 1}" : "Support Driver Drop";
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripBloc, TripState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.activeTrip != current.activeTrip ||
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.status == TripStatus.completed) {
          Navigator.pushReplacementNamed(context, '/main_driver_trip_completion');
        }

        if (state.status == TripStatus.cancelled) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Trip Cancelled"),
              content: const Text("This trip has been cancelled."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<TripBloc>().add(ResetToSearching());
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/driver_home',
                      (route) => false,
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }

        if (state.status == TripStatus.requestReceived && !_isRequestSheetShown) {
          _showTripRequestSheet(context, state.activeTrip!);
        }

        if (state.status != TripStatus.requestReceived && _isRequestSheetShown) {
          Navigator.pop(context);
          _isRequestSheetShown = false;
        }
      },
      builder: (context, state) {
        final trip = state.activeTrip;
        final bool isTripActive = state.status != TripStatus.searching &&
            state.status != TripStatus.requestReceived;

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
                // High performance Google Map wrapper with scoped rebuilds
                BlocBuilder<TripBloc, TripState>(
                  buildWhen: (previous, current) =>
                      previous.currentLatitude != current.currentLatitude ||
                      previous.currentLongitude != current.currentLongitude ||
                      previous.currentHeading != current.currentHeading ||
                      previous.routePoints != current.routePoints,
                  builder: (context, mapState) {
                    final driverPos = mapState.currentLatitude != null &&
                            mapState.currentLongitude != null
                        ? LatLng(mapState.currentLatitude!, mapState.currentLongitude!)
                        : null;
                    return TransportMapWidget(
                      driverPosition: driverPos,
                      driverHeading: mapState.currentHeading,
                      pickupPosition: _getPickupLatLng(mapState),
                      dropPosition: _getDropLatLng(mapState),
                      routePoints: mapState.routePoints,
                      onMapCreated: (controller) => _mapController = controller,
                    );
                  },
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

                // Metrics Overlay (Floating Glassmorphism Card)
                BlocBuilder<TripBloc, TripState>(
                  buildWhen: (previous, current) =>
                      previous.distanceRemaining != current.distanceRemaining ||
                      previous.eta != current.eta ||
                      previous.status != current.status,
                  builder: (context, metricState) {
                    final isMetricActive = metricState.status == TripStatus.accepted ||
                        metricState.status == TripStatus.support_driver_pickup ||
                        metricState.status == TripStatus.support_driver_drop;
                    if (!isMetricActive) return const SizedBox.shrink();

                    return Positioned(
                      top: 120,
                      left: 16,
                      right: 16,
                      child: TransportMetricsWidget(
                        distance: metricState.distanceRemaining ?? "Calculating...",
                        eta: metricState.eta ?? "Calculating...",
                        arrivalTime: _calculateArrivalTime(metricState.eta),
                      ),
                    );
                  },
                ),

                // Premium Bottom Sheet UI
                if (state.status != TripStatus.requestReceived && trip != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TransportBottomUIWidget(
                      driverName: _getCurrentTarget(trip).name,
                      driverPhoto: _getCurrentTarget(trip).photo ?? "",
                      locationLabel: (trip.currentStep % 2 == 1) ? "Dropping at" : "Pickup from",
                      locationAddress: (trip.currentStep % 2 == 1)
                          ? _getCurrentTarget(trip).dropLocation
                          : _getCurrentTarget(trip).pickupLocation,
                      buttonText: _getActionText(state),
                      onActionPressed: () => _handleMainAction(context, state),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
