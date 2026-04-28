import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../data/models/update_profile.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';
import '../../../../../core/network/api_client.dart';

class UpdateProfileRepository {
  final ApiClient apiClient;

  UpdateProfileRepository({required this.apiClient});

  Future<UpdateProfileResponse> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (phone != null && phone.isNotEmpty) body['phone_number'] = phone; // Adjust to your API's expected key

      // Changed from patch to put as 405 means Method Not Allowed
      final response = await apiClient.dio.put('/driver/profile', data: body); 

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateProfileResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Failed to update profile: $errorMessage');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final UpdateProfileRepository repository;

  UpdateProfileBloc({required this.repository}) : super(const UpdateProfileInitial()) {
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
        phone: event.phone,
      );
      
      if (response.success == true) {
        emit(UpdateProfileSuccess(response: response));
      } else {
        emit(UpdateProfileError(message: response.message ?? "Unknown error occurred"));
      }
    } catch (e) {
      emit(UpdateProfileError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
