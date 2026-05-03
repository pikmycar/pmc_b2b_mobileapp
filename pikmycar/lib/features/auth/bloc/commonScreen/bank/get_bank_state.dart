import 'package:equatable/equatable.dart';
import '../../../data/models/get_bank.dart';

abstract class GetBankState extends Equatable {
  const GetBankState();
  
  @override
  List<Object?> get props => [];
}

class GetBankInitial extends GetBankState {
  const GetBankInitial();
}

class GetBankLoading extends GetBankState {
  const GetBankLoading();
}

class GetBankSuccess extends GetBankState {
  final GetBankResponse response;

  const GetBankSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class GetBankError extends GetBankState {
  final String message;

  const GetBankError({required this.message});

  @override
  List<Object?> get props => [message];
}
