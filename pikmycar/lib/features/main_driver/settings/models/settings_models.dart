import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String profilePicture;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.profilePicture,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicture,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, profilePicture];
}

class BankModel extends Equatable {
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String bankName;

  const BankModel({
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
  });

  @override
  List<Object?> get props => [accountHolder, accountNumber, ifscCode, bankName];
}

enum DocumentStatus { verified, pending, rejected, notUploaded }

class DocumentModel extends Equatable {
  final String title;
  final String type; // DL, RC, Insurance, etc.
  final DocumentStatus status;
  final String? fileUrl;

  const DocumentModel({
    required this.title,
    required this.type,
    required this.status,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [title, type, status, fileUrl];
}

class EarningsModel extends Equatable {
  final double totalEarnings;
  final double availableBalance;

  const EarningsModel({
    required this.totalEarnings,
    required this.availableBalance,
  });

  @override
  List<Object?> get props => [totalEarnings, availableBalance];
}
