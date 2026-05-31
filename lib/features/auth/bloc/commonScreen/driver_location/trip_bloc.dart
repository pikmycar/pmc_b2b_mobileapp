import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/constants/app_constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/models/trip_models.dart';
import '../../../../../core/services/trip_storage_service.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/services/map_navigation_service.dart';
import '../../../../../core/storage/secure_storage_service.dart';
import '../../../data/datasource/driver_api.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final TripStorageService _storageService;
  final DriverApi _driverApi;
  final LocationService _locationService;
  final MapNavigationService _navigationService = MapNavigationService();
  
  Timer? _requestTimeoutTimer;
  StreamSubscription<Position>? _locationSubscription;
  DateTime? _lastLocationUpdate;

  IOWebSocketChannel? _webSocketChannel;
  Timer? _wsReconnectTimer;
  Timer? _wsPingTimer;
  bool _isConnectingWs = false;
  bool _isWsConnected = false;

  TripBloc(this._storageService, this._driverApi, this._locationService) : super(const TripInitial()) {
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
    on<FetchPendingRequests>(_onFetchPendingRequests);
    on<NextTripStep>(_onNextTripStep);
    on<CancelActiveTrip>(_onCancelActiveTrip);
    on<LogoutReset>(_onLogoutReset);

    // Load stored trip on initialization
    add(ReloadStoredTrip());
  }

  Future<void> _onReloadStoredTrip(ReloadStoredTrip event, Emitter<TripState> emit) async {
    final storedTrip = await _storageService.getTrip();
    if (storedTrip != null) {
      emit(TripUpdate(status: storedTrip.status, activeTrip: storedTrip));
      if (storedTrip.status != TripStatus.offline) {
        _connectWebSocket();
      }
    }
  }

  Future<void> _onGoOnline(GoOnline event, Emitter<TripState> emit) async {
    if (state.status == TripStatus.offline) {
      emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, isLoading: true));
      
      try {
        final position = await _locationService.getCurrentLocation();
        String address = "Unknown Location";
        if (position != null) {
          address = await _locationService.getAddressFromCoordinates(position.latitude, position.longitude);
        }

        // Call Availability API
        await _driverApi.updateAvailability(
          isOnline: true,
          isAvailable: true,
          lat: position?.latitude ?? 0.0,
          lng: position?.longitude ?? 0.0,
          address: address,
        );

        final newState = const TripUpdate(status: TripStatus.searching, isLoading: false);
        emit(newState);
        _persistState(newState);

        // Start location tracking
        _startLocationTracking();

        // Connect to WebSocket for real-time broadcasts
        _connectWebSocket();

        // Trigger fetch of pending requests immediately when online
        add(FetchPendingRequests());

      } catch (e) {
        String errorMsg = "Failed to go online";
        if (e is DioException && e.response?.statusCode == 422) {
          errorMsg = "Validation error: Please ensure location services are fully enabled.";
        }
        emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, error: errorMsg, isLoading: false));
      }
    }
  }

Future<void> _onGoOffline(GoOffline event, Emitter<TripState> emit) async {
  _requestTimeoutTimer?.cancel();
  _stopLocationTracking();
  _disconnectWebSocket();

  emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, isLoading: true));

  try {
    final position = await _locationService.getCurrentLocation();

    await _driverApi.updateAvailability(
      isOnline: false,
      isAvailable: false,
      lat: position?.latitude ?? 0.0,   // ✅ ADD THIS
      lng: position?.longitude ?? 0.0,  // ✅ ADD THIS
    );

    final newState = const TripUpdate(status: TripStatus.offline, isLoading: false);
    emit(newState);
    _storageService.clearTrip();
  } catch (e) {
    emit(TripUpdate(
      status: state.status,
      activeTrip: state.activeTrip,
      error: "Failed to go offline",
      isLoading: false,
    ));
  }
}
  void _startLocationTracking() {
    _stopLocationTracking(); // Clean up existing
    _locationSubscription = _locationService.getPositionStream().listen((Position position) {
      // 1. Dispatch locally to update UI immediately
      add(UpdateLocation(position.latitude, position.longitude, position.heading));

      final now = DateTime.now().toUtc();
      
      // 2. Throttle updates: Call API only every 3-5 seconds or based on distanceFilter (10m defined in LocationService)
      if (_lastLocationUpdate == null || now.difference(_lastLocationUpdate!).inSeconds >= 3) {
        _lastLocationUpdate = now;
        
        // Use the current active trip ID if we are on a trip
        String? currentTripId;
        if (state.activeTrip != null && state.status != TripStatus.searching && state.status != TripStatus.offline) {
          currentTripId = state.activeTrip!.tripId;
        }

        try {
          _driverApi.updateLocation(
            tripId: currentTripId,
            lat: position.latitude,
            lng: position.longitude,
            speed: position.speed,
            heading: position.heading,
            timestamp: now,
          );
        } catch (e) {
          print("DEBUG: [TripBloc] updateLocation API error: $e");
        }
      }
    });
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _lastLocationUpdate = null;
  }

  void _onSimulateRequest(SimulateRequest event, Emitter<TripState> emit) {
    print("DEBUG: [TripBloc] SimulateRequest received. Current Status: ${state.status}");
    
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

    final newState = TripUpdate(status: TripStatus.requestReceived, activeTrip: trip);
    emit(newState);
    _persistState(newState);

    _requestTimeoutTimer?.cancel();
    _requestTimeoutTimer = Timer(const Duration(minutes: 5), () {
      print("DEBUG: [TripBloc] Request timeout reached. Auto-declining.");
      add(DeclineRequest());
    });
  }

  Future<void> _onAcceptRequest(AcceptRequest event, Emitter<TripState> emit) async {
    if (state.activeTrip == null || state.activeTrip!.requestId == null) return;
    
    final requestId = state.activeTrip!.requestId!;
    _requestTimeoutTimer?.cancel();
    emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, isLoading: true));

    try {
      final response = await _driverApi.acceptRequest(requestId);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedTrip = state.activeTrip!.copyWith(
          status: TripStatus.accepted,
          currentStep: 0,
          supportDrivers: state.activeTrip!.supportDrivers.map((d) => 
            d.copyWith(status: SupportDriverStatus.ACCEPTED)
          ).toList(),
        );

        List<LatLng> routePoints = [];
        String? distanceRemaining;
        String? eta;
        if (state.currentLatitude != null && state.currentLongitude != null) {
          final currentTarget = updatedTrip.supportDrivers.firstWhere(
            (d) => d.id == updatedTrip.currentTargetDriverId,
            orElse: () => updatedTrip.supportDrivers.first,
          );
          final isDrop = updatedTrip.currentStep % 2 == 1;
          final destLat = isDrop ? currentTarget.dropLat : currentTarget.pickupLat;
          final destLng = isDrop ? currentTarget.dropLng : currentTarget.pickupLng;
          if (destLat != null && destLng != null) {
            final route = await _navigationService.fetchDirections(
              LatLng(state.currentLatitude!, state.currentLongitude!),
              LatLng(destLat, destLng),
            );
            if (route != null) {
              routePoints = route.polylinePoints;
              distanceRemaining = route.distanceText;
              eta = route.durationText;
            }
          }
        }

        final newState = TripUpdate(
          status: TripStatus.accepted, 
          activeTrip: updatedTrip,
          isLoading: false,
          routePoints: routePoints,
          distanceRemaining: distanceRemaining,
          eta: eta,
        );
        emit(newState);
        _persistState(newState);
      } else {
        emit(TripUpdate(
          status: TripStatus.searching,
          activeTrip: null,
          error: "Failed to accept request",
          isLoading: false,
        ));
      }
    } catch (e) {
      String errorMsg = "Accept failed: $e";
      if (e is DioException) {
        final code = e.response?.statusCode;
        if (code == 409) {
          errorMsg = "Already accepted by another driver";
        } else if (code == 400) {
          errorMsg = "Request expired";
        } else if (code == 401) {
          errorMsg = "Token expired";
        } else if (code == 403) {
          errorMsg = "Role issue";
        }
      }
      emit(TripUpdate(
        status: TripStatus.searching,
        activeTrip: null,
        error: errorMsg,
        isLoading: false,
      ));
    }
  }

  Future<void> _onDeclineRequest(DeclineRequest event, Emitter<TripState> emit) async {
    _requestTimeoutTimer?.cancel();
    if (state.activeTrip == null || state.activeTrip!.requestId == null) {
      final newState = const TripUpdate(status: TripStatus.searching);
      emit(newState);
      _storageService.clearTrip();
      return;
    }

    final requestId = state.activeTrip!.requestId!;
    emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, isLoading: true));

    try {
      await _driverApi.rejectRequest(requestId);
      final newState = const TripUpdate(status: TripStatus.searching);
      emit(newState);
      _storageService.clearTrip();
      add(FetchPendingRequests());
    } catch (e) {
      final newState = const TripUpdate(status: TripStatus.searching);
      emit(newState);
      _storageService.clearTrip();
      add(FetchPendingRequests());
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
    if (state.status == TripStatus.completed || state.status == TripStatus.requestReceived || state.status == TripStatus.cancelled) {
      _stopLocationTracking();
      _storageService.clearTrip();
      
      final newState = const TripUpdate(status: TripStatus.searching, activeTrip: null);
      emit(newState);
      _persistState(newState);
      
      add(FetchPendingRequests());
    }
  }

  void _onCancelActiveTrip(CancelActiveTrip event, Emitter<TripState> emit) {
    _stopLocationTracking();
    _storageService.clearTrip();
    emit(TripUpdate(
      status: TripStatus.cancelled,
      activeTrip: state.activeTrip,
      isLoading: false,
    ));
  }

  Future<void> _onLogoutReset(LogoutReset event, Emitter<TripState> emit) async {
    _requestTimeoutTimer?.cancel();
    _stopLocationTracking();
    _disconnectWebSocket();
    
    // Clear SharedPreferences (delete all cache) while preserving theme preferences
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('user_theme_mode');
    await prefs.clear();
    if (themeMode != null) {
      await prefs.setString('user_theme_mode', themeMode);
    }

    emit(const TripUpdate(
      status: TripStatus.offline,
      activeTrip: null,
      isLoading: false,
    ));
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  Future<void> _onFetchPendingRequests(FetchPendingRequests event, Emitter<TripState> emit) async {
    if (state.status != TripStatus.searching && state.status != TripStatus.requestReceived) {
      return;
    }

    emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, isLoading: true));

    try {
      final response = await _driverApi.getPendingRequests();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic rawData = response.data;
        if (rawData is Map && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        
        final List<dynamic> requests = rawData is List ? rawData : [];

        print("========== PENDING FLOW ==========");
        print("REQUEST COUNT => ${requests.length}");

        if (requests.isNotEmpty) {
          final item = requests.first as Map<String, dynamic>;
          final trip = Trip.fromJson(item);

          print("TRIP FOUND => ${trip.requestId}");

          print("========== STATE UPDATE ==========");
          print("OLD STATUS => ${state.status}");
          print("NEW STATUS => requestReceived");

          print("========== POPUP CHECK ==========");
          print("STATUS => requestReceived");
          print("ACTIVE TRIP => $trip");

          final newState = TripUpdate(
            status: TripStatus.requestReceived, 
            activeTrip: trip,
            isLoading: false,
          );
          emit(newState);
          _persistState(newState);
        } else {
          emit(TripUpdate(
            status: TripStatus.searching,
            activeTrip: null,
            isLoading: false,
          ));
        }
        print("==================================");
      } else {
        emit(TripUpdate(
          status: state.status,
          activeTrip: state.activeTrip,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(TripUpdate(
        status: state.status,
        activeTrip: state.activeTrip,
        isLoading: false,
      ));
    }
  }

  Future<void> _onNextTripStep(NextTripStep event, Emitter<TripState> emit) async {
    final trip = state.activeTrip;
    if (trip == null) return;

    final N = trip.supportDrivers.length;
    final step = trip.currentStep;
    final ticketId = trip.ticketId ?? trip.tripId;

    emit(TripUpdate(status: state.status, activeTrip: state.activeTrip, isLoading: true));

    int currentPassengerIndex = step ~/ 2;
    String currentAction = "";
    String targetStatusString = "";
    TripStatus nextTripStatus = state.status;
    int nextStep = step;

    if (step < 2 * N) {
      if (step % 2 == 0) {
        currentAction = "pickup";
        targetStatusString = TicketStatus.driverArrived.name;
        nextTripStatus = TripStatus.support_driver_pickup;
        nextStep = step + 1;
      } else {
        currentAction = "drop";
        targetStatusString = TicketStatus.inTransit.name;
        nextTripStatus = TripStatus.support_driver_drop;
        nextStep = step + 1;
      }
    } else {
      currentAction = "completed";
      targetStatusString = TicketStatus.completed.name;
      nextTripStatus = TripStatus.completed;
      nextStep = step + 1;
    }

    print("========== LOOP STATUS ==========");
    print("CURRENT PASSENGER => $currentPassengerIndex");
    print("CURRENT ACTION => $currentAction");

    try {
      final response = await _driverApi.updateTicketDetails(ticketId, targetStatusString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final driverIndex = step ~/ 2;
        final updatedSupportDrivers = List<SupportDriver>.from(trip.supportDrivers);
        if (driverIndex < N) {
          final d = updatedSupportDrivers[driverIndex];
          SupportDriverStatus nextSdStatus = d.status;
          if (step % 2 == 0) {
            nextSdStatus = SupportDriverStatus.PICKED;
          } else {
            nextSdStatus = SupportDriverStatus.DROPPED;
          }
          updatedSupportDrivers[driverIndex] = d.copyWith(status: nextSdStatus);
        }

        String? nextTargetId = trip.currentTargetDriverId;
        final nextDriverIndex = nextStep ~/ 2;
        if (nextDriverIndex < N) {
          nextTargetId = updatedSupportDrivers[nextDriverIndex].id;
        }

        final updatedTrip = trip.copyWith(
          status: nextTripStatus,
          currentStep: nextStep,
          currentTargetDriverId: nextTargetId,
          supportDrivers: updatedSupportDrivers,
        );

        List<LatLng> routePoints = [];
        String? distanceRemaining;
        String? eta;
        if (state.currentLatitude != null && state.currentLongitude != null) {
          final currentTarget = updatedTrip.supportDrivers.firstWhere(
            (d) => d.id == updatedTrip.currentTargetDriverId,
            orElse: () => updatedTrip.supportDrivers.first,
          );
          final isDrop = updatedTrip.currentStep % 2 == 1;
          final destLat = isDrop ? currentTarget.dropLat : currentTarget.pickupLat;
          final destLng = isDrop ? currentTarget.dropLng : currentTarget.pickupLng;
          if (destLat != null && destLng != null) {
            final route = await _navigationService.fetchDirections(
              LatLng(state.currentLatitude!, state.currentLongitude!),
              LatLng(destLat, destLng),
            );
            if (route != null) {
              routePoints = route.polylinePoints;
              distanceRemaining = route.distanceText;
              eta = route.durationText;
            }
          }
        }

        final newState = TripUpdate(
          status: nextTripStatus,
          activeTrip: updatedTrip,
          isLoading: false,
          routePoints: routePoints,
          distanceRemaining: distanceRemaining,
          eta: eta,
        );
        emit(newState);
        _persistState(newState);

        if (nextTripStatus == TripStatus.completed) {
          await _storageService.clearTrip();
        }
      } else {
        emit(TripUpdate(
          status: state.status,
          activeTrip: state.activeTrip,
          error: "Failed to update status",
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(TripUpdate(
        status: state.status,
        activeTrip: state.activeTrip,
        error: "Status update failed: $e",
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateLocation(UpdateLocation event, Emitter<TripState> emit) async {
    List<LatLng> updatedRoutePoints = List<LatLng>.from(state.routePoints);
    String? distanceStr = state.distanceRemaining;
    String? etaStr = state.eta;

    final trip = state.activeTrip;
    if (trip != null &&
        trip.supportDrivers.isNotEmpty &&
        state.status != TripStatus.searching &&
        state.status != TripStatus.offline &&
        state.status != TripStatus.completed &&
        state.status != TripStatus.cancelled) {
      
      final currentTarget = trip.supportDrivers.firstWhere(
        (d) => d.id == trip.currentTargetDriverId,
        orElse: () => trip.supportDrivers.first,
      );
      final isDrop = trip.currentStep % 2 == 1;
      final destLat = isDrop ? currentTarget.dropLat : currentTarget.pickupLat;
      final destLng = isDrop ? currentTarget.dropLng : currentTarget.pickupLng;

      if (destLat != null && destLng != null) {
        final driverPos = LatLng(event.lat, event.lng);
        final destPos = LatLng(destLat, destLng);

        if (updatedRoutePoints.isEmpty) {
          final route = await _navigationService.fetchDirections(driverPos, destPos);
          if (route != null) {
            updatedRoutePoints = route.polylinePoints;
            distanceStr = route.distanceText;
            etaStr = route.durationText;
          }
        } else {
          // Check route deviation (threshold 100 meters)
          final isDeviated = _navigationService.checkRouteDeviation(driverPos, updatedRoutePoints, 100.0);
          if (isDeviated) {
            final route = await _navigationService.fetchDirections(driverPos, destPos);
            if (route != null) {
              updatedRoutePoints = route.polylinePoints;
              distanceStr = route.distanceText;
              etaStr = route.durationText;
            }
          } else {
            // Shrink route: find closest point to driver
            int closestIdx = 0;
            double minDistance = double.infinity;
            for (int i = 0; i < updatedRoutePoints.length; i++) {
              final dist = _navigationService.distanceBetween(driverPos, updatedRoutePoints[i]);
              if (dist < minDistance) {
                minDistance = dist;
                closestIdx = i;
              }
            }
            if (closestIdx > 0) {
              updatedRoutePoints = updatedRoutePoints.sublist(closestIdx);
            }

            // Recalculate remaining distance/duration
            double remainingMeters = 0.0;
            if (updatedRoutePoints.isNotEmpty) {
              remainingMeters = _navigationService.distanceBetween(driverPos, updatedRoutePoints.first);
              for (int i = 0; i < updatedRoutePoints.length - 1; i++) {
                remainingMeters += _navigationService.distanceBetween(updatedRoutePoints[i], updatedRoutePoints[i + 1]);
              }
            }
            final distKm = remainingMeters / 1000;
            distanceStr = "${distKm.toStringAsFixed(1)} km";
            final durationMins = (remainingMeters / 12.5 / 60).round();
            etaStr = "$durationMins mins";
          }
        }
      }
    }

    emit(TripUpdate(
      status: state.status,
      activeTrip: state.activeTrip,
      error: state.error,
      isLoading: state.isLoading,
      currentLatitude: event.lat,
      currentLongitude: event.lng,
      currentHeading: event.heading,
      routePoints: updatedRoutePoints,
      distanceRemaining: distanceStr,
      eta: etaStr,
    ));
  }

  void _persistState(TripState state) {
    if (state.activeTrip != null) {
      _storageService.saveTrip(state.activeTrip!);
    }
  }

  Future<void> _connectWebSocket() async {
    if (AppConstants.isMockMode) {
      debugPrint("DEBUG: [TripBloc] WS connection skipped (Mock Mode Active)");
      return;
    }

    if (_isConnectingWs || _webSocketChannel != null) return;
    _isConnectingWs = true;

    try {
      final secureStorage = SecureStorageService();
      final token = await secureStorage.getToken();
      final driverId = await secureStorage.getDriverId();
      
      if (token == null || driverId == null) {
        _isConnectingWs = false;
        return;
      }

      final wsUrl = "${AppConstants.mainDriverWsEndpoint}/$driverId?token=$token";
      debugPrint("DEBUG: [TripBloc] Connecting to WS: $wsUrl");
      
      _webSocketChannel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
      
      _isWsConnected = true;
      _isConnectingWs = false;
      
      _startPingTimer();

      _webSocketChannel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          debugPrint("DEBUG: [TripBloc] WS Error: $error");
          _isWsConnected = false;
          _webSocketChannel = null;
          _reconnectWebSocket();
        },
        onDone: () {
          debugPrint("DEBUG: [TripBloc] WS Connection Closed");
          _isWsConnected = false;
          _webSocketChannel = null;
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      debugPrint("DEBUG: [TripBloc] WS connection error: $e");
      _isWsConnected = false;
      _isConnectingWs = false;
      _reconnectWebSocket();
    }
  }


  void _reconnectWebSocket() {
    _wsReconnectTimer?.cancel();
    if (state.status == TripStatus.offline) return;

    _wsReconnectTimer = Timer(const Duration(seconds: 5), () {
      if (state.status != TripStatus.offline) {
        _connectWebSocket();
      }
    });
  }

  void _startPingTimer() {
    _wsPingTimer?.cancel();
    _wsPingTimer = Timer.periodic(const Duration(seconds: 25), (t) {
      if (_webSocketChannel != null) {
        _webSocketChannel!.sink.add(jsonEncode({"type": "ping"}));
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _disconnectWebSocket() async {
    _wsReconnectTimer?.cancel();
    _wsPingTimer?.cancel();
    if (_webSocketChannel != null) {
      await _webSocketChannel!.sink.close();
      _webSocketChannel = null;
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message.toString());

      if (data.containsKey('event')) {
        final event = data['event'];
        final requestId = data['requestId']?.toString() ?? data['request_id']?.toString() ?? '';

        print("========== WS EVENT ==========");
        print("EVENT => $event");
        print("REQUEST ID => $requestId");
        print("================================");

        if (event == "main_driver_trip_request") {
          if (requestId.isNotEmpty) {
            _sendWsFrame({"type": "ack", "request_id": requestId});
            print("ACK SENT => $requestId");
          }

          add(FetchPendingRequests());

          if (requestId.isNotEmpty) {
            _sendWsFrame({"type": "seen", "request_id": requestId});
            print("SEEN SENT => $requestId");
          }
        } 
        else if (event == "main_driver_trip_request_accepted") {
          print("TRIP ACCEPTED EVENT RECEIVED");
        } 
        else if (event == "main_driver_trip_request_expired" || event == "main_driver_trip_cancelled") {
          print("TRIP EXPIRED / CANCELLED");
          if (state.status == TripStatus.requestReceived) {
            print("CLOSING POPUP");
            add(ResetToSearching());
          } else if (state.status == TripStatus.accepted ||
                     state.status == TripStatus.support_driver_pickup ||
                     state.status == TripStatus.support_driver_drop) {
            add(CancelActiveTrip());
          }
        }
      }
    } catch (e) {
      print("DEBUG: [TripBloc] Failed to handle WS message: $e");
    }
  }

  void _sendWsFrame(Map<String, dynamic> frame) {
    if (_webSocketChannel != null) {
      _webSocketChannel!.sink.add(jsonEncode(frame));
    }
  }

  @override
  Future<void> close() {
    _requestTimeoutTimer?.cancel();
    _stopLocationTracking();
    _disconnectWebSocket();
    return super.close();
  }
}
