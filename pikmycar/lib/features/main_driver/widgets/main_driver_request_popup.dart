import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../transport_trip/bloc/trip_bloc.dart';
import '../transport_trip/bloc/trip_event.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/theme/app_theme.dart';

class MainDriverRequestPopup extends StatefulWidget {
  final Trip trip;

  const MainDriverRequestPopup({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  State<MainDriverRequestPopup> createState() => _MainDriverRequestPopupState();
}

class _MainDriverRequestPopupState extends State<MainDriverRequestPopup> {
  int secondsLeft = 45;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
        // Auto decline when time ends
        if (mounted) {
          context.read<TripBloc>().add(DeclineRequest());
        }
      } else {
        if (mounted) {
          setState(() {
            secondsLeft--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final trip = widget.trip;

    if (trip.supportDrivers.isEmpty) return const SizedBox.shrink();
    final driver = trip.supportDrivers.first;

    double progress = secondsLeft / 45;

    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.12 : 0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      "PICK ME REQUEST",
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  // TIMER UI
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: progress,
                          color: colorScheme.secondary,
                          backgroundColor: colorScheme.secondary.withOpacity(0.1),
                          strokeWidth: 3.5,
                        ),
                      ),
                      Text(
                        "$secondsLeft",
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "New Trip Found!",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              // DRIVER INFO
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        driver.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            "Support Driver",
                            style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _locationItem(context, colorScheme.primary, "Pickup", driver.pickupLocation),
              const SizedBox(height: 16),
              _locationItem(context, colorScheme.error, "Destination", driver.dropLocation),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metricBox(context, "${driver.distance} km", "Distance"),
                    _metricBox(context, driver.eta, "ETA"),
                    _metricBox(context, "${driver.seatsRequired}", "Seats", isAccent: true),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ACTIONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        timer?.cancel();
                        context.read<TripBloc>().add(DeclineRequest());
                      },
                      child: const Text("DECLINE"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                      ),
                      onPressed: () {
                        timer?.cancel();
                        context.read<TripBloc>().add(AcceptRequest());
                      },
                      child: const Text("ACCEPT"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationItem(BuildContext context, Color color, String label, String address) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                address, 
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricBox(BuildContext context, String val, String label, {bool isAccent = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          val,
          style: textTheme.titleMedium?.copyWith(
            color: isAccent ? colorScheme.secondary : colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}