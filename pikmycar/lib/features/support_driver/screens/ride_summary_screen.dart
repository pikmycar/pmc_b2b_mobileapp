import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RideSummaryScreen extends StatefulWidget {
  const RideSummaryScreen({Key? key}) : super(key: key);

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _doneBadgeController;

  @override
  void initState() {
    super.initState();
    _doneBadgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _doneBadgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.designForestGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ride Summary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildDoneBadge(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Success Icon
            _buildSuccessIcon(),
            const SizedBox(height: 32),
            
            // Completion Titles
            const Text(
              "Ride\nCompleted!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.0,
                fontFamily: 'Roboto',
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Car delivered to garage.\nStatus: At Garage – Service In Progress",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 16, height: 1.4),
            ),
            
            const SizedBox(height: 48),

            // Trip Summary Card
            _buildTripDetailsCard(),
            
            const SizedBox(height: 32),
            
            // Availability Status
            _buildAvailabilityFooter(),
            
            const SizedBox(height: 40),

            // Final Action
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.designForestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 12),
                    Text("Back to Home", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneBadge() {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1).animate(_doneBadgeController),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: const [
            Text("DONE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.check, color: Colors.greenAccent, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: AppColors.designForestGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 60),
        ),
      ],
    );
  }

  Widget _buildTripDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        children: [
          _buildDetailRow("Trip #", "#PKM-2847", isBold: true),
          _buildDetailRow("Customer", "Ahmed Al-Rashid"),
          _buildDetailRow("Car", "BMW · M72528"),
          _buildDetailRow("Distance", "12.4 km"),
          _buildDetailRow("Duration", "38 mins"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.black12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Earnings", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              _buildAnimatedEarnings(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAnimatedEarnings() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 85),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          "AED ${value.toInt()}",
          style: const TextStyle(
            color: AppColors.designForestGreen,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            letterSpacing: -1,
          ),
        );
      },
    );
  }

  Widget _buildAvailabilityFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.designMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: AppColors.designForestGreen, size: 20),
          SizedBox(width: 8),
          Text(
            "Status: Now Available for next trip",
            style: TextStyle(color: AppColors.designForestGreen, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
