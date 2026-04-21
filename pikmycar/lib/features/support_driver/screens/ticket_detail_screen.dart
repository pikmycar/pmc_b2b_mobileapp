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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ticket #${widget.ticketId}",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
                  context: context,
                  icon: Icons.check,
                  label: "Accepted",
                  bgColor: AppColors.success,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  "HIGH priority",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Customer InfoSection
            _buildSectionHeader(context, "CUSTOMER INFO"),
            const SizedBox(height: 12),
            _buildInfoCard(
              context: context,
              child: Column(
                children: [
                  _buildDetailRow(
                    context: context,
                    icon: Icons.person,
                    iconColor: colorScheme.primary,
                    title: "Ahmed Al-Rashid",
                    subtitle: "+971 50 123 4567",
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context: context,
                    icon: Icons.email,
                    iconColor: colorScheme.secondary,
                    title: "ahmed@example.ae",
                    subtitle: "",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pickup Details Section
            _buildSectionHeader(context, "PICKUP DETAILS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              context: context,
              child: Column(
                children: [
                  _buildDetailRow(
                    context: context,
                    icon: Icons.location_on,
                    iconColor: AppColors.error,
                    title: "Dubai Marina, Tower B",
                    subtitle: "Today · 10:30 AM · Ahmed Al-Rashid",
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      height: 30,
                      width: 2,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context: context,
                    icon: Icons.factory_outlined,
                    iconColor: colorScheme.onSurface.withOpacity(0.6),
                    title: "Al Quoz Auto Service",
                    subtitle: "Preferred delivery: Today by 4:00 PM",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Car Details Section
            _buildSectionHeader(context, "CAR DETAILS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              context: context,
              bgColor: colorScheme.primary.withOpacity(0.05),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BMW 3 Series · Blue",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "2022 · Plate: M72528",
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.onSurface, width: 1.5),
                      ),
                      child: Text(
                        "M72528",
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service Options Section
            _buildSectionHeader(context, "SERVICE OPTIONS"),
            const SizedBox(height: 12),
            _buildInfoCard(
              context: context,
              bgColor: colorScheme.secondary.withOpacity(0.05),
              child: Column(
                children: [
                  _buildDetailRow(
                    context: context,
                    icon: Icons.build_outlined,
                    iconColor: colorScheme.onSurface.withOpacity(0.4),
                    title: "Full Service",
                    subtitle: "Oil change, filters, inspection",
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context: context,
                    icon: Icons.money,
                    iconColor: AppColors.warning,
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
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
          child: ElevatedButton(
            onPressed: _isSendingRequest ? null : _handlePickMe,
            child: _isSendingRequest
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text("Request sending..."),
                    ],
                  )
                : const Text("Pick Me"),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
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
            style: textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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

  Widget _buildInfoCard({required BuildContext context, required Widget child, Color? bgColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
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
