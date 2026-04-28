import 'package:equatable/equatable.dart';

abstract class GetRatingsEvent extends Equatable {
  const GetRatingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchRatingsEvent extends GetRatingsEvent {
  const FetchRatingsEvent();
}
