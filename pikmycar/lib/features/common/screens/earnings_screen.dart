import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Top background is black as per image
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildBalanceCard(),
                      const SizedBox(height: 24),
                      _buildPeriodTabs(),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildCarInfo(),
                      const SizedBox(height: 24),
                      _buildPayoutCard(),
                      const SizedBox(height: 40),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: const [
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text(
            "Earnings",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.designYellow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AED",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const Text(
            "1,240",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Total This Week",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.trending_up, color: Color(0xFF1E6B3F), size: 16),
              SizedBox(width: 4),
              Text(
                "+18% vs last week",
                style: TextStyle(
                  color: Color(0xFF1E6B3F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Row(
      children: [
        _buildTab("Today", isActive: true),
        const SizedBox(width: 12),
        _buildTab("Week"),
        const SizedBox(width: 12),
        _buildTab("Month"),
      ],
    );
  }

  Widget _buildTab(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            "12",
            "Trips",
            backgroundColor: AppColors.designMint,
            textColor: const Color(0xFF1E6B3F),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            "4.9",
            "Rating",
            showStar: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            "AED 320",
            "Today",
            textColor: const Color(0xFF1E6B3F),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, {Color? backgroundColor, Color? textColor, bool showStar = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: backgroundColor == null ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor ?? Colors.black,
                ),
              ),
              if (showStar) ...[
                const SizedBox(width: 4),
                Icon(Icons.star, color: Colors.amber, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCarInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: const Center(
        child: Text(
          "BMW",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPayoutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.designMint.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Color(0xFF1E6B3F), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Payout Available",
                  style: TextStyle(
                    color: Color(0xFF1E6B3F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.designDarkGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "Withdraw AED 1,240",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
