import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'get_ratings_event.dart';
import 'get_ratings_state.dart';
import '../../../data/models/get_ratings.dart'; // Ensure compatibility with existing model
import '../../../../../core/network/api_client.dart';

/// Clean repository class for fetching ratings
class RatingsRepository {
  final ApiClient apiClient;

  RatingsRepository({required this.apiClient});

  Future<GetRatings> fetchRatings() async {
    try {
      final response = await apiClient.dio.get(
        '/driver/ratings',
      ); // Update endpoint if needed

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetRatings.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch ratings (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch ratings: ${e.message}');
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
      // Extract meaningful error messages based on your specific backend exceptions
      emit(GetRatingsError(message: e.toString()));
    }
  }
}
