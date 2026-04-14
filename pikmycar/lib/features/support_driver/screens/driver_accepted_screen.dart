import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import 'driver_on_way_screen.dart';

class DriverAcceptedScreen extends StatefulWidget {
  const DriverAcceptedScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Main Driver Assigned',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        backgroundColor: AppColors.designYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge("🚕 Main Driver Accepted!", const Color(0xFFE8F5E9), textColor: const Color(0xFF2E7D32)),
            const SizedBox(height: 24),

            _buildSectionTitle("MAIN DRIVER DETAILS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "KA",
                            style: TextStyle(color: AppColors.designYellow, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Khalid Al-Ameri',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.orange, size: 16),
                                Text(' 4.9 · Main Driver · 620 trips', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            const Text(
                              '2020 Toyota Camry · White',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // CTA for impatient users (optional, but keep it automated as requested)
                  const Text(
                    "Assigning live tracking... Please wait",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("TRIP SUMMARY"),
            const SizedBox(height: 12),
            _buildInfoCard(
              child: Column(
                children: [
                   _buildLocationRow(Icons.location_on, Colors.pink, "Dubai Marina, Tower B", "Pickup Location"),
                   const Divider(height: 32),
                   _buildLocationRow(Icons.factory_outlined, Colors.blueGrey, "Al Quoz Auto Service", "Drop Location"),
                   const Divider(height: 32),
                   _buildLocationRow(Icons.access_time_filled, const Color(0xFF2E7D32), "4 Minutes", "Estimated Arrival (ETA)"),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            // Progress Indicator
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.designYellow),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                "Starting live tracking in a few moments",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bgColor, {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2));
  }

  Widget _buildInfoCard({required Widget child, Color bgColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
