import 'package:equatable/equatable.dart';

abstract class CreateBankEvent extends Equatable {
  const CreateBankEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCreateBankEvent extends CreateBankEvent {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;

  const SubmitCreateBankEvent({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
  });

  @override
  List<Object?> get props => [
        accountHolderName,
        accountNumber,
        ifscCode,
        bankName,
        branchName,
      ];
}
