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
  support_driver_pickup,
  support_driver_drop,
  cancelled,
}

enum TicketStatus {
  newRequests,
  underReview,
  driverAssigned,
  driverArrived,
  inTransit,
  completed,
}

extension TicketStatusExtension on TicketStatus {
  int get id {
    switch (this) {
      case TicketStatus.newRequests: return 1;
      case TicketStatus.underReview: return 2;
      case TicketStatus.driverAssigned: return 3;
      case TicketStatus.driverArrived: return 4;
      case TicketStatus.inTransit: return 5;
      case TicketStatus.completed: return 6;
    }
  }

  String get name {
    switch (this) {
      case TicketStatus.newRequests: return "New Requests";
      case TicketStatus.underReview: return "Under Review";
      case TicketStatus.driverAssigned: return "Driver Assigned";
      case TicketStatus.driverArrived: return "Driver Arrived";
      case TicketStatus.inTransit: return "In Transit";
      case TicketStatus.completed: return "Completed";
    }
  }

  static TicketStatus fromName(String name) {
    switch (name) {
      case "New Requests": return TicketStatus.newRequests;
      case "Under Review": return TicketStatus.underReview;
      case "Driver Assigned": return TicketStatus.driverAssigned;
      case "Driver Arrived": return TicketStatus.driverArrived;
      case "In Transit": return TicketStatus.inTransit;
      case "Completed": return TicketStatus.completed;
      default: return TicketStatus.newRequests;
    }
  }

  static TicketStatus fromId(int id) {
    switch (id) {
      case 1: return TicketStatus.newRequests;
      case 2: return TicketStatus.underReview;
      case 3: return TicketStatus.driverAssigned;
      case 4: return TicketStatus.driverArrived;
      case 5: return TicketStatus.inTransit;
      case 6: return TicketStatus.completed;
      default: return TicketStatus.newRequests;
    }
  }
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
  final String? ticketId;
  final String? requestId;
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
    this.ticketId,
    this.requestId,
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
    var supportDriversList = json['supportDrivers'];
    if (supportDriversList == null && json['supportDriver'] != null) {
      supportDriversList = [json['supportDriver']];
    }

    final String reqId = json['requestId']?.toString() ?? json['request_id']?.toString() ?? json['id']?.toString() ?? '';
    final String tckId = json['ticketId']?.toString() ?? json['ticket_id']?.toString() ?? '';

    List<SupportDriver> drivers = [];
    if (supportDriversList is List) {
      drivers = supportDriversList.map((d) {
        if (d is Map) {
          final String pLoc = d['pickupLocation']?.toString() ?? json['pickup']?.toString() ?? 'Unknown Pickup';
          final String dLoc = d['dropLocation']?.toString() ?? json['drop']?.toString() ?? 'Unknown Destination';
          
          return SupportDriver(
            id: d['id']?.toString() ?? d['driverId']?.toString() ?? 'SD-01',
            name: d['name']?.toString() ?? 'Support Driver',
            rating: d['rating'] != null ? (d['rating'] as num?)?.toDouble() : null,
            photo: d['photo']?.toString() ?? d['avatar']?.toString(),
            pickupLocation: pLoc,
            dropLocation: dLoc,
            pickupLat: d['pickupLat'] != null ? (d['pickupLat'] as num?)?.toDouble() : null,
            pickupLng: d['pickupLng'] != null ? (d['pickupLng'] as num?)?.toDouble() : null,
            dropLat: d['dropLat'] != null ? (d['dropLat'] as num?)?.toDouble() : null,
            dropLng: d['dropLng'] != null ? (d['dropLng'] as num?)?.toDouble() : null,
            distance: d['distance'] != null ? (d['distance'] as num).toDouble() : 1.0,
            eta: d['eta']?.toString() ?? '10 mins',
            seatsRequired: d['seatsRequired'] is int ? d['seatsRequired'] : (int.tryParse(d['seatsRequired']?.toString() ?? '') ?? 1),
            status: d['status'] != null 
                ? SupportDriverStatus.values.firstWhere((e) => e.name == d['status'], orElse: () => SupportDriverStatus.REQUESTED)
                : SupportDriverStatus.REQUESTED,
          );
        }
        return SupportDriver.fromJson(Map<String, dynamic>.from(d));
      }).toList();
    }

    return Trip(
      tripId: tckId.isNotEmpty ? tckId : reqId,
      ticketId: tckId,
      requestId: reqId,
      mainDriverId: json['mainDriverId'] ?? '',
      supportDrivers: drivers,
      availableSeats: json['availableSeats'] ?? 4,
      selectedSeats: json['selectedSeats'] ?? 1,
      currentStep: json['currentStep'] ?? 0,
      currentTargetDriverId: json['currentTargetDriverId'] ?? (drivers.isNotEmpty ? drivers.first.id : null),
      totalDistance: json['totalDistance'] != null ? (json['totalDistance'] as num).toDouble() : 0.0,
      totalEarnings: json['totalEarnings'] != null ? (json['totalEarnings'] as num).toDouble() : 0.0,
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.offline,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'ticketId': ticketId,
      'requestId': requestId,
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
    String? ticketId,
    String? requestId,
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
      ticketId: ticketId ?? this.ticketId,
      requestId: requestId ?? this.requestId,
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
        ticketId,
        requestId,
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
