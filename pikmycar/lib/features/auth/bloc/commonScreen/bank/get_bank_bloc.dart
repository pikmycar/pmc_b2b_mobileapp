import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import 'get_bank_event.dart';
import 'get_bank_state.dart';
import '../../../data/models/get_bank.dart';

class GetBankRepository {
  final ApiClient apiClient;

  GetBankRepository({required this.apiClient});

  Future<GetBankResponse> fetchBank() async {
    try {
      final response = await apiClient.dio.get(AppConstants.getBankEndpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetBankResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch bank details (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch bank details: ${e.message}');
    }
  }
}

class GetBankBloc extends Bloc<GetBankEvent, GetBankState> {
  final GetBankRepository repository;

  GetBankBloc({required this.repository}) : super(const GetBankInitial()) {
    on<FetchBankEvent>(_onFetchBank);
  }

  Future<void> _onFetchBank(
    FetchBankEvent event,
    Emitter<GetBankState> emit,
  ) async {
    emit(const GetBankLoading());
    try {
      final response = await repository.fetchBank();
      emit(GetBankSuccess(response: response));
    } catch (e) {
      emit(GetBankError(message: e.toString()));
    }
  }
}
