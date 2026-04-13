import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/rate_experience_screen.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _allTrips = [
    {
      'dateHeader': 'YESTERDAY, FEB 26',
      'trips': [
        {
          'vehicle': 'Mercedes C300',
          'plate': 'A11222',
          'route': 'DIFC ➡️ Motor City',
          'time': '2:00 PM',
          'amount': '+AED 110',
          'status': 'Completed',
          'emoji': '🚙',
          'bgColor': Color(0xFFFEF4ED),
        },
        {
          'vehicle': 'Nissan Patrol',
          'plate': 'K55500',
          'route': 'Mirdif ➡️ Deira',
          'time': '4:45 PM',
          'amount': '',
          'status': 'Cancelled',
          'emoji': '🚫',
          'bgColor': Color(0xFFFEEDED),
        },
      ]
    },
    {
      'dateHeader': 'FEB 25',
      'trips': [
        {
          'vehicle': 'BMW 5 Series',
          'plate': 'D12345',
          'route': 'JBR ➡️ Al Barsha',
          'time': '11:15 AM',
          'amount': '+AED 70',
          'status': 'Completed',
          'emoji': '🚗',
          'bgColor': Color(0xFFF0F9FF),
        },
      ]
    }
  ];

  List<Map<String, dynamic>> get _filteredGroups {
    if (_selectedFilter == 'All') return _allTrips;
    
    List<Map<String, dynamic>> filtered = [];
    for (var group in _allTrips) {
      final matchingTrips = (group['trips'] as List).where((t) => t['status'] == _selectedFilter).toList();
      if (matchingTrips.isNotEmpty) {
        filtered.add({
          'dateHeader': group['dateHeader'],
          'trips': matchingTrips,
        });
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: _buildTripList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           const Icon(Icons.arrow_back, color: Colors.black, size: 24),
           const Text(
            "Trip History",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Icon(Icons.settings, color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 12),
          _buildFilterChip('Completed'),
          const SizedBox(width: 12),
          _buildFilterChip('Cancelled'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTripList() {
    final groups = _filteredGroups;
    if (groups.isEmpty) {
      return const Center(child: Text("No trips found", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              group['dateHeader'],
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            ... (group['trips'] as List).map((trip) => _buildTripCard(trip)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    bool isCompleted = trip['status'] == 'Completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: trip['bgColor'],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                trip['status'] == 'Completed' ? Icons.directions_car : Icons.cancel_outlined,
                color: isCompleted ? Colors.blue.shade700 : Colors.red.shade700,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['vehicle'],
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  trip['plate'],
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      trip['route'].toString().split('➡️')[0].trim(),
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_right_alt, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      trip['route'].toString().split('➡️')[1].trim(),
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  trip['time'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          // Status/Amount Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCompleted) ...[
                Text(
                  trip['amount'],
                  style: const TextStyle(
                    color: Color(0xFF1E6B3F),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: const [
                    Text("✓ Done", style: TextStyle(color: Color(0xFF1E6B3F), fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              if (isCompleted) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RateExperienceScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "Rate",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
