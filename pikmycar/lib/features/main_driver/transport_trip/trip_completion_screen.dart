import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/trip_bloc.dart';
import 'bloc/trip_event.dart';
import 'bloc/trip_state.dart';

class TripCompletionScreen extends StatelessWidget {
  const TripCompletionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        final trip = state.activeTrip;
        final driverName =
            trip?.supportDrivers.first.name ?? "Abdul Rahman";
        final earningsStr = trip != null
            ? "AED ${trip.totalEarnings.toInt()}"
            : "AED 45";

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Trip Summary',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Divider(
                    color: Colors.black12,
                    height: 40,
                  ),

                  const Spacer(),

                  // Success Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFC107).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_box,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Pick Me Completed!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Support driver dropped at customer location successfully',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _summaryRow('Trip', '#PKM-2847'),
                        const SizedBox(height: 12),
                        _summaryRow('Support Driver', driverName),
                        const SizedBox(height: 12),
                        _summaryRow('Distance', '7.1 km'),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Earnings',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              earningsStr,
                              style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        context
                            .read<TripBloc>()
                            .add(ResetToSearching());

                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                          '/main_driver_dashboard',
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}