import 'package:equatable/equatable.dart';
import '../models/settings_models.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateProfile extends SettingsEvent {
  final String name;
  final String email;
  final String? photoPath;
  UpdateProfile({required this.name, required this.email, this.photoPath});
}

class SaveBankDetails extends SettingsEvent {
  final BankModel bankDetails;
  SaveBankDetails(this.bankDetails);
}

class WithdrawMoney extends SettingsEvent {
  final double amount;
  WithdrawMoney(this.amount);
}

class TogglePreference extends SettingsEvent {
  final String key;
  final bool value;
  TogglePreference(this.key, this.value);
}
