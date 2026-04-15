import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/trip_models.dart';
import '../../../../core/services/trip_storage_service.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripStorageService _storageService;
  Timer? _requestTimeoutTimer;

  TripBloc(this._storageService) : super(const TripInitial()) {
    on<GoOnline>(_onGoOnline);
    on<GoOffline>(_onGoOffline);
    on<SimulateRequest>(_onSimulateRequest);
    on<AcceptRequest>(_onAcceptRequest);
    on<DeclineRequest>(_onDeclineRequest);
    on<MarkArrivedAtPickup>(_onMarkArrivedAtPickup);
    on<StartTripToCustomer>(_onStartTripToCustomer);
    on<MarkDropComplete>(_onMarkDropComplete);
    on<UpdateLocation>(_onUpdateLocation);
    on<ResetToSearching>(_onResetToSearching);
    on<ReloadStoredTrip>(_onReloadStoredTrip);

    // Load stored trip on initialization
    add(ReloadStoredTrip());
  }

  Future<void> _onReloadStoredTrip(ReloadStoredTrip event, Emitter<TripState> emit) async {
    final storedTrip = await _storageService.getTrip();
    if (storedTrip != null) {
      emit(TripUpdate(status: storedTrip.status, activeTrip: storedTrip));
    }
  }

  void _onGoOnline(GoOnline event, Emitter<TripState> emit) {
    if (state.status == TripStatus.offline) {
      final newState = const TripUpdate(status: TripStatus.searching);
      emit(newState);
      _persistState(newState);
    }
  }

  void _onGoOffline(GoOffline event, Emitter<TripState> emit) {
    _requestTimeoutTimer?.cancel();
    final newState = const TripUpdate(status: TripStatus.offline);
    emit(newState);
    _storageService.clearTrip();
  }

  void _onSimulateRequest(SimulateRequest event, Emitter<TripState> emit) {
    print("DEBUG: [TripBloc] SimulateRequest received. Current Status: ${state.status}");
    
    // Simulation allows resetting for testing purposes
    final mockDriver = const SupportDriver(
      id: 'SD-99',
      name: 'Rahul Kumar',
      rating: 4.8,
      photo: 'https://i.pravatar.cc/150?img=11',
      pickupLocation: 'Burj Khalifa, Downtown Dubai',
      dropLocation: 'Dubai Museum, Al Fahidi',
      pickupLat: 25.1972,
      pickupLng: 55.2744,
      dropLat: 25.276987,
      dropLng: 55.296249,
      distance: 8.5,
      eta: '12 mins',
      seatsRequired: 1,
    );

    final trip = Trip(
      tripId: 'TRP-${DateTime.now().millisecondsSinceEpoch}',
      mainDriverId: 'MD-001',
      supportDrivers: [mockDriver],
      availableSeats: 4,
      selectedSeats: 1,
      totalDistance: 8.5,
      totalEarnings: 45.0,
      status: TripStatus.requestReceived,
      currentTargetDriverId: mockDriver.id,
    );

    print("DEBUG: [TripBloc] Emitting requestReceived. ActiveTrip: ${trip.tripId}, SupportDrivers: ${trip.supportDrivers.length}");
    
    final newState = TripUpdate(status: TripStatus.requestReceived, activeTrip: trip);
    emit(newState);
    _persistState(newState);

    // Start 5-minute timeout
    _requestTimeoutTimer?.cancel();
    _requestTimeoutTimer = Timer(const Duration(minutes: 5), () {
      print("DEBUG: [TripBloc] Request timeout reached. Auto-declining.");
      add(DeclineRequest());
    });
  }

  void _onAcceptRequest(AcceptRequest event, Emitter<TripState> emit) {
    if (state.status == TripStatus.requestReceived && state.activeTrip != null) {
      _requestTimeoutTimer?.cancel();
      
      final updatedTrip = state.activeTrip!.copyWith(
        status: TripStatus.navigatingToPickup,
        supportDrivers: state.activeTrip!.supportDrivers.map((d) => 
          d.copyWith(status: SupportDriverStatus.PICKUP_IN_PROGRESS)
        ).toList(),
      );

      final newState = TripUpdate(status: TripStatus.navigatingToPickup, activeTrip: updatedTrip);
      emit(newState);
      _persistState(newState);
    }
  }

  void _onDeclineRequest(DeclineRequest event, Emitter<TripState> emit) {
    if (state.status == TripStatus.requestReceived) {
      _requestTimeoutTimer?.cancel();
      final newState = const TripUpdate(status: TripStatus.searching);
      emit(newState);
      _persistState(newState);
    }
  }

  void _onMarkArrivedAtPickup(MarkArrivedAtPickup event, Emitter<TripState> emit) {
    if (state.status == TripStatus.navigatingToPickup && state.activeTrip != null) {
      final updatedTrip = state.activeTrip!.copyWith(
        status: TripStatus.pickupReached,
        supportDrivers: state.activeTrip!.supportDrivers.map((d) => 
          d.copyWith(status: SupportDriverStatus.PICKUP_REACHED)
        ).toList(),
      );
      final newState = TripUpdate(status: TripStatus.pickupReached, activeTrip: updatedTrip);
      emit(newState);
      _persistState(newState);
    }
  }

  void _onStartTripToCustomer(StartTripToCustomer event, Emitter<TripState> emit) {
    if (state.status == TripStatus.pickupReached && state.activeTrip != null) {
      final updatedTrip = state.activeTrip!.copyWith(
        status: TripStatus.inTrip,
        supportDrivers: state.activeTrip!.supportDrivers.map((d) => 
          d.copyWith(status: SupportDriverStatus.PICKED)
        ).toList(),
      );
      final newState = TripUpdate(status: TripStatus.inTrip, activeTrip: updatedTrip);
      emit(newState);
      _persistState(newState);
    }
  }

  void _onMarkDropComplete(MarkDropComplete event, Emitter<TripState> emit) {
    if (state.status == TripStatus.inTrip && state.activeTrip != null) {
      final updatedTrip = state.activeTrip!.copyWith(
        status: TripStatus.completed,
        supportDrivers: state.activeTrip!.supportDrivers.map((d) => 
          d.copyWith(status: SupportDriverStatus.DROPPED)
        ).toList(),
      );
      final newState = TripUpdate(status: TripStatus.completed, activeTrip: updatedTrip);
      emit(newState);
      _storageService.clearTrip(); // Trip finished
    }
  }

  void _onResetToSearching(ResetToSearching event, Emitter<TripState> emit) {
    if (state.status == TripStatus.completed) {
      final newState = const TripUpdate(status: TripStatus.searching);
      emit(newState);
      _persistState(newState);
    }
  }

  void _onUpdateLocation(UpdateLocation event, Emitter<TripState> emit) {
    // Logic for live location updates
  }

  void _persistState(TripState state) {
    if (state.activeTrip != null) {
      _storageService.saveTrip(state.activeTrip!);
    }
  }

  @override
  Future<void> close() {
    _requestTimeoutTimer?.cancel();
    return super.close();
  }
}
