import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ArrivedAtGarageScreen extends StatelessWidget {
  const ArrivedAtGarageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Arrived at Garage',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.designForestGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
        child: Column(
          children: [
            // Center Illustration (Trophy/Success)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.emoji_events, color: AppColors.designYellow, size: 70),
              ),
            ),
            const SizedBox(height: 32),
            
            // Completion Header
            const Text(
              "You've Arrived\nat the Garage!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Al Quoz Auto Service Center",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // Trip Summary Card
            _buildSummaryCard(),
            
            const SizedBox(height: 48),

            // Primary Action
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/support_driver_garage_handover');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.designForestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    const Icon(Icons.check_circle, size: 24),
                    const SizedBox(width: 12),
                    const Text("Handover to Garage"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        children: [
          const Text(
            "JOURNEY SUMMARY",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(Icons.route, "14.6 km", "Distance"),
              Container(height: 30, width: 1, color: Colors.grey.shade300),
              _buildSummaryItem(Icons.timer, "36 mins", "Duration"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.designForestGreen, size: 24),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
