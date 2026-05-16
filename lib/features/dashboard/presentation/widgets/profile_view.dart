import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumira_ai_mobile/core/network/api_client.dart';
import 'package:lumira_ai_mobile/core/services/firebase_service.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_section_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_info_row.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_display_field.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_setting_row.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_logout_button.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/pages/edit_profile_page.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/logout_dialog.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    if (authState.isLoading && user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final id = user?.id ?? '-';
    final name = user?.name ?? 'Unknown';
    final email = user?.email ?? '-';
    final phone = user?.phone ?? '-';
    final dob = user?.dateOfBirth ?? '-';
    final address = user?.address ?? '-';
    final city = user?.city ?? '-';
    final postalCode = user?.postalCode ?? '-';

    return Column(
      children: [
        ProfileHeader(
          patientId: id,
          patientName: name,
          imageUrl: user?.imageUrl,
          imagePath: user?.role == 'doctor' ? AppAssets.doctorProfile : AppAssets.patientProfile,
          onEditTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            );
          },
        ),
        
        const SizedBox(height: 10),
        
        ProfileSectionCard(
          headerIcon: Icons.person_outline,
          headerTitle: 'Account Details',
          child: Column(
            children: [
              ProfileInfoRow(
                label: 'Email',
                value: email,
              ),
              ProfileInfoRow(
                label: 'Phone',
                value: phone,
              ),
              ProfileInfoRow(
                label: 'Date of Birth',
                value: dob,
                showDivider: false,
              ),
            ],
          ),
        ),
        
        ProfileSectionCard(
          headerIcon: Icons.account_circle_outlined,
          headerTitle: 'Account Address',
          child: Column(
            children: [
              ProfileDisplayField(
                label: '',
                value: address,
                isMultiLine: true,
                showLabel: false,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ProfileDisplayField(
                      label: 'CITY',
                      value: city,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProfileDisplayField(
                      label: 'POSTAL CODE',
                      value: postalCode,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        ProfileSectionCard(
          headerIcon: Icons.tune,
          headerTitle: 'App Settings',
          child: Column(
            children: [
              ProfileSettingRow(
                icon: Icons.notifications_none,
                title: 'Notifications',
                showDivider: false, // Make this the last item
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (bool value) async {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('notifications_enabled', value);
                    
                    final dio = ApiClient().dio;
                    if (value) {
                      await FirebaseService.registerDeviceToken(dio);
                    } else {
                      await FirebaseService.removeDeviceToken(dio);
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        ProfileLogoutButton(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const LogoutDialog();
              },
            );
          },
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
}
