import 'package:equatable/equatable.dart';

enum SupportDriverStatus {
  REQUESTED,
  ACCEPTED,
  PICKUP_IN_PROGRESS,
  PICKUP_REACHED,
  PICKED,
  DROP_IN_PROGRESS,
  DROPPED,
}

enum TripStatus {
  offline,
  searching,
  requestReceived,
  accepted,
  navigatingToPickup,
  pickupReached,
  inTrip,
  completed,
}

class SupportDriver extends Equatable {
  final String id;
  final String name;
  final double? rating;
  final String? photo;
  final String pickupLocation;
  final String dropLocation;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final double distance;
  final String eta;
  final int seatsRequired;
  final SupportDriverStatus status;
  final int? pickupOrder;
  final int? dropOrder;

  const SupportDriver({
    required this.id,
    required this.name,
    this.rating,
    this.photo,
    required this.pickupLocation,
    required this.dropLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
    required this.distance,
    required this.eta,
    required this.seatsRequired,
    this.status = SupportDriverStatus.REQUESTED,
    this.pickupOrder,
    this.dropOrder,
  });

  factory SupportDriver.fromJson(Map<String, dynamic> json) {
    return SupportDriver(
      id: json['id'],
      name: json['name'],
      rating: json['rating'],
      photo: json['photo'],
      pickupLocation: json['pickupLocation'],
      dropLocation: json['dropLocation'],
      pickupLat: json['pickupLat'],
      pickupLng: json['pickupLng'],
      dropLat: json['dropLat'],
      dropLng: json['dropLng'],
      distance: json['distance'],
      eta: json['eta'],
      seatsRequired: json['seatsRequired'],
      status: SupportDriverStatus.values.firstWhere((e) => e.name == json['status']),
      pickupOrder: json['pickupOrder'],
      dropOrder: json['dropOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'photo': photo,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'distance': distance,
      'eta': eta,
      'seatsRequired': seatsRequired,
      'status': status.name,
      'pickupOrder': pickupOrder,
      'dropOrder': dropOrder,
    };
  }

  SupportDriver copyWith({
    String? id,
    String? name,
    double? rating,
    String? photo,
    String? pickupLocation,
    String? dropLocation,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
    double? distance,
    String? eta,
    int? seatsRequired,
    SupportDriverStatus? status,
    int? pickupOrder,
    int? dropOrder,
  }) {
    return SupportDriver(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      photo: photo ?? this.photo,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      seatsRequired: seatsRequired ?? this.seatsRequired,
      status: status ?? this.status,
      pickupOrder: pickupOrder ?? this.pickupOrder,
      dropOrder: dropOrder ?? this.dropOrder,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rating,
        photo,
        pickupLocation,
        dropLocation,
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
        distance,
        eta,
        seatsRequired,
        status,
        pickupOrder,
        dropOrder,
      ];
}

class Trip extends Equatable {
  final String tripId;
  final String mainDriverId;
  final List<SupportDriver> supportDrivers;
  final int availableSeats;
  final int selectedSeats;
  final int currentStep;
  final String? currentTargetDriverId;
  final double totalDistance;
  final double totalEarnings;
  final TripStatus status;

  const Trip({
    required this.tripId,
    required this.mainDriverId,
    required this.supportDrivers,
    required this.availableSeats,
    required this.selectedSeats,
    this.currentStep = 0,
    this.currentTargetDriverId,
    required this.totalDistance,
    required this.totalEarnings,
    this.status = TripStatus.offline,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['tripId'],
      mainDriverId: json['mainDriverId'],
      supportDrivers: (json['supportDrivers'] as List)
          .map((d) => SupportDriver.fromJson(d))
          .toList(),
      availableSeats: json['availableSeats'],
      selectedSeats: json['selectedSeats'],
      currentStep: json['currentStep'],
      currentTargetDriverId: json['currentTargetDriverId'],
      totalDistance: json['totalDistance'],
      totalEarnings: json['totalEarnings'],
      status: TripStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'mainDriverId': mainDriverId,
      'supportDrivers': supportDrivers.map((d) => d.toJson()).toList(),
      'availableSeats': availableSeats,
      'selectedSeats': selectedSeats,
      'currentStep': currentStep,
      'currentTargetDriverId': currentTargetDriverId,
      'totalDistance': totalDistance,
      'totalEarnings': totalEarnings,
      'status': status.name,
    };
  }

  Trip copyWith({
    String? tripId,
    String? mainDriverId,
    List<SupportDriver>? supportDrivers,
    int? availableSeats,
    int? selectedSeats,
    int? currentStep,
    String? currentTargetDriverId,
    double? totalDistance,
    double? totalEarnings,
    TripStatus? status,
  }) {
    return Trip(
      tripId: tripId ?? this.tripId,
      mainDriverId: mainDriverId ?? this.mainDriverId,
      supportDrivers: supportDrivers ?? this.supportDrivers,
      availableSeats: availableSeats ?? this.availableSeats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      currentStep: currentStep ?? this.currentStep,
      currentTargetDriverId: currentTargetDriverId ?? this.currentTargetDriverId,
      totalDistance: totalDistance ?? this.totalDistance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        mainDriverId,
        supportDrivers,
        availableSeats,
        selectedSeats,
        currentStep,
        currentTargetDriverId,
        totalDistance,
        totalEarnings,
        status,
      ];
}
