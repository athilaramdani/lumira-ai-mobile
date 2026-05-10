import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
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

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                trailing: Switch(
                  value: true,
                  onChanged: (bool value) {},
                  activeColor: AppColors.primary,
                ),
              ),
              const ProfileSettingRow(
                icon: Icons.language,
                title: 'Language',
                trailing: Text(
                  'English (US)',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                showDivider: false,
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
