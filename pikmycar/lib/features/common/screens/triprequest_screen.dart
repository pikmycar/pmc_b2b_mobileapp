import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

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

  // 🔥 FAKE API LOAD
  Future<void> _loadTrips() async {
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      trips = [
        {
          "pickup": "Triplicane, Chennai",
          "drop": "T Nagar, Chennai",
          "name": "Mohamed Haja",
          "rating": "4.5",
          "fare": "₹1544"
        },
        {
          "pickup": "Velachery, Chennai",
          "drop": "OMR, Chennai",
          "name": "Rahul",
          "rating": "4.2",
          "fare": "₹320"
        },
        {
          "pickup": "Adyar, Chennai",
          "drop": "Guindy, Chennai",
          "name": "Suresh",
          "rating": "4.8",
          "fare": "₹210"
        },
      ];
    });
  }

  // 🔥 PULL TO REFRESH
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
      const SnackBar(content: Text("Trip Accepted ✅")),
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
    return Scaffold(
      backgroundColor: AppColors.designSurface,
      appBar: AppBar(
        title: const Text("Trip Requests"),
        backgroundColor: AppColors.designForestGreen,
        centerTitle: true,
      ),

      // 🔥 PULL TO REFRESH WRAPPER
      body: RefreshIndicator(
        onRefresh: _refreshTrips,
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

  // 🔥 SWIPE RIGHT TO REJECT
  Widget _buildSwipeCard(Map<String, dynamic> trip, int index) {
    return Dismissible(
      key: ValueKey(trip["name"] + index.toString()),
      direction: DismissDirection.startToEnd, // 👉 swipe right
      onDismissed: (_) => _rejectTrip(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 30),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: _buildCard(trip, index),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> trip, int index) {
    bool isActive = index == currentIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Swipe right to reject • Scroll down for next",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          /// 📍 ROUTE
          _locationRow(Icons.circle, trip["pickup"], Colors.green),
          const SizedBox(height: 8),
          _dottedLine(),
          const SizedBox(height: 8),
          _locationRow(Icons.location_on, trip["drop"], Colors.red),

          const Divider(height: 35),

          /// 👤 USER + FARE
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip["name"],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                        Text(" ${trip["rating"]}",
                            style: const TextStyle(color: Colors.grey))
                      ],
                    )
                  ],
                ),
              ),
              Text(
                trip["fare"],
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.designForestGreen,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 25),

          if (isActive)
            Text(
              "Auto reject in ${_time()}",
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),

          const SizedBox(height: 20),

          /// 🔥 BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _rejectTrip,
                  child: const Text("Reject"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _acceptTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.designForestGreen,
                  ),
                  child: const Text("Accept"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _locationRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        )
      ],
    );
  }

  Widget _dottedLine() {
    return Column(
      children: List.generate(
        4,
        (_) => Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 4,
          width: 2,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}