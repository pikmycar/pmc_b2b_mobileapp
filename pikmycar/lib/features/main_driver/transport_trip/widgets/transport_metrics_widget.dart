import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TransportMetricsWidget extends StatelessWidget {
  final String distance;
  final String eta;
  final String speed;

  const TransportMetricsWidget({
    Key? key,
    required this.distance,
    required this.eta,
    required this.speed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricItem(Icons.navigation_outlined, distance, "Distance"),
          _metricItem(Icons.timer_outlined, eta, "ETA"),
          _metricItem(Icons.speed, speed, "Speed"),
        ],
      ),
    );
  }

  Widget _metricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
