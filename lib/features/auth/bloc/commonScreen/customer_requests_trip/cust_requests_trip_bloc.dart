import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
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
      final driverId = await apiClient.storageService.getDriverId();
      final response = await apiClient.dio.post(
        AppConstants.fetchTicketsEndpoint,
        data: {
          "userId": driverId,
          "pageNumber": 1,
          "pageSize": 20,
        },
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

  CustRequestsTripBloc({required this.repository})
      : super(const CustRequestsTripInitial()) {
    on<FetchCustRequestsTripEvent>(_onFetchTrips);
    on<AcceptCustRequestsTripEvent>(_onAcceptTrip);
    on<DeclineCustRequestsTripEvent>(_onDeclineTrip);
    on<CompleteCustRequestsTripEvent>(_onCompleteTrip);
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
