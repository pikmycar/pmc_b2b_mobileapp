import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How can we help you?",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Our support team is available 24/7 to assist you with any issues or queries.",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            _buildSupportOption(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              title: "Chat with Support",
              subtitle: "Start a conversation now",
              color: colorScheme.primary,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.call_outlined,
              title: "Call Support",
              subtitle: "Talk to our customer executive",
              color: colorScheme.secondary,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "Send us your queries via email",
              color: Colors.orange,
              onTap: () {},
            ),
            
            const SizedBox(height: 48),
            Text(
              "Common FAQs", 
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(context, "How to withdraw my earnings?"),
            _buildFAQItem(context, "What documents are required for verification?"),
            _buildFAQItem(context, "My trip was cancelled, what should I do?"),
            _buildFAQItem(context, "How to update my bank account details?"),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question, 
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                "You can find the detailed information about this in our help documentation. Typically, it takes 24 hours to process your request.",
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
