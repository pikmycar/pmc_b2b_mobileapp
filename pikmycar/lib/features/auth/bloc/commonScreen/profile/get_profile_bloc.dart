import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import 'get_profile_event.dart';
import 'get_profile_state.dart';
import '../../../data/models/get_profile.dart'; // Ensure compatibility with existing model


/// Simple repository interface for fetching profile details
class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  Future<GetProfileDetails> fetchProfile() async {
    try {
      // ApiClient already has the base URL from AppConstants and handles tokens!
      final response = await apiClient.dio.get('/driver/profile');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetProfileDetails.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch profile (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch profile: ${e.message}');
    }
  }
}

class GetProfileBloc extends Bloc<GetProfileEvent, GetProfileState> {
  final ProfileRepository repository;

  GetProfileBloc({required this.repository}) : super(const GetProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<GetProfileState> emit,
  ) async {
    emit(const GetProfileLoading());
    try {
      final profileDetails = await repository.fetchProfile();
      emit(GetProfileSuccess(profileDetails: profileDetails));
    } catch (e) {
      // Handle proper exception parsing based on your architecture
      // For instance, if you have custom exception classes, catch them here
      emit(GetProfileError(message: e.toString()));
    }
  }
}
