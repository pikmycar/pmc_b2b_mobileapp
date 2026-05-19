import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'get_ratings_event.dart';
import 'get_ratings_state.dart';
import '../../../data/models/get_ratings.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart'; // ✅ ADD THIS

/// Clean repository class for fetching ratings
class RatingsRepository {
  final ApiClient apiClient;

  RatingsRepository({required this.apiClient});

  Future<GetRatings> fetchRatings() async {
    try {
      final response = await apiClient.dio.get(
        AppConstants.ratingsEndpoint, // ✅ USE CONSTANT
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetRatings.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch ratings (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Ratings fetch failed';

      throw Exception(errorMessage);
    }
  }
}

class GetRatingsBloc extends Bloc<GetRatingsEvent, GetRatingsState> {
  final RatingsRepository repository;

  GetRatingsBloc({required this.repository})
      : super(const GetRatingsInitial()) {
    on<FetchRatingsEvent>(_onFetchRatings);
  }

  Future<void> _onFetchRatings(
    FetchRatingsEvent event,
    Emitter<GetRatingsState> emit,
  ) async {
    emit(const GetRatingsLoading());

    try {
      final ratingsData = await repository.fetchRatings();

      emit(GetRatingsSuccess(ratingsData: ratingsData));
    } catch (e) {
      emit(GetRatingsError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}