import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/thank_you_screen.dart';
import '../features/common/widgets/splash_screen.dart';
import 'main_wrapper.dart';

import '../features/support_driver/dashboard/support_driver_dashboard.dart';
import '../features/support_driver/pickup_requests/pickup_request_screen.dart';
import '../features/support_driver/active_trip/waiting_screen.dart';
import '../features/support_driver/inspection/inspection_screen.dart';
import '../features/support_driver/garage_delivery/garage_delivery_screen.dart';

import '../features/main_driver/dashboard/main_driver_dashboard.dart';
import '../features/main_driver/pick_me_requests/pick_me_request_screen.dart';
import '../features/main_driver/transport_trip/transport_trip_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/thank_you':
        return MaterialPageRoute(builder: (_) => const ThankYouScreen());
        
      // SUPPORT DRIVER ROUTES
      case '/support_driver_dashboard':
        return MaterialPageRoute(builder: (_) => const MainWrapper(child: SupportDriverDashboard()));
      case '/support_driver_pickup_request':
        return MaterialPageRoute(builder: (_) => const SupportDriverPickupRequestScreen());
      case '/support_driver_waiting':
        return MaterialPageRoute(builder: (_) => const SupportDriverWaitingScreen());
      case '/support_driver_inspection':
        return MaterialPageRoute(builder: (_) => const SupportDriverInspectionScreen());
      case '/support_driver_garage_delivery':
        return MaterialPageRoute(builder: (_) => const SupportDriverGarageDeliveryScreen());
        
      // MAIN DRIVER ROUTES
      case '/main_driver_dashboard':
        return MaterialPageRoute(builder: (_) => const MainWrapper(child: MainDriverDashboard()));
      case '/main_driver_pick_me_request':
        return MaterialPageRoute(builder: (_) => const MainDriverPickMeRequestScreen());
      case '/main_driver_transport':
        return MaterialPageRoute(builder: (_) => const MainDriverTransportScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for \${settings.name}'),
            ),
          ),
        );
    }
  }
}
