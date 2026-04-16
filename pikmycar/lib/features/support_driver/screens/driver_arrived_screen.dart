import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DriverArrivedScreen extends StatelessWidget {
  const DriverArrivedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Driver Arrived!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const Icon(Icons.celebration, color: Colors.indigo, size: 24),
          ],
        ),
        toolbarHeight: 100,
        backgroundColor: AppColors.designYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          children: [
            // Center Illustration Section
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.designYellow.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.designYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_taxi,
                      color: Colors.black,
                      size: 60,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Text Content
            const Text(
              "Main Driver is\nHere!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Khalid Al-Ameri is waiting outside.\nPlease head down to the car.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // Info Card
            _buildInfoCard(
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.directions_car,
                    Colors.redAccent.shade100,
                    "Toyota Camry · White",
                    "Plate: AB 12345",
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 40, top: 4, bottom: 4),
                    child: Divider(color: Colors.black12),
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    Colors.pinkAccent.shade100,
                    "Front entrance, Gate A",
                    "",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Primary Action
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/support_driver_ride_to_customer',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.designYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check, size: 24),
                    SizedBox(width: 8),
                    Text("I'm in the Car"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Action
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  print("Calling Driver...");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.phone_in_talk, color: Colors.pink, size: 24),
                    SizedBox(width: 12),
                    Text("Call Driver"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
