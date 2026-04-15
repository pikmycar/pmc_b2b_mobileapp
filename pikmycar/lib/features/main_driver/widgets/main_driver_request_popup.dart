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
        context.read<TripBloc>().add(DeclineRequest());
      } else {
        setState(() {
          secondsLeft--;
        });
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
    final trip = widget.trip;

    if (trip.supportDrivers.isEmpty) return const SizedBox.shrink();
    final driver = trip.supportDrivers.first;

    double progress = secondsLeft / 45;

    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.designYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "PICK ME REQUEST",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),

                // 🔥 TIMER UI
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: progress,
                        color: AppColors.success,
                        strokeWidth: 3,
                      ),
                    ),
                    Text(
                      "$secondsLeft",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "New Trip Found!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 24),

            // DRIVER INFO
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.designYellow,
                  child: Text(
                    driver.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    driver.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            _locationItem(
                Colors.pink, "Pickup point", driver.pickupLocation),
            const SizedBox(height: 16),
            _locationItem(
                Colors.cyan, "Drop-off location", driver.dropLocation),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metricBox("${driver.distance}km", "Distance"),
                _metricBox(driver.eta, "ETA"),
                _metricBox("${driver.seatsRequired}", "Seats",
                    isGreen: true),
              ],
            ),

            const SizedBox(height: 32),

            // ACTIONS
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      timer?.cancel();
                      context.read<TripBloc>().add(DeclineRequest());
                    },
                    child: const Text(
                      "Decline",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.designYellow,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      timer?.cancel();
                      context.read<TripBloc>().add(AcceptRequest());
                    },
                    child: const Text("Accept"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _locationItem(Color color, String label, String address) {
    return Row(
      children: [
        Icon(Icons.location_on, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(address)),
      ],
    );
  }

  Widget _metricBox(String val, String label, {bool isGreen = false}) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: isGreen ? AppColors.success : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}