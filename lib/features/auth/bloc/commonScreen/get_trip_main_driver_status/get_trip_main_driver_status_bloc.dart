import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/getTrip_mainDriver_status.dart';
import 'get_trip_main_driver_status_event.dart';
import 'get_trip_main_driver_status_state.dart';

class GetTripMainDriverStatusRepository {
  final ApiClient apiClient;

  GetTripMainDriverStatusRepository({required this.apiClient});

  String _extractErrorMessage(DioException e) {
    final errorData = e.response?.data;
    String? msg;
    if (errorData is Map) {
      msg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            errorData['detail']?.toString();
    }
    return msg ?? e.message ?? 'Failed to get main driver status';
  }

  Future<GetTripMainDriverStatus> getStatus(String ticketId) async {
    try {
      final response = await apiClient.dio.get(
        "${AppConstants.getTripMainDriverStatusEndpoint}/$ticketId",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetTripMainDriverStatus.fromJson(response.data);
      } else {
        throw Exception("Failed to load status (Status: ${response.statusCode})");
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }
}

class GetTripMainDriverStatusBloc
    extends Bloc<GetTripMainDriverStatusEvent, GetTripMainDriverStatusState> {
  final GetTripMainDriverStatusRepository repository;

  GetTripMainDriverStatusBloc({required this.repository})
      : super(const GetTripMainDriverStatusInitial()) {
    on<FetchTripMainDriverStatusEvent>(_onFetchStatus);
  }

  Future<void> _onFetchStatus(
    FetchTripMainDriverStatusEvent event,
    Emitter<GetTripMainDriverStatusState> emit,
  ) async {
    // Keep the current state if already loaded to avoid blank loading screens during polling
    if (state is GetTripMainDriverStatusInitial) {
      emit(const GetTripMainDriverStatusLoading());
    }

    try {
      final response = await repository.getStatus(event.ticketId);
      final status = response.data?.status?.toLowerCase() ?? 'searching';

      if (status == 'main_driver_assigned') {
        emit(GetTripMainDriverStatusAssigned(statusDetails: response));
      } else {
        emit(GetTripMainDriverStatusSearching(statusDetails: response));
      }
    } catch (e) {
      emit(GetTripMainDriverStatusError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
