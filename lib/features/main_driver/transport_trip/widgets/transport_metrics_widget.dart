import 'dart:ui';
import 'package:flutter/material.dart';

class TransportMetricsWidget extends StatelessWidget {
  final String distance;
  final String eta;
  final String arrivalTime;

  const TransportMetricsWidget({
    super.key,
    required this.distance,
    required this.eta,
    required this.arrivalTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricItem(
                context,
                Icons.navigation_outlined,
                distance,
                "Distance",
                const Color(0xFF2196F3),
              ),
              Container(
                width: 1.5,
                height: 32,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
              ),
              _metricItem(
                context,
                Icons.timer_outlined,
                eta,
                "ETA",
                const Color(0xFF4CAF50),
              ),
              Container(
                width: 1.5,
                height: 32,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
              ),
              _metricItem(
                context,
                Icons.schedule_outlined,
                arrivalTime,
                "Arrival",
                const Color(0xFFFF9800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: (isDark ? Colors.white70 : Colors.black54).withOpacity(0.6),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
