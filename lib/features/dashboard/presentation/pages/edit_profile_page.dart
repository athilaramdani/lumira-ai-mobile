import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/auth/data/models/user_model.dart';
import 'package:lumira_ai_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_section_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_text_field.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/save_changes_dialog.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late UserModel _localUser;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      _localUser = user.copyWith();
    } else {
      _localUser = UserModel(id: 'PAS-859317', name: 'Test Patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              patientId: _localUser.id ?? 'Unknown ID',
              patientName: _localUser.name ?? 'Unknown',
              imageUrl: _localUser.imageUrl,
              editIcon: Icons.camera_alt,
              onEditTap: () {
                _showImageEditDialog(context);
              },
            ),
            
            const SizedBox(height: 10),
            
            ProfileSectionCard(
              headerIcon: Icons.person_outline,
              headerTitle: 'Personal Details',
              child: Column(
                children: [
                  ProfileTextField(
                    label: 'Full Name',
                    initialValue: _localUser.name ?? '',
                    onChanged: (val) => _localUser = _localUser.copyWith(name: val),
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Email Address',
                    initialValue: _localUser.email ?? '',
                    onChanged: (val) => _localUser = _localUser.copyWith(email: val),
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Phone Number',
                    initialValue: _localUser.phone ?? '',
                    onChanged: (val) => _localUser = _localUser.copyWith(phone: val),
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Date of Birth',
                    initialValue: _localUser.dateOfBirth ?? '',
                    onChanged: (val) => _localUser = _localUser.copyWith(dateOfBirth: val),
                  ),
                ],
              ),
            ),
            
            ProfileSectionCard(
              headerIcon: Icons.account_circle_outlined,
              headerTitle: 'Account Address',
              child: Column(
                children: [
                  ProfileTextField(
                    label: '',
                    initialValue: _localUser.address ?? '',
                    isMultiLine: true,
                    onChanged: (val) => _localUser = _localUser.copyWith(address: val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileTextField(
                          label: 'CITY',
                          initialValue: _localUser.city ?? '',
                          onChanged: (val) => _localUser = _localUser.copyWith(city: val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ProfileTextField(
                          label: 'POSTAL CODE',
                          initialValue: _localUser.postalCode ?? '',
                          onChanged: (val) => _localUser = _localUser.copyWith(postalCode: val),
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
                        // Update the provider with the new data
                        ref.read(authControllerProvider.notifier).updateProfileLocally(_localUser);
                        
                        showDialog<bool>(
                          context: context,
                          builder: (context) => const SaveChangesDialog(),
                        ).then((saved) {
                          if (saved == true) {
                            if (context.mounted) {
                              Navigator.pop(context); // Go back to profile page after save
                            }
                          }
                        });
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

  void _showImageEditDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController(text: _localUser.imageUrl ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile Photo'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _localUser = _localUser.copyWith(imageUrl: urlController.text.trim());
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
