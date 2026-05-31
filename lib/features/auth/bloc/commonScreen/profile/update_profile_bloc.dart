import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../data/models/update_profile.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/storage/secure_storage_service.dart';

class UpdateProfileRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;

  UpdateProfileRepository({required this.apiClient, required this.storage});

  Future<UpdateProfile> updateProfile({
    String? name,
    String? email,
    String? contact,
    String? profileImage,
  }) async {
    try {
      // Read driverId — required as ?id= query param for the update endpoint
      final driverId = await storage.getDriverId();
      if (driverId == null || driverId.isEmpty) {
        throw Exception('Driver ID not found. Please log in again.');
      }

      final Map<String, dynamic> body = {};

      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;
      // New field name: contact (was phoneNumber)
      if (contact != null && contact.isNotEmpty) body['contact'] = contact;
      // New field name: profileImage (was profileImageUrl)
      if (profileImage != null && profileImage.isNotEmpty) {
        body['profileImage'] = profileImage;
      }

      final response = await apiClient.dio.put(
        '${AppConstants.updateProfileEndpoint}/$driverId',
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateProfile.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to update profile (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Update failed';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class UpdateProfileBloc
    extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final UpdateProfileRepository repository;

  UpdateProfileBloc({required this.repository})
      : super(const UpdateProfileInitial()) {
    on<SubmitUpdateProfileEvent>(_onSubmitUpdateProfile);
  }

  Future<void> _onSubmitUpdateProfile(
    SubmitUpdateProfileEvent event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(const UpdateProfileLoading());

    try {
      final response = await repository.updateProfile(
        name: event.name,
        email: event.email,
        contact: event.contact,
        profileImage: event.profileImage,
      );

      // New model uses status: "success" string (not a bool success field)
      if (response.status == "success" || response.data != null) {
        emit(UpdateProfileSuccess(response: response));
      } else {
        emit(UpdateProfileError(
          message: response.message ?? "Unknown error occurred",
        ));
      }
    } catch (e) {
      emit(UpdateProfileError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}