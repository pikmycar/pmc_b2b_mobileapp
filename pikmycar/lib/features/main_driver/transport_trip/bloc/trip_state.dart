import 'package:equatable/equatable.dart';
import '../../../../core/models/trip_models.dart';

abstract class TripState extends Equatable {
  final TripStatus status;
  final Trip? activeTrip;
  final String? error;
  final bool isLoading;

  const TripState({
    this.status = TripStatus.offline,
    this.activeTrip,
    this.error,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [status, activeTrip, error, isLoading];
}

class TripInitial extends TripState {
  const TripInitial() : super();
}

class TripUpdate extends TripState {
  const TripUpdate({
    required super.status,
    super.activeTrip,
    super.error,
    super.isLoading,
  });
}
