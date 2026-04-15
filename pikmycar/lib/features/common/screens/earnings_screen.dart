import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _balanceCard(),
                      const SizedBox(height: 20),
                      _tabs(),
                      const SizedBox(height: 20),
                      _stats(),
                      const SizedBox(height: 20),
                      _car(),
                      const SizedBox(height: 20),
                      _payout(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 GRADIENT HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF1C1C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text(
            "Earnings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 BALANCE CARD
  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.designYellow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "AED 1,240",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Total This Week",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF1E6B3F), size: 16),
              SizedBox(width: 4),
              Text(
                "+18% vs last week",
                style: TextStyle(
                  color: Color(0xFF1E6B3F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 🔥 TABS
  Widget _tabs() {
    return Row(
      children: [
        _tab("Today", true),
        const SizedBox(width: 10),
        _tab("Week", false),
        const SizedBox(width: 10),
        _tab("Month", false),
      ],
    );
  }

  Widget _tab(String text, bool active) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 🔥 STATS
  Widget _stats() {
    return Row(
      children: [
        Expanded(child: _stat("12", "Trips")),
        const SizedBox(width: 10),
        Expanded(child: _rating()),
        const SizedBox(width: 10),
        Expanded(child: _stat("AED 320", "Today", green: true)),
      ],
    );
  }

  Widget _stat(String value, String label, {bool green = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: green ? const Color(0xFF1E6B3F) : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12))
        ],
      ),
    );
  }

  // ⭐ PRO RATING UI
  Widget _rating() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "4.9",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF1E6B3F),
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.star, color: Colors.green, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Rating",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        ],
      ),
    );
  }

  // 🔥 CAR
  Widget _car() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Center(
        child: Text(
          "BMW • Active Vehicle",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // 🔥 PAYOUT BUTTON
  Widget _payout(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet,
                color: Color(0xFF1E6B3F)),
            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                "Payout Available",
                style: TextStyle(
                  color: Color(0xFF1E6B3F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/withdraw');
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      "Withdraw",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
          ],
        ),
      ),
    );
  }
}