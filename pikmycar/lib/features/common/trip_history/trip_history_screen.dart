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
      'dateHeader': 'YESTERDAY',
      'trips': [
        {
          'vehicle': 'Mercedes C300',
          'plate': 'A11222',
          'route': 'DIFC ➡️ Motor City',
          'time': '2:00 PM',
          'amount': '+₹110',
          'status': 'Completed',
        },
        {
          'vehicle': 'Nissan Patrol',
          'plate': 'K55500',
          'route': 'Mirdif ➡️ Deira',
          'time': '4:45 PM',
          'amount': '',
          'status': 'Cancelled',
        },
      ]
    },
  ];

  List<Map<String, dynamic>> get _filteredGroups {
    if (_selectedFilter == 'All') return _allTrips;

    List<Map<String, dynamic>> filtered = [];

    for (var group in _allTrips) {
      final trips = (group['trips'] as List)
          .where((t) => t['status'] == _selectedFilter)
          .toList();

      if (trips.isNotEmpty) {
        filtered.add({
          'dateHeader': group['dateHeader'],
          'trips': trips,
        });
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designSurface,
      body: SafeArea(
        child: Stack(
          children: [
            _headerBg(),

            Column(
              children: [
                _header(),

                const SizedBox(height: 30),

                // 🔥 FLOATING FILTER CARD
                _filterContainer(),

                Expanded(child: _tripList()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 HEADER BACKGROUND
  Widget _headerBg() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.designDarkGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // 🔥 HEADER
  Widget _header() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            "Trip History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Your completed & cancelled rides",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FILTER CONTAINER (NEW PREMIUM)
  Widget _filterContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _chip('All'),
          _chip('Completed'),
          _chip('Cancelled'),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    bool selected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 🔥 LIST
  Widget _tripList() {
    final groups = _filteredGroups;

    if (groups.isEmpty) {
      return const Center(child: Text("No trips"));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 DATE HEADER (IMPROVED)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                group['dateHeader'],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),

            ...group['trips']
                .map<Widget>((trip) => _tripCard(trip))
                .toList(),
          ],
        );
      },
    );
  }

  // 🔥 PREMIUM CARD
  Widget _tripCard(Map trip) {
    bool isCompleted = trip['status'] == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.close,
              color: isCompleted ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(width: 12),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['vehicle'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700)),
                Text(trip['plate'],
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(trip['route'],
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
                Text(trip['time'],
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // RIGHT SIDE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // STATUS BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trip['status'],
                  style: TextStyle(
                    color:
                        isCompleted ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              if (isCompleted)
                Text(
                  trip['amount'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

              const SizedBox(height: 6),

              if (isCompleted)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RateExperienceScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Rate",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}