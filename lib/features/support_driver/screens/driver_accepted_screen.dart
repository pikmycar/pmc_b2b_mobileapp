import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/getTrip_mainDriver_status.dart';
import 'driver_on_way_screen.dart';

class DriverAcceptedScreen extends StatefulWidget {
  final GetTripMainDriverStatus? statusDetails;

  const DriverAcceptedScreen({
    super.key,
    this.statusDetails,
  });

  @override
  State<DriverAcceptedScreen> createState() => _DriverAcceptedScreenState();
}

class _DriverAcceptedScreenState extends State<DriverAcceptedScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Auto-navigate to DriverOnWayScreen after 30 seconds
    _navigationTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverOnWayScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

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
      Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Resolve driver details from status API response or use fallback defaults
    final info = GetTripMainDriverStatusHelper.resolveDriverInfo(widget.statusDetails);

    final String driverName = info['name'];
    final String driverPhone = info['phone'];
    final String driverAvatar = info['avatar'];
    final String driverRating = info['rating'];
    final String vehicleType = info['vehicleType'];
    final String vehicleNumber = info['vehicleNumber'];
    final String eta = info['eta'];
    final String pickupLocation = info['pickupLocation'];
    final String tripStatus = info['status'];

    final String displayInitial = driverName.isNotEmpty 
        ? (driverName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase())
        : "KA";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Driver Assigned',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge
              _buildStatusBadge(
                context, 
                "🚕 Driver: ${tripStatus.replaceAll('_', ' ').toUpperCase()}", 
                AppColors.success, 
                textColor: Colors.white,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(context, "MAIN DRIVER DETAILS"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: driverAvatar.isNotEmpty ? NetworkImage(driverAvatar) : null,
                          backgroundColor: colorScheme.primary,
                          child: driverAvatar.isEmpty
                              ? Text(
                                  displayInitial,
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text(
                                    ' $driverRating · Main Driver · $driverPhone', 
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                              Text(
                                '$vehicleType · $vehicleNumber',
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Assigning live tracking... Please wait",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context, "TRIP SUMMARY"),
              const SizedBox(height: 12),
              _buildInfoCard(
                context: context,
                child: Column(
                  children: [
                     _buildLocationRow(context, Icons.location_on, AppColors.error, pickupLocation, "Pickup Location"),
                     const Divider(height: 32),
                     _buildLocationRow(context, Icons.factory_outlined, colorScheme.onSurface.withOpacity(0.5), "Al Quoz Auto Service", "Drop Location"),
                     const Divider(height: 32),
                     _buildLocationRow(context, Icons.access_time_filled, AppColors.success, eta, "Estimated Arrival (ETA)"),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              // Progress Indicator
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Starting live tracking in a few moments",
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String text, Color bgColor, {Color textColor = Colors.white}) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface.withOpacity(0.5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({required BuildContext context, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.premiumCardDecoration(context, borderRadius: 16.0),
      child: child,
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ],
    );
  }
}
