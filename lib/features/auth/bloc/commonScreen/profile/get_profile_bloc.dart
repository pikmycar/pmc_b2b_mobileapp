import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/storage/secure_storage_service.dart';
import 'get_profile_event.dart';
import 'get_profile_state.dart';
import '../../../data/models/get_profile.dart';

/// Simple repository interface for fetching profile details
class ProfileRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;

  ProfileRepository({required this.apiClient, required this.storage});

  Future<GetProfile> fetchProfile() async {
    try {
      // Read driverId from secure storage — required as ?id= query param
      final driverId = await storage.getDriverId();
      if (driverId == null || driverId.isEmpty) {
        throw Exception('Driver ID not found. Please log in again.');
      }

      final response = await apiClient.dio.get(
        AppConstants.profileEndpoint,
        queryParameters: {'id': driverId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetProfile.fromJson(response.data);
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
      emit(GetProfileSuccess(profile: profileDetails));
    } catch (e) {
      emit(GetProfileError(message: e.toString()));
    }
  }
}