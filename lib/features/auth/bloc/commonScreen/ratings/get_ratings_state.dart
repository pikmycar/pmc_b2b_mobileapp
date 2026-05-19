import 'package:equatable/equatable.dart';
import '../../../data/models/get_ratings.dart'; // Integration with your GetRatings model

abstract class GetRatingsState extends Equatable {
  const GetRatingsState();
  
  @override
  List<Object?> get props => [];
}

class GetRatingsInitial extends GetRatingsState {
  const GetRatingsInitial();
}

class GetRatingsLoading extends GetRatingsState {
  const GetRatingsLoading();
}

class GetRatingsSuccess extends GetRatingsState {
  final GetRatings ratingsData;

  const GetRatingsSuccess({required this.ratingsData});

  @override
  List<Object?> get props => [ratingsData];
}

class GetRatingsError extends GetRatingsState {
  final String message;

  const GetRatingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
