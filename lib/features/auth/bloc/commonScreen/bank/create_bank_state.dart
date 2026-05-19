import 'package:equatable/equatable.dart';
import '../../../data/models/create_bank.dart';

abstract class CreateBankState extends Equatable {
  const CreateBankState();

  @override
  List<Object?> get props => [];
}

class CreateBankInitial extends CreateBankState {
  const CreateBankInitial();
}

class CreateBankLoading extends CreateBankState {
  const CreateBankLoading();
}

class CreateBankSuccess extends CreateBankState {
  final CreateBankResponse response;

  const CreateBankSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class CreateBankError extends CreateBankState {
  final String message;

  const CreateBankError({required this.message});

  @override
  List<Object?> get props => [message];
}
