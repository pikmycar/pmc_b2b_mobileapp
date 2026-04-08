import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../common/widgets/custom_top_header_bar.dart';
import '../../common/widgets/offline_screen_body.dart';
import '../../common/widgets/app_drawer.dart';
import '../../../app/main_wrapper.dart';

class SupportDriverDashboard extends StatefulWidget {
  const SupportDriverDashboard({super.key});

  @override
  State<SupportDriverDashboard> createState() => _SupportDriverDashboardState();
}

class _SupportDriverDashboardState extends State<SupportDriverDashboard> {
  bool _isOnline = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
                        const Text("245", style: AppTextStyles.heading1),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, color: AppColors.textInversePrimary.withValues(alpha: 0.8), size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            
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
                        tripsCount: "15",
                        rating: "4.9",
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
            target: LatLng(25.2048, 55.2708),
            zoom: 14.0,
          ),
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
        ),
        
        // Car Marker
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: const Center(
            child: Icon(Icons.directions_car, color: Colors.white, size: 24),
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
                const Icon(Icons.search, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Looking for nearby pickup requests...",
                    style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/support_driver_pickup_request'),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
