import 'package:equatable/equatable.dart';

abstract class GetEarningsEvent extends Equatable {
  const GetEarningsEvent();

  @override
  List<Object?> get props => [];
}

class FetchEarningsEvent extends GetEarningsEvent {}
