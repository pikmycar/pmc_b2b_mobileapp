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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.15 : 0.4),
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
                  Expanded(child: _buildBadge(context)),
                  const SizedBox(width: 12),
                  _buildTimerCircle(context),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                isExpanded ? "Expanded Area Request" : "New Car Pickup!",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Expansion Message (if applicable)
              if (isExpanded) _buildExpansionMessage(context),

              // Locations
              _buildLocationRow(
                context,
                icon: Icons.location_on,
                iconColor: colorScheme.primary,
                title: tripData['pickup'] ?? 'N/A',
                subtitle: "Pickup Location",
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                context,
                icon: Icons.factory_outlined,
                iconColor: colorScheme.onSurface.withOpacity(0.4),
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
                  _buildStatCard(context, tripData['distance'] ?? '0km', "Distance"),
                  const SizedBox(width: 8),
                  _buildStatCard(context, tripData['eta'] ?? '0min', "ETA"),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    tripData['priority'] ?? 'LOW',
                    "Priority",
                    valueColor: _getPriorityColor(context, tripData['priority']),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      child: const Text("Decline"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      child: Text(isExpanded ? "Accept" : "Accept Pickup"),
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

  Widget _buildBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final badgeColor = isExpanded ? colorScheme.error : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpanded ? Icons.notifications_none : Icons.directions_car,
            size: 16,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "Pickup Request · ${isExpanded ? '10km' : '5km'} Radius",
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double progress = secondsRemaining / totalSeconds;
    final timerColor = isExpanded ? colorScheme.error : colorScheme.primary;

    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: colorScheme.onSurface.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
          Text(
            "$secondsRemaining",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: timerColor,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.satellite_alt, color: colorScheme.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "No driver accepted in 5km. Request expanded to 10km radius.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.05),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, {Color? valueColor}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, String? priority) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return colorScheme.error;
      case 'MED':
        return AppColors.info;
      default:
        return AppColors.success;
    }
  }
}
