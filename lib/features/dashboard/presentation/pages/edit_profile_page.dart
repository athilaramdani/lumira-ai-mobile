import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    helperText: '* Input harus berupa angka',
                    onChanged: (val) => _localUser = _localUser.copyWith(phone: val),
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    key: ValueKey(_localUser.dateOfBirth),
                    label: 'DATE OF BIRTH',
                    initialValue: () {
                      final dob = _localUser.dateOfBirth ?? '';
                      if (dob.isEmpty) return '';
                      final parts = dob.split(RegExp(r'[-/]'));
                      if (parts.length == 3 && parts[0].length == 4) {
                        return '${parts[2]}-${parts[1]}-${parts[0]}';
                      }
                      return dob;
                    }(),
                    hintText: 'DD-MM-YYYY',
                    readOnly: true,
                    onTap: () async {
                      final now = DateTime.now();
                      DateTime initialDate = now;
                      if (_localUser.dateOfBirth != null && _localUser.dateOfBirth!.isNotEmpty) {
                        final parts = _localUser.dateOfBirth!.split(RegExp(r'[-/]'));
                        if (parts.length == 3) {
                          try {
                            if (parts[0].length == 4) {
                              initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                            } else {
                              initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                            }
                          } catch (e) {
                            // ignore and use now
                          }
                        }
                      }
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(1900),
                        lastDate: now,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        setState(() {
                          final formattedDate = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                          _localUser = _localUser.copyWith(dateOfBirth: formattedDate);
                        });
                      }
                    },
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          helperText: '* Input harus berupa angka',
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
                      onPressed: () async {
                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .updateProfile(_localUser);

                        if (success && context.mounted) {
                          showDialog<bool>(
                            context: context,
                            builder: (context) => const SaveChangesDialog(),
                          ).then((saved) {
                            if (saved == true) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          });
                        } else if (context.mounted) {
                          final error = ref.read(authControllerProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error ?? 'Gagal memperbarui profil. Silakan coba lagi.',
                              ),
                              backgroundColor: Colors.red.shade700,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
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
