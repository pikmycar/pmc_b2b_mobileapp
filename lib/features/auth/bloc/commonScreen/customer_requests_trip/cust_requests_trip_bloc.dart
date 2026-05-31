import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/storage/secure_storage_service.dart';
import '../../../data/models/cust_requests_trip.dart';
import 'cust_requests_trip_event.dart';
import 'cust_requests_trip_state.dart';

/// Repository for handling customer requested trips APIs
class CustomerRequestsTripRepository {
  final ApiClient apiClient;

  CustomerRequestsTripRepository({required this.apiClient});

  /// Fetch customer requested trips from server
  Future<CustRequestTrip> fetchTrips() async {
    try {
      final response = await apiClient.dio.get(
        AppConstants.fetchTicketsEndpoint,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustRequestTrip.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch requested trips (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Failed to fetch requested trips';
      throw Exception(errorMessage);
    }
  }

  /// Accept a customer requested trip
  Future<void> acceptTrip(String tripId) async {
    try {
      final response = await apiClient.dio.post('/driver/trips/$tripId/accept');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to accept trip (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Failed to accept trip';
      throw Exception(errorMessage);
    }
  }

  /// Decline a customer requested trip
  Future<void> declineTrip(String tripId) async {
    try {
      final response = await apiClient.dio.post('/driver/trips/$tripId/decline');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to decline trip (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Failed to decline trip';
      throw Exception(errorMessage);
    }
  }

  /// Complete an active customer requested trip
  Future<void> completeTrip(String tripId) async {
    try {
      final response = await apiClient.dio.post('/driver/trips/$tripId/complete');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to complete trip (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Failed to complete trip';
      throw Exception(errorMessage);
    }
  }
}

/// Core BLoC class executing state transitions for customer requested trips
class CustRequestsTripBloc
    extends Bloc<CustRequestsTripEvent, CustRequestsTripState> {
  final CustomerRequestsTripRepository repository;
  IOWebSocketChannel? _webSocketChannel;
  Timer? _reconnectTimer;
  bool _isConnecting = false;

  CustRequestsTripBloc({required this.repository})
      : super(const CustRequestsTripInitial()) {
    on<FetchCustRequestsTripEvent>(_onFetchTrips);
    on<AcceptCustRequestsTripEvent>(_onAcceptTrip);
    on<DeclineCustRequestsTripEvent>(_onDeclineTrip);
    on<CompleteCustRequestsTripEvent>(_onCompleteTrip);

    // Establish WebSocket connection to SignalR KanbanHub for live updates
    _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    if (_isConnecting || _webSocketChannel != null) return;
    _isConnecting = true;

    try {
      final secureStorage = SecureStorageService();
      final token = await secureStorage.getToken();
      final driverId = await secureStorage.getDriverId();

      if (token == null || driverId == null) {
        _isConnecting = false;
        return;
      }

      // Format standard SignalR WebSocket endpoint connection URL
      final wsUrl = "wss://pmcapi.pikmycar.com/kanbanHub?access_token=$token";
      
      final client = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final webSocket = await WebSocket.connect(wsUrl, customClient: client);
      _webSocketChannel = IOWebSocketChannel(webSocket);
      _isConnecting = false;

      // 1. Send SignalR Handshake message (terminated by ASCII 30)
      final handshake = jsonEncode({"protocol": "json", "version": 1}) + String.fromCharCode(30);
      _webSocketChannel!.sink.add(handshake);

      _webSocketChannel!.stream.listen(
        (message) {
          final dataStr = message.toString();
          final records = dataStr.split(String.fromCharCode(30));
          for (var record in records) {
            if (record.isEmpty) continue;
            try {
              final Map<String, dynamic> json = jsonDecode(record);

              // On handshake success response (empty map), join the support driver group
              if (json.isEmpty) {
                final joinMsg = jsonEncode({
                  "type": 1,
                  "target": "JoinKanbanGroup",
                  "arguments": ["R008", driverId]
                }) + String.fromCharCode(30);
                _webSocketChannel!.sink.add(joinMsg);
              }

              // On receiving the assignment broadcast from Hub
              if (json['type'] == 1 && json['target'] == "SupportDriverAssigned") {
                print("🔔 [SignalR] Received assignment update broadcast!");
                // Trigger auto-refresh of requested trips
                add(const FetchCustRequestsTripEvent());
              }
            } catch (_) {}
          }
        },
        onError: (err) {
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _webSocketChannel = null;
    _reconnectSignalR();
  }

  void _reconnectSignalR() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _connectSignalR();
    });
  }

  @override
  Future<void> close() {
    _webSocketChannel?.sink.close();
    _reconnectTimer?.cancel();
    return super.close();
  }

  /// Handles fetching customer trips
  Future<void> _onFetchTrips(
    FetchCustRequestsTripEvent event,
    Emitter<CustRequestsTripState> emit,
  ) async {
    emit(const CustRequestsTripLoading());
    try {
      final trips = await repository.fetchTrips();
      emit(CustRequestsTripSuccess(tripData: trips));
    } catch (e) {
      emit(CustRequestsTripError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handles accepting a trip
  Future<void> _onAcceptTrip(
    AcceptCustRequestsTripEvent event,
    Emitter<CustRequestsTripState> emit,
  ) async {
    emit(const CustRequestsTripLoading());
    try {
      await repository.acceptTrip(event.tripId);
      emit(CustRequestsTripAccepted(tripId: event.tripId));
    } catch (e) {
      emit(CustRequestsTripError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handles declining a trip
  Future<void> _onDeclineTrip(
    DeclineCustRequestsTripEvent event,
    Emitter<CustRequestsTripState> emit,
  ) async {
    emit(const CustRequestsTripLoading());
    try {
      await repository.declineTrip(event.tripId);
      emit(CustRequestsTripDeclined(tripId: event.tripId));
    } catch (e) {
      emit(CustRequestsTripError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handles completing a trip
  Future<void> _onCompleteTrip(
    CompleteCustRequestsTripEvent event,
    Emitter<CustRequestsTripState> emit,
  ) async {
    emit(const CustRequestsTripLoading());
    try {
      await repository.completeTrip(event.tripId);
      emit(CustRequestsTripCompleted(tripId: event.tripId));
    } catch (e) {
      emit(CustRequestsTripError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
