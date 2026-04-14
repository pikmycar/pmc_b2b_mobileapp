import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupportRequestPopup extends StatelessWidget {
  final Map<String, dynamic> tripData;
  final int secondsRemaining;
  final int totalSeconds;
  final bool isExpanded;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const SupportRequestPopup({
    super.key,
    required this.tripData,
    required this.secondsRemaining,
    required this.totalSeconds,
    required this.isExpanded,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 1.0, end: 0.0),
        curve: Curves.easeOutBack,
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, value * 200),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildBadge()),
                  const SizedBox(width: 12),
                  _buildTimerCircle(),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                isExpanded ? "Expanded Area Request" : "New Car Pickup!",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Expansion Message (if applicable)
              if (isExpanded) _buildExpansionMessage(),

              // Locations
              _buildLocationRow(
                icon: Icons.location_on,
                iconColor: Colors.pinkAccent,
                title: tripData['pickup'] ?? 'N/A',
                subtitle: "Pickup Location",
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                icon: Icons.factory_outlined,
                iconColor: Colors.grey,
                title: tripData['drop'] ?? 'N/A',
                subtitle:
                    isExpanded
                        ? "Pickup · ${tripData['distance']} away"
                        : "Garage Drop",
              ),
              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  _buildStatCard(tripData['distance'] ?? '0km', "Distance"),
                  const SizedBox(width: 8),
                  _buildStatCard(tripData['eta'] ?? '0min', "ETA"),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    tripData['priority'] ?? 'LOW',
                    "Priority",
                    valueColor: _getPriorityColor(tripData['priority']),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: "Decline",
                      onPressed: onDecline,
                      isPrimary: false,
                      icon: Icons.close,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: isExpanded ? "Accept" : "Accept Pickup",
                      onPressed: onAccept,
                      isPrimary: true,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isExpanded ? const Color(0xFFFFF7ED) : AppColors.designYellow,
        borderRadius: BorderRadius.circular(20),
        border:
            isExpanded
                ? Border.all(color: Colors.orange.withOpacity(0.3))
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpanded ? Icons.notifications_none : Icons.directions_car,
            size: 16,
            color: isExpanded ? Colors.orange : Colors.black,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "Pickup Request · ${isExpanded ? '10km' : '5km'} Radius",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isExpanded ? Colors.orange : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle() {
    double progress = secondsRemaining / totalSeconds;
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.grey.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isExpanded ? Colors.orange : AppColors.designYellow,
            ),
          ),
          Text(
            "$secondsRemaining",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isExpanded ? Colors.orange : AppColors.designYellow,
              fontFamily: 'Roboto', // Premium feel
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.designYellow.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.satellite_alt, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "No driver accepted in 5km. Request expanded to 10km radius.",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF854D0E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required IconData icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? AppColors.designYellow : Colors.grey.withOpacity(0.05),
        foregroundColor: isPrimary ? Colors.black : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return Colors.redAccent;
      case 'MED':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }
}
