import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/support_pickMe_request.dart';
import 'support_pickme_request_event.dart';
import 'support_pickme_request_state.dart';

/// Repository for handling Support Driver "Pick Me" Request APIs
class SupportPickMeRepository {
  final ApiClient apiClient;

  SupportPickMeRepository({required this.apiClient});

  String _extractErrorMessage(DioException e) {
    final errorData = e.response?.data;
    String? msg;
    if (errorData is Map) {
      msg = errorData['error']?.toString() ??
            errorData['message']?.toString() ??
            errorData['detail']?.toString();
    }
    return msg ?? e.message ?? 'Failed to process request';
  }

  /// Sends Support Driver "Pick Me" Request to nearby Main Drivers
  Future<SupportPickmeRequest> sendPickMeRequest({
    required String ticketId,
    required String supportDriverId,
    required String pickupLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupGoogleMapsAddress,
    required String dropLocation,
    required double dropLatitude,
    required double dropLongitude,
    required String dropGoogleMapsAddress,
    required String notes,
    required bool sameVendorOnly,
    required String targetMainDriverId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        AppConstants.sendMainDriverRequestEndpoint,
        data: {
          "ticketId": ticketId,
          "supportDriverId": supportDriverId,
          "pickupLocation": pickupLocation,
          "pickupLatitude": pickupLatitude,
          "pickupLongitude": pickupLongitude,
          "pickupGoogleMapsAddress": pickupGoogleMapsAddress,
          "dropLocation": dropLocation,
          "dropLatitude": dropLatitude,
          "dropLongitude": dropLongitude,
          "dropGoogleMapsAddress": dropGoogleMapsAddress,
          "notes": notes,
          "sameVendorOnly": sameVendorOnly,
          "targetMainDriverId": targetMainDriverId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SupportPickmeRequest.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to send Pick Me request (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      if (e.response?.statusCode == 409) {
        throw Exception("409: $msg");
      }
      throw Exception(msg);
    }
  }

  /// Accept Pick Me Request (for Main Driver coordination)
  Future<void> acceptRequest(String tripId) async {
    try {
      final response = await apiClient.dio.post(
        "/driver/main-driver-request/accept",
        data: {"tripId": tripId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to accept request");
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Decline Pick Me Request (for Main Driver coordination)
  Future<void> declineRequest(String tripId) async {
    try {
      final response = await apiClient.dio.post(
        "/driver/main-driver-request/decline",
        data: {"tripId": tripId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to decline request");
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Complete Pick Me Request flow
  Future<void> completeRequest(String tripId) async {
    try {
      final response = await apiClient.dio.post(
        "/driver/main-driver-request/complete",
        data: {"tripId": tripId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to complete request");
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }
}

/// Core BLoC managing Pick Me Request flows
class SupportPickMeRequestBloc
    extends Bloc<SupportPickMeRequestEvent, SupportPickMeRequestState> {
  final SupportPickMeRepository repository;

  SupportPickMeRequestBloc({required this.repository})
      : super(const SupportPickMeRequestInitial()) {
    on<FetchSupportPickMeRequestEvent>(_onSendPickMeRequest);
    on<AcceptSupportPickMeRequestEvent>(_onAcceptRequest);
    on<DeclineSupportPickMeRequestEvent>(_onDeclineRequest);
    on<CompleteSupportPickMeRequestEvent>(_onCompleteRequest);
  }

  /// Handles sending/fetching Pick Me request
  Future<void> _onSendPickMeRequest(
    FetchSupportPickMeRequestEvent event,
    Emitter<SupportPickMeRequestState> emit,
  ) async {
    emit(const SupportPickMeRequestLoading());
    try {
      final response = await repository.sendPickMeRequest(
        ticketId: event.ticketId,
        supportDriverId: event.supportDriverId,
        pickupLocation: event.pickupLocation,
        pickupLatitude: event.pickupLatitude,
        pickupLongitude: event.pickupLongitude,
        pickupGoogleMapsAddress: event.pickupGoogleMapsAddress,
        dropLocation: event.dropLocation,
        dropLatitude: event.dropLatitude,
        dropLongitude: event.dropLongitude,
        dropGoogleMapsAddress: event.dropGoogleMapsAddress,
        notes: event.notes,
        sameVendorOnly: event.sameVendorOnly,
        targetMainDriverId: event.targetMainDriverId,
      );
      emit(SupportPickMeRequestSuccess(requestDetails: response));
    } catch (e) {
      emit(SupportPickMeRequestError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handles accepting request
  Future<void> _onAcceptRequest(
    AcceptSupportPickMeRequestEvent event,
    Emitter<SupportPickMeRequestState> emit,
  ) async {
    emit(const SupportPickMeRequestLoading());
    try {
      await repository.acceptRequest(event.tripId);
      emit(const SupportPickMeRequestAccepted());
    } catch (e) {
      emit(SupportPickMeRequestError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handles declining request
  Future<void> _onDeclineRequest(
    DeclineSupportPickMeRequestEvent event,
    Emitter<SupportPickMeRequestState> emit,
  ) async {
    emit(const SupportPickMeRequestLoading());
    try {
      await repository.declineRequest(event.tripId);
      emit(const SupportPickMeRequestDeclined());
    } catch (e) {
      emit(SupportPickMeRequestError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Handles completing request
  Future<void> _onCompleteRequest(
    CompleteSupportPickMeRequestEvent event,
    Emitter<SupportPickMeRequestState> emit,
  ) async {
    emit(const SupportPickMeRequestLoading());
    try {
      await repository.completeRequest(event.tripId);
      emit(const SupportPickMeRequestCompleted());
    } catch (e) {
      emit(SupportPickMeRequestError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
