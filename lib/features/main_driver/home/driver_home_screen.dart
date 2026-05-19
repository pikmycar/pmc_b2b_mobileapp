// import 'package:flutter/material.dart';
// import '../../../core/theme/app_theme.dart';

// class DriverHomeScreen extends StatefulWidget {
//   const DriverHomeScreen({super.key});

//   @override
//   State<DriverHomeScreen> createState() => _DriverHomeScreenState();
// }

// class _DriverHomeScreenState extends State<DriverHomeScreen> {
//   bool _isOnline = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final textTheme = theme.textTheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "PikMyCar Driver",
//           style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings_outlined),
//             onPressed: () => Navigator.pushNamed(context, '/settings'),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 16),
//               // Driver Profile Header
//               _buildHeader(context),
//               const SizedBox(height: 32),
              
//               // Stats Grid
//               Row(
//                 children: [
//                   _statCard(context, "Total Trips", "12", Icons.directions_car),
//                   const SizedBox(width: 16),
//                   _statCard(context, "Earnings", "AED 450", Icons.account_balance_wallet),
//                 ],
//               ),
              
//               const Spacer(),
              
//               // Status Indicator
//               _buildStatusIndicator(context),
              
//               const SizedBox(height: 32),
              
//               // Action Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     setState(() => _isOnline = !_isOnline);
//                     if (_isOnline) {
//                       Future.delayed(const Duration(seconds: 2), () {
//                         if (mounted && _isOnline) {
//                           _showTripRequest();
//                         }
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _isOnline ? colorScheme.error : colorScheme.primary,
//                     foregroundColor: _isOnline ? colorScheme.onError : colorScheme.onPrimary,
//                   ),
//                   child: Text(
//                     _isOnline ? "GO OFFLINE" : "GO ONLINE",
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Row(
//       children: [
//         Container(
//           width: 64,
//           height: 64,
//           decoration: BoxDecoration(
//             color: colorScheme.primary.withOpacity(0.1),
//             shape: BoxShape.circle,
//             border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 2),
//           ),
//           child: Center(
//             child: Icon(Icons.person, size: 36, color: colorScheme.primary),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Welcome back,",
//               style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
//             ),
//             Text(
//               "Main Driver",
//               style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _statCard(BuildContext context, String label, String value, IconData icon) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: colorScheme.outlineVariant),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: colorScheme.primary, size: 24),
//             const SizedBox(height: 16),
//             Text(
//               label,
//               style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusIndicator(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//     final activeColor = _isOnline ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.4);

//     return Container(
//       padding: const EdgeInsets.all(32),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: _isOnline ? colorScheme.secondary.withOpacity(0.05) : colorScheme.onSurface.withOpacity(0.03),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: activeColor.withOpacity(0.1)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: activeColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               _isOnline ? Icons.online_prediction : Icons.offline_bolt,
//               size: 56,
//               color: activeColor,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             _isOnline ? "YOU ARE ONLINE" : "YOU ARE OFFLINE",
//             style: textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.w900,
//               color: activeColor,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _isOnline ? "Waiting for trip requests..." : "Go online to start receiving trips",
//             textAlign: TextAlign.center,
//             style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTripRequest() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: false,
//       enableDrag: false,
//       builder: (context) => _buildTripRequestUI(context),
//     );
//   }

//   Widget _buildTripRequestUI(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Container(
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: colorScheme.onSurface.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: 32),
//           Text(
//             "New Trip Request!",
//             style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
//           ),
//           const SizedBox(height: 32),
//           _tripInfoRow(context, Icons.person, "Customer", "John Doe"),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 16.0),
//             child: Divider(),
//           ),
//           _tripInfoRow(context, Icons.location_on, "Pickup", "Mall of the Emirates"),
//           const SizedBox(height: 16),
//           _tripInfoRow(context, Icons.flag, "Drop", "Dubai Marina Mall"),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 16.0),
//             child: Divider(),
//           ),
//           _tripInfoRow(context, Icons.account_balance_wallet, "Fare", "AED 250"),
//           const SizedBox(height: 40),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("DECLINE"),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pushNamed(context, '/navigate_to_pickup');
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.secondary,
//                     foregroundColor: colorScheme.onSecondary,
//                   ),
//                   child: const Text("ACCEPT"),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   Widget _tripInfoRow(BuildContext context, IconData icon, String label, String value) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: colorScheme.primary, size: 20),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 value,
//                 style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
