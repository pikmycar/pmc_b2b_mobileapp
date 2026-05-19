import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../models/settings_models.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateProfile>(_onUpdateProfile);
    on<SaveBankDetails>(_onSaveBankDetails);
    on<WithdrawMoney>(_onWithdrawMoney);
    on<TogglePreference>(_onTogglePreference);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock initial data
    final user = const UserModel(
      id: 'D-123',
      name: 'Mohammad Shahid',
      phone: '+91 9876543210',
      email: 'shahid.driver@example.com',
      profilePicture: 'https://i.pravatar.cc/150?img=12',
    );

    final documents = [
      const DocumentModel(title: 'Driving License', type: 'DL', status: DocumentStatus.verified),
      const DocumentModel(title: 'RC Book', type: 'RC', status: DocumentStatus.verified),
      const DocumentModel(title: 'Vehicle Insurance', type: 'INS', status: DocumentStatus.pending),
      const DocumentModel(title: 'Aadhaar Card', type: 'ID', status: DocumentStatus.notUploaded),
    ];

    const earnings = EarningsModel(totalEarnings: 12450.0, availableBalance: 4500.0);

    emit(state.copyWith(
      status: SettingsStatus.success,
      user: user,
      documents: documents,
      earnings: earnings,
    ));
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<SettingsState> emit) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        name: event.name,
        email: event.email,
        profilePicture: event.photoPath ?? state.user!.profilePicture,
      );
      emit(state.copyWith(user: updatedUser));
    }
  }

  void _onSaveBankDetails(SaveBankDetails event, Emitter<SettingsState> emit) {
    emit(state.copyWith(bankDetails: event.bankDetails));
  }

  void _onWithdrawMoney(WithdrawMoney event, Emitter<SettingsState> emit) {
    if (state.earnings != null && state.earnings!.availableBalance >= event.amount) {
      final newEarnings = EarningsModel(
        totalEarnings: state.earnings!.totalEarnings,
        availableBalance: state.earnings!.availableBalance - event.amount,
      );
      emit(state.copyWith(earnings: newEarnings));
    }
  }

  void _onTogglePreference(TogglePreference event, Emitter<SettingsState> emit) {
    final Map<String, bool> newPrefs = Map.from(state.preferences);
    newPrefs[event.key] = event.value;
    emit(state.copyWith(preferences: newPrefs));
  }
}
