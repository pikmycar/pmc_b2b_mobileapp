import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../transport_trip/bloc/trip_bloc.dart';
import '../transport_trip/bloc/trip_event.dart';
import '../transport_trip/bloc/trip_state.dart';
import '../../../core/models/trip_models.dart';

class MainDriverPickMeRequestScreen extends StatefulWidget {
  const MainDriverPickMeRequestScreen({super.key});

  @override
  State<MainDriverPickMeRequestScreen> createState() => _MainDriverPickMeRequestScreenState();
}

class _MainDriverPickMeRequestScreenState extends State<MainDriverPickMeRequestScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state.status == TripStatus.accepted) {
          Navigator.pushReplacementNamed(context, '/main_driver_transport');
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.primary.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Trip Requests', 
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        body: Center(
          child: Text(
            'Please manage trips from the Home Dashboard', 
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
