import 'package:equatable/equatable.dart';

abstract class GetBankEvent extends Equatable {
  const GetBankEvent();

  @override
  List<Object?> get props => [];
}

class FetchBankEvent extends GetBankEvent {}
