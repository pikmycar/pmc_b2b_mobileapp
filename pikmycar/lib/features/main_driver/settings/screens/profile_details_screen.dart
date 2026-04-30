import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/bloc/commonScreen/profile/get_profile_bloc.dart';
import '../../../auth/bloc/commonScreen/profile/get_profile_event.dart';
import '../../../auth/bloc/commonScreen/profile/get_profile_state.dart';
import '../../../auth/bloc/commonScreen/profile/update_profile_bloc.dart';
import '../../../auth/bloc/commonScreen/profile/update_profile_event.dart';
import '../../../auth/bloc/commonScreen/profile/update_profile_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _phone = "";
  String _profilePicture = "";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetProfileBloc(
            repository: ProfileRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          )..add( FetchProfileEvent()),
        ),
        BlocProvider(
          create: (context) => UpdateProfileBloc(
            repository: UpdateProfileRepository(
              apiClient: ApiClient(context.read<SecureStorageService>()),
            ),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<GetProfileBloc, GetProfileState>(
                listener: (context, state) {
                  if (state is GetProfileSuccess) {
                    final data = state.profileDetails.data;
                    _nameController.text = data?.name ?? "";
                    _emailController.text = data?.email ?? "";
                    setState(() {
                      _phone = data?.phoneNumber ?? "";
                      _profilePicture = data?.profileImageUrl ?? "";
                    });
                  }
                },
              ),
              BlocListener<UpdateProfileBloc, UpdateProfileState>(
                listener: (context, state) {
                  if (state is UpdateProfileSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.response.message ?? "Profile updated successfully")),
                    );
                    Navigator.pop(context, true);
                  } else if (state is UpdateProfileError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.red))),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<GetProfileBloc, GetProfileState>(
              builder: (context, getProfileState) {
                final isGetLoading = getProfileState is GetProfileLoading || getProfileState is GetProfileInitial;

                return BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
                  builder: (context, updateProfileState) {
                    final isUpdateLoading = updateProfileState is UpdateProfileLoading;

                    return Scaffold(
                      appBar: AppBar(
                  title: const Text("Profile Details"),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.pushNamed(context, '/notifications'),
                    ),
                  ],
                ),
                body: isGetLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                                  backgroundImage: _profilePicture.isNotEmpty
                                      ? NetworkImage(_profilePicture)
                                      : null,
                                  child: _profilePicture.isEmpty
                                      ? Icon(Icons.person, size: 60, color: colorScheme.primary)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                                    child: Icon(Icons.camera_alt, color: colorScheme.onPrimary, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            
                            _buildTextField(
                              context,
                              controller: _nameController,
                              label: "Full Name",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),
                            
                            _buildTextField(
                              context,
                              label: "Phone Number",
                              hint: _phone,
                              icon: Icons.phone_android,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            
                            _buildTextField(
                              context,
                              controller: _emailController,
                              label: "Email Address",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            
                            const SizedBox(height: 60),
                            
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isUpdateLoading ? null : () {
                                  context.read<UpdateProfileBloc>().add(SubmitUpdateProfileEvent(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    // Phone is readOnly as requested so we don't necessarily send it
                                  ));
                                },
                                child: isUpdateLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.onPrimary,
                                        ),
                                      )
                                    : const Text("SAVE CHANGES"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    TextEditingController? controller,
    required String label,
    String? hint,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            fillColor: readOnly ? colorScheme.onSurface.withOpacity(0.05) : null,
            filled: readOnly,
          ),
        ),
      ],
    );
  }
}
