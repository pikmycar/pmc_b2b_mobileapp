import 'package:flutter/material.dart';
import '../bloc/trip_state.dart';
import '../../../../core/models/trip_models.dart';

class TransportHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBackTap;

  const TransportHeaderWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.onBackTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: onBackTap,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
