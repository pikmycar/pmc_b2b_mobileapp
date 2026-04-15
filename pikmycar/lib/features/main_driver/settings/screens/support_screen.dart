import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Help & Support", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our support team is available 24/7 to assist you with any issues or queries.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            
            _buildSupportOption(
              context,
              icon: Icons.chat_bubble_outline,
              title: "Chat with Support",
              subtitle: "Start a conversation now",
              color: Colors.blue,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.call_outlined,
              title: "Call Support",
              subtitle: "Talk to our customer executive",
              color: Colors.green,
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
            const Text("Common FAQs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildFAQItem("How to withdraw my earnings?"),
            _buildFAQItem("What documents are required for verification?"),
            _buildFAQItem("My trip was cancelled, what should I do?"),
            _buildFAQItem("How to update my bank account details?"),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
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
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "You can find the detailed information about this in our help documentation. Typically, it takes 24 hours to process your request.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
