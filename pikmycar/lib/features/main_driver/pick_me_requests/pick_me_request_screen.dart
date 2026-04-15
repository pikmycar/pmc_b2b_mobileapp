import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../transport_trip/bloc/trip_bloc.dart';
import '../transport_trip/bloc/trip_event.dart';
import '../transport_trip/bloc/trip_state.dart';
import '../../../core/models/trip_models.dart';

class MainDriverPickMeRequestScreen extends StatefulWidget {
  const MainDriverPickMeRequestScreen({Key? key}) : super(key: key);

  @override
  State<MainDriverPickMeRequestScreen> createState() => _MainDriverPickMeRequestScreenState();
}

class _MainDriverPickMeRequestScreenState extends State<MainDriverPickMeRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state.status == TripStatus.accepted) {
          Navigator.pushReplacementNamed(context, '/main_driver_transport');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary.withOpacity(0.87),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Trip Requests', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        ),
        body: const Center(
          child: Text('Please manage trips from the Home Dashboard', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
