import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../common/widgets/custom_top_header_bar.dart';
import '../../common/widgets/offline_screen_body.dart';
import '../../common/widgets/app_drawer.dart';
import '../../../app/main_wrapper.dart';

class MainDriverDashboard extends StatefulWidget {
  const MainDriverDashboard({super.key});

  @override
  State<MainDriverDashboard> createState() => _MainDriverDashboardState();
}

class _MainDriverDashboardState extends State<MainDriverDashboard> {
  bool _isOnline = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Sync initial state with wrapper
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainWrapper.isOnlineNotifier.value = _isOnline;
    });
  }

  void _toggleOnline(bool val) {
    setState(() {
      _isOnline = val;
    });
    MainWrapper.isOnlineNotifier.value = val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomTopHeaderBar(
               isOnline: _isOnline,
               onOnlineStatusChanged: _toggleOnline,
               onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            
            // Stats/Earnings Row (Only visible when online)
            if (_isOnline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5) ?? Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "💵 Today's",
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textInverseSecondary),
                        ),
                        Text(
                          "Earnings",
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textInverseSecondary),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text("AED", style: AppTextStyles.subtitle),
                        const SizedBox(width: 8),
                        const Text("320", style: AppTextStyles.heading1),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, color: AppColors.textInversePrimary.withValues(alpha: 0.8), size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Main Content Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: _isOnline 
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )
                    : BorderRadius.zero,
                ),
                child: ClipRRect(
                  borderRadius: _isOnline 
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      )
                    : BorderRadius.zero,
                  child: _isOnline
                    ? _buildOnlineContent()
                    : const OfflineScreenBody(
                        tripsCount: "20",
                        rating: "4.8",
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(25.2048, 55.2708), // Default Dubai
            zoom: 14.0,
          ),
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
        ),
        
        // Radar effect overlay
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          ),
        ),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
          ),
        ),
        // Car Marker
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: const Center(
            child: Icon(Icons.directions_car, color: Colors.black87, size: 24),
          ),
        ),
        
        // Searching badge
        Positioned(
          bottom: 20,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(
              children: [
                const Icon(Icons.radar, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Waiting for trips in 5km radius...",
                    style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Invisible tap target for demo
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/main_driver_pick_me_request'),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
