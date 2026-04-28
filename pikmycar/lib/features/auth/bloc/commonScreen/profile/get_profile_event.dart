import 'package:equatable/equatable.dart';

abstract class GetProfileEvent extends Equatable {
  const GetProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends GetProfileEvent {
  const FetchProfileEvent();
}
