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

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileHeader(
          patientId: 'LX-8842',
          patientName: 'Bobby Rojusian',
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
            children: const [
              ProfileInfoRow(
                label: 'Email',
                value: 'bobbyroji@gmail.com',
              ),
              ProfileInfoRow(
                label: 'Phone',
                value: '+62 812-3456-7890',
              ),
              ProfileInfoRow(
                label: 'Date of Birth',
                value: 'March 14, 1985',
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
              const ProfileDisplayField(
                label: '',
                value: 'Jl. Kemang Raya No. 12,\nMampang Prapatan, Jakarta\nSelatan, 12730',
                isMultiLine: true,
                showLabel: false,
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                    child: ProfileDisplayField(
                      label: 'CITY',
                      value: 'Jakarta',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ProfileDisplayField(
                      label: 'POSTAL CODE',
                      value: '12730',
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
              ProfileSettingRow(
                icon: Icons.language,
                title: 'Language',
                trailing: const Text(
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
