import 'package:equatable/equatable.dart';
import '../../../data/models/get_earnings.dart';

abstract class GetEarningsState extends Equatable {
  const GetEarningsState();
  
  @override
  List<Object?> get props => [];
}

class GetEarningsInitial extends GetEarningsState {
  const GetEarningsInitial();
}

class GetEarningsLoading extends GetEarningsState {
  const GetEarningsLoading();
}

class GetEarningsSuccess extends GetEarningsState {
  final GetEarningsResponse earnings;

  const GetEarningsSuccess({required this.earnings});

  @override
  List<Object?> get props => [earnings];
}

class GetEarningsError extends GetEarningsState {
  final String message;

  const GetEarningsError({required this.message});

  @override
  List<Object?> get props => [message];
}
