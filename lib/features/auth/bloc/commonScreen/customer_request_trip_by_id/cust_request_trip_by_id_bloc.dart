import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/cust_request_trip_by_id.dart';
import 'cust_request_trip_by_id_event.dart';
import 'cust_request_trip_by_id_state.dart';

/// Repository for handling customer requested trip details by ID API
class CustomerRequestTripByIdRepository {
  final ApiClient apiClient;

  CustomerRequestTripByIdRepository({required this.apiClient});

  /// Fetch customer requested trip details by ID
  Future<CustRequestTripById> fetchTripById(String tripId) async {
    try {
      final response = await apiClient.dio.post(
        AppConstants.fetchTicketByIdEndpoint,
        data: {
          "ticketId": tripId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustRequestTripById.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch trip details (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Failed to fetch trip details';
      throw Exception(errorMessage);
    }
  }
}

/// Core BLoC class executing state transitions for customer requested trip details by ID
class CustRequestTripByIdBloc
    extends Bloc<CustRequestTripByIdEvent, CustRequestTripByIdState> {
  final CustomerRequestTripByIdRepository repository;

  CustRequestTripByIdBloc({required this.repository})
      : super(const CustRequestTripByIdInitial()) {
    on<FetchCustRequestTripByIdEvent>(_onFetchTripById);
  }

  /// Handles fetching ticket details by ID
  Future<void> _onFetchTripById(
    FetchCustRequestTripByIdEvent event,
    Emitter<CustRequestTripByIdState> emit,
  ) async {
    emit(const CustRequestTripByIdLoading());
    try {
      final details = await repository.fetchTripById(event.tripId);
      emit(CustRequestTripByIdSuccess(tripDetails: details));
    } catch (e) {
      emit(CustRequestTripByIdError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
