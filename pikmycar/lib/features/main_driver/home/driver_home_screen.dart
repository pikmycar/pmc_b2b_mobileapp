import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PikMyCar Driver", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Driver Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 35),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Welcome back,", style: TextStyle(color: Colors.grey)),
                    Text("Main Driver", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Stats Grid
            Row(
              children: [
                _statCard("Total Trips", "12", Icons.directions_car),
                const SizedBox(width: 16),
                _statCard("Earnings", "₹450", Icons.account_balance_wallet),
              ],
            ),
            
            const Spacer(),
            
            // Online/Offline Toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.success.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    _isOnline ? Icons.online_prediction : Icons.offline_bolt,
                    size: 60,
                    color: _isOnline ? AppColors.success : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isOnline ? "YOU ARE ONLINE" : "YOU ARE OFFLINE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isOnline ? AppColors.success : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOnline ? "Waiting for trip requests..." : "Go online to start receiving trips",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isOnline = !_isOnline);
                  if (_isOnline) {
                    // Simulate a request coming after a delay
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted && _isOnline) {
                        _showTripRequest();
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOnline ? AppColors.error : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isOnline ? "GO OFFLINE" : "GO ONLINE",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showTripRequest() {
    // Show TripRequest bottom sheet style screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _buildTripRequestUI(),
    );
  }

  Widget _buildTripRequestUI() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "New Trip Request!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          _tripInfoRow(Icons.person, "Customer", "John Doe"),
          const SizedBox(height: 16),
          _tripInfoRow(Icons.location_on, "Pickup", "Mall of the Emirates"),
          const SizedBox(height: 12),
          _tripInfoRow(Icons.flag, "Drop", "Dubai Marina Mall"),
          const SizedBox(height: 16),
          _tripInfoRow(Icons.wallet, "Fare", "₹250"),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("DECLINE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/navigate_to_pickup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("ACCEPT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _tripInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        )
      ],
    );
  }
}
