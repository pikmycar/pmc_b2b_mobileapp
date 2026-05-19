import 'dart:async';
import 'package:flutter/material.dart';

class TripRequestScreen extends StatefulWidget {
  const TripRequestScreen({super.key});

  @override
  State<TripRequestScreen> createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends State<TripRequestScreen> {
  int currentIndex = 0;
  int seconds = 300;
  Timer? timer;
  late PageController _pageController;

  List<Map<String, dynamic>> trips = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadTrips();
    _startTimer();
  }

  Future<void> _loadTrips() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      trips = [
        {
          "pickup": "Dubai Marina, Tower A",
          "drop": "Al Quoz, Auto Center",
          "name": "Mohamed Haja",
          "rating": "4.5",
          "fare": "AED 1,544"
        },
        {
          "pickup": "Palm Jumeirah",
          "drop": "Business Bay",
          "name": "Rahul",
          "rating": "4.2",
          "fare": "AED 320"
        },
        {
          "pickup": "JLT Cluster V",
          "drop": "DXB Terminal 1",
          "name": "Suresh",
          "rating": "4.8",
          "fare": "AED 210"
        },
      ];
    });
  }

  Future<void> _refreshTrips() async {
    currentIndex = 0;
    await _loadTrips();
    _pageController.jumpToPage(0);
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    seconds = 300;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() => seconds--);

      if (seconds <= 0) {
        _rejectTrip(auto: true);
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() => currentIndex = index);
    _startTimer();
  }

  void _nextTrip() {
    if (currentIndex < trips.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _acceptTrip() {
    timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Trip Accepted! Drive Safely. ✅"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _nextTrip();
  }

  void _rejectTrip({bool auto = false}) {
    timer?.cancel();
    _nextTrip();
  }

  String _time() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Trip Requests",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: trips.isEmpty 
        ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
        : RefreshIndicator(
            onRefresh: _refreshTrips,
            color: colorScheme.primary,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _onPageChanged,
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return _buildSwipeCard(trips[index], index);
              },
            ),
          ),
    );
  }

  Widget _buildSwipeCard(Map<String, dynamic> trip, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(trip["name"] + index.toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _rejectTrip(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.only(left: 32),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.close, color: colorScheme.onError, size: 36),
      ),
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _buildCard(trip, index),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> trip, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    bool isActive = index == currentIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.08 : 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Swipe right to reject • Scroll down for next",
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 32),

          _locationRow(context, Icons.radio_button_checked, trip["pickup"], colorScheme.primary, "PICKUP"),
          const SizedBox(height: 8),
          _dottedLine(context),
          const SizedBox(height: 8),
          _locationRow(context, Icons.location_on, trip["drop"], colorScheme.error, "DROP-OFF"),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),

          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.person, color: colorScheme.primary, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip["name"],
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: colorScheme.secondary),
                        Text(
                          " ${trip["rating"]} Rating",
                          style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trip["fare"],
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "Est. Earnings",
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.4), fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 32),

          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Expiring in ${_time()}",
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _rejectTrip,
                  child: const Text("REJECT"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _acceptTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                  ),
                  child: const Text("ACCEPT"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _locationRow(BuildContext context, IconData icon, String text, Color color, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.4),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                text,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _dottedLine(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 9.0),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            height: 4,
            width: 2,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}