import 'package:flutter/material.dart';
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
          'amount': '+AED 110',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _headerBg(context),

            Column(
              children: [
                _header(context),

                const SizedBox(height: 30),

                // FLOATING FILTER CARD
                _filterContainer(context),

                Expanded(child: _tripList(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerBg(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, color: colorScheme.onPrimary, size: 20),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Trip History",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Spacer for centering
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Your completed & cancelled rides",
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterContainer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.08 : 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _chip(context, 'All'),
          _chip(context, 'Completed'),
          _chip(context, 'Cancelled'),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool selected = _selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.6),
            fontWeight: selected ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tripList(BuildContext context) {
    final groups = _filteredGroups;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              "No trips found",
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                group['dateHeader'],
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            ...group['trips']
                .map<Widget>((trip) => _tripCard(context, trip))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _tripCard(BuildContext context, Map trip) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    bool isCompleted = trip['status'] == 'Completed';
    final statusColor = isCompleted ? colorScheme.secondary : colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.directions_car_filled : Icons.cancel_outlined,
              color: statusColor,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['vehicle'],
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  trip['plate'],
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  trip['route'],
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trip['time'],
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip['status'].toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (isCompleted)
                Text(
                  trip['amount'],
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),

              if (isCompleted)
                const SizedBox(height: 8),

              if (isCompleted)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RateExperienceScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Rate Trip",
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
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