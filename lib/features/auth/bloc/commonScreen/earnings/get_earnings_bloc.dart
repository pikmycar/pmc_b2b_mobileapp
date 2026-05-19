import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import 'get_earnings_event.dart';
import 'get_earnings_state.dart';
import '../../../data/models/get_earnings.dart';

class EarningsRepository {
  final ApiClient apiClient;

  EarningsRepository({required this.apiClient});

  Future<GetEarningsResponse> fetchEarnings() async {
    try {
      final response = await apiClient.dio.get(AppConstants.earningsEndpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetEarningsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch earnings (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch earnings: ${e.message}');
    }
  }
}

class GetEarningsBloc extends Bloc<GetEarningsEvent, GetEarningsState> {
  final EarningsRepository repository;

  GetEarningsBloc({required this.repository}) : super(const GetEarningsInitial()) {
    on<FetchEarningsEvent>(_onFetchEarnings);
  }

  Future<void> _onFetchEarnings(
    FetchEarningsEvent event,
    Emitter<GetEarningsState> emit,
  ) async {
    emit(const GetEarningsLoading());
    try {
      final earnings = await repository.fetchEarnings();
      emit(GetEarningsSuccess(earnings: earnings));
    } catch (e) {
      emit(GetEarningsError(message: e.toString()));
    }
  }
}
