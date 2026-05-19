import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/app_constants.dart';
import 'create_bank_event.dart';
import 'create_bank_state.dart';
import '../../../data/models/create_bank.dart';

class BankRepository {
  final ApiClient apiClient;

  BankRepository({required this.apiClient});

  Future<CreateBankResponse> createBank({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    required String branchName,
  }) async {
    try {
      final body = {
        "account_holder_name": accountHolderName,
        "account_number": accountNumber,
        "ifsc_code": ifscCode,
        "bank_name": bankName,
        "branch_name": branchName,
      };

      final response = await apiClient.dio.post(
        AppConstants.createBankEndpoint,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateBankResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create bank details (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create bank details: ${e.message}');
    }
  }
}

class CreateBankBloc extends Bloc<CreateBankEvent, CreateBankState> {
  final BankRepository repository;

  CreateBankBloc({required this.repository}) : super(const CreateBankInitial()) {
    on<SubmitCreateBankEvent>(_onSubmitCreateBank);
  }

  Future<void> _onSubmitCreateBank(
    SubmitCreateBankEvent event,
    Emitter<CreateBankState> emit,
  ) async {
    emit(const CreateBankLoading());
    try {
      final response = await repository.createBank(
        accountHolderName: event.accountHolderName,
        accountNumber: event.accountNumber,
        ifscCode: event.ifscCode,
        bankName: event.bankName,
        branchName: event.branchName,
      );
      emit(CreateBankSuccess(response: response));
    } catch (e) {
      emit(CreateBankError(message: e.toString()));
    }
  }
}
