import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/searching_main_driver_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({
    super.key,
    this.ticketId = "PKM-2847",
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isSendingRequest = false;

  Future<void> _handlePickMe() async {
    setState(() => _isSendingRequest = true);

    // Simulate 2s sending request
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate to dedicated Searching Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchingMainDriverScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.designYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ticket #${widget.ticketId}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badges
            Row(
              children: [
                _buildStatusBadge(
                  icon: Icons.check,
                  label: "Accepted by Pikmycar",
                  bgColor: AppColors.designForestGreen,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  "HIGH priority",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer InfoSection
            _buildSectionHeader("CUSTOMER INFO"),
            const SizedBox(height: 12),
            _buildInfoCard(
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.person,
                    iconColor: Colors.deepPurple,
                    title: "Ahmed Al-Rashid",
                    subtitle: "+971 50 123 4567",
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    icon: Icons.email,
                    iconColor: Colors.purple.shade100,
                    title: "ahmed@example.ae",
                    subtitle: "",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pickup Details Section
            _buildSectionHeader("PICKUP DETAILS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.location_on,
                    iconColor: Colors.pink,
                    title: "Dubai Marina, Tower B",
                    subtitle: "Today · 10:30 AM · Ahmed Al-Rashid",
                  ),
                  const SizedBox(height: 12),
                  // Dotted line simulation
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      height: 30,
                      width: 2,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.factory_outlined,
                    iconColor: Colors.blueGrey,
                    title: "Al Quoz Auto Service",
                    subtitle: "Preferred delivery: Today by 4:00 PM",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Car Details Section
            _buildSectionHeader("CAR DETAILS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              bgColor: const Color(0xFFE8F5E9),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BMW 3 Series · Blue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "2022 · Plate: M72528",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Text(
                        "M72528",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: const Text(
                        "M72528",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service Options Section
            _buildSectionHeader("SERVICE OPTIONS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              bgColor: const Color(0xFFFFFBE6),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.build_outlined,
                    iconColor: Colors.grey.shade400,
                    title: "Full Service",
                    subtitle: "Oil change, filters, inspection",
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.money,
                    iconColor: Colors.orange.shade300,
                    title: "Pricing: AED 280",
                    subtitle: "Peak-time + High priority",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Footer Note
            Text(
              "Notes: Please handle with care – premium vehicle",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isSendingRequest ? null : _handlePickMe,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.designYellow,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSendingRequest
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Request sending...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    "Pick Me",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({required Widget child, Color bgColor = Colors.transparent}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor == Colors.transparent ? Colors.white : bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: bgColor == Colors.transparent ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: child,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
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
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
