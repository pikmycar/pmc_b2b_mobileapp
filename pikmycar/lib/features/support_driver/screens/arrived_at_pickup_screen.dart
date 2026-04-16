import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ArrivedAtPickupScreen extends StatelessWidget {
  const ArrivedAtPickupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Arrived at Pickup',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          children: [
            // Center Illustration (Pin)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Pale Green
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.location_on, color: Colors.pink, size: 50),
              ),
            ),
            const SizedBox(height: 32),
            
            // Arrival Header
            const Text(
              "You've Arrived!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Dubai Marina, Tower B",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Locate the customer and begin inspection",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 48),

            // Customer Contact Card
            _buildContactCard(),
            
            const SizedBox(height: 32),

            // Secondary Actions (Call/SMS)
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryButton(
                    context, 
                    "Call", 
                    Icons.phone_in_talk, 
                    Colors.pink,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSecondaryButton(
                    context, 
                    "SMS", 
                    Icons.textsms_rounded, 
                    Colors.deepPurpleAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Primary Action
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/support_driver_inspection');
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
                    Icon(Icons.search, size: 22),
                    SizedBox(width: 8),
                    Text("Start Car Inspection"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CUSTOMER CONTACT", 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.deepPurple, size: 28),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ahmed Al-Rashid",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                  ),
                  Text(
                    "Contact person on-site",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.pinkAccent, size: 26),
              const SizedBox(width: 16),
              const Text(
                "+971 50 123 4567",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String label, IconData icon, Color iconColor) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${label}ing Ahmed Al-Rashid..."),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.designForestGreen,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5F9),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
