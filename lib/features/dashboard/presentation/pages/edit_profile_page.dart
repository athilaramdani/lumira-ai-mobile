import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_section_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_text_field.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/save_changes_dialog.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              patientId: 'LX-8842',
              patientName: 'Bobby Rojusian',
              editIcon: Icons.camera_alt,
              onEditTap: () {
                // Template action for changing photo
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileSectionCard(
              headerIcon: Icons.person_outline,
              headerTitle: 'Personal Details',
              child: Column(
                children: const [
                  ProfileTextField(
                    label: 'Full Name',
                    initialValue: 'Sarah Wijaya',
                  ),
                  SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Email Address',
                    initialValue: 'bobbyroji@gmail.com',
                  ),
                  SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Phone Number',
                    initialValue: '+62 812-3456-7890',
                  ),
                  SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Date of Birth',
                    initialValue: 'March 14, 1985',
                  ),
                ],
              ),
            ),
            
            ProfileSectionCard(
              headerIcon: Icons.account_circle_outlined,
              headerTitle: 'Account Address',
              child: Column(
                children: [
                  const ProfileTextField(
                    label: '',
                    initialValue: 'Jl. Kemang Raya No. 12,\nMampang Prapatan, Jakarta\nSelatan, 12730',
                    isMultiLine: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: ProfileTextField(
                          label: 'CITY',
                          initialValue: 'Jakarta',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ProfileTextField(
                          label: 'POSTAL CODE',
                          initialValue: '12730',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SaveChangesDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
