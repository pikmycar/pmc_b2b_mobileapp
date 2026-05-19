import 'package:equatable/equatable.dart';
import '../models/settings_models.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final UserModel? user;
  final List<DocumentModel> documents;
  final BankModel? bankDetails;
  final EarningsModel? earnings;
  final Map<String, bool> preferences;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.user,
    this.documents = const [],
    this.bankDetails,
    this.earnings,
    this.preferences = const {
      'notifications': true,
      'biometric': false,
      'darkMode': false,
    },
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    UserModel? user,
    List<DocumentModel>? documents,
    BankModel? bankDetails,
    EarningsModel? earnings,
    Map<String, bool>? preferences,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      user: user ?? this.user,
      documents: documents ?? this.documents,
      bankDetails: bankDetails ?? this.bankDetails,
      earnings: earnings ?? this.earnings,
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, documents, bankDetails, earnings, preferences, errorMessage];
}
