import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import 'driver_accepted_screen.dart';

class SearchingMainDriverScreen extends StatefulWidget {
  const SearchingMainDriverScreen({Key? key}) : super(key: key);

  @override
  State<SearchingMainDriverScreen> createState() => _SearchingMainDriverScreenState();
}

class _SearchingMainDriverScreenState extends State<SearchingMainDriverScreen>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Auto-navigate to DriverAcceptedScreen after 8 seconds (Simulated search)
    _searchTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DriverAcceptedScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Searching for Main Driver...',
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
        child: Column(
          children: [
            // Radar Section
            Container(
              height: 300,
              width: double.infinity,
              color: const Color(0xFFF1F5F9),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _radarController,
                      builder: (context, child) {
                        double progress = (_radarController.value + index / 3) % 1.0;
                        return Container(
                          width: progress * 400,
                          height: progress * 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.designYellow.withOpacity(1 - progress),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.designYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: Colors.black, size: 30),
                  ),
                  _buildMockCarIcon(100, -80),
                  _buildMockCarIcon(-130, 60),
                  _buildMockCarIcon(150, 40),
                ],
              ),
            ),

            // Details Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge("Pickup Accepted", AppColors.designForestGreen),
                  const SizedBox(height: 16),
                  const Text(
                    "Searching for Main Driver...",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connecting you with a nearby driver for your pickup.",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("TRIP DETAILS"),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.my_location, AppColors.designYellow, "Your Location", "Support Driver Location"),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.person, Colors.deepPurple, "Ahmed Al-Rashid", "Customer · +971 50 123 4567"),
                        const Divider(height: 24),
                        _buildLocationRow(Icons.location_on, Colors.pink, "Dubai Marina, Tower B", "Pickup · Today 10:30 AM"),
                        const SizedBox(height: 12),
                        _buildLocationRow(Icons.factory_outlined, Colors.blueGrey, "Al Quoz Auto Service", "Drop-off"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("CAR DETAILS"),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    bgColor: const Color(0xFFE8F5E9),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, color: Colors.redAccent, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("BMW 3 Series · Blue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("M72528 · 2022", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        _buildPlateBox("M72528"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusBox(
                    emoji: "⏳",
                    text: "Pick Me request sent! Waiting for a Main Driver to confirm and pick you up from your location",
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildActionButton("Call Customer", Icons.phone)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionButton("Message", Icons.message)),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockCarIcon(double x, double y) {
    return Positioned(
      child: Transform.translate(
        offset: Offset(x, y),
        child: const Icon(Icons.directions_car, color: Colors.black45, size: 24),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildDetailRow(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildPlateBox(String plate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(plate, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBox({required String emoji, required String text}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.designYellow.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF854D0E), fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}
