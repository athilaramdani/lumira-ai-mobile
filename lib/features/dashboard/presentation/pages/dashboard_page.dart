import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/scan_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:lumira_ai_mobile/core/widgets/custom_search_bar.dart';
import 'package:lumira_ai_mobile/core/widgets/status_badge.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/promo_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/custom_bottom_nav.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/consult_ai_view.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/history_view.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_view.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/doctor_chat_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedTabIndex = 0; // 0: All, 1: Pending/In Review, 2: Done
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTabSelected: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
      body: _currentNavIndex == 2
          ? const DoctorChatListPage()
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_currentNavIndex != 4)
                    const DashboardHeader(),

                  if (_currentNavIndex == 0)
                    _buildStatsContent(),

                  if (_currentNavIndex == 1)
                    const ConsultAiView(),

                  if (_currentNavIndex == 3)
                    const HistoryView(),

                  if (_currentNavIndex == 4)
                    const ProfileView(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsContent() {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.id;

    // Use patientDetailProvider to fetch this patient's own records
    final patientAsync = userId != null
        ? ref.watch(patientDetailProvider(userId))
        : const AsyncValue<dynamic>.loading();

    return patientAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Text(
            'Failed to load data: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (patient) {
        final medicalRecords = patient?.medicalRecords ?? [];

        // --- Count stats ---
        int pendingCount = 0;
        int doneCount = 0;
        for (final record in medicalRecords) {
          final status = record.validationStatus?.toUpperCase() ?? '';
          final hasDoctorReview = (record.doctorDiagnosis?.trim().isNotEmpty ?? false) &&
              record.doctorDiagnosis!.trim().toLowerCase() != 'null';

          if (status == 'REVIEWED' || status == 'DONE' || status == 'VALIDATED' || hasDoctorReview) {
            doneCount++;
          } else {
            pendingCount++;
          }
        }
        final totalCount = medicalRecords.length;

        // --- Build scan cards ---
        List<Widget> dynamicCards;
        if (medicalRecords.isEmpty) {
          dynamicCards = [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No scan records found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ];
        } else {
          dynamicCards = medicalRecords.map((record) {
            final recordId = record.id?.toString() ?? '#USG-???';

            // Determine status for ScanCard
            final validationStatus = record.validationStatus?.toUpperCase() ?? '';
            final hasDoctorReview = (record.doctorDiagnosis?.trim().isNotEmpty ?? false) &&
                record.doctorDiagnosis!.trim().toLowerCase() != 'null';

            ScanStatus scanStatus;
            if (validationStatus == 'REVIEWED' || validationStatus == 'DONE' ||
                validationStatus == 'VALIDATED' || hasDoctorReview) {
              scanStatus = ScanStatus.done;
            } else if (validationStatus == 'IN_REVIEW' || validationStatus == 'INREVIEW') {
              scanStatus = ScanStatus.inReview;
            } else {
              scanStatus = ScanStatus.pending;
            }

            // Filter by selected tab
            if (_selectedTabIndex == 1 && scanStatus == ScanStatus.done) {
              return const SizedBox.shrink();
            }
            if (_selectedTabIndex == 2 && scanStatus != ScanStatus.done) {
              return const SizedBox.shrink();
            }

            final doctorId = record.doctor?['id']?.toString() ?? '';
            final doctorName = record.doctor?['name']?.toString() ?? 'Dokter';

            return ScanCard(
              scanId: recordId,
              status: scanStatus,
              result: record.resultLabel,
              doctorName: doctorName,
              doctorId: doctorId,
              verifiedDate: record.createdAt,
              isPatientView: true,
            );
          }).whereType<Widget>().toList();
        }

        return Column(
          children: [
            // --- Stat Cards ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatCard(
                        isActive: _selectedTabIndex == 1,
                        icon: Icons.timer_outlined,
                        label: 'Pending',
                        count: pendingCount,
                        iconColor: AppColors.error,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        isActive: _selectedTabIndex == 2,
                        icon: Icons.check_circle_outline,
                        label: 'Done',
                        count: doneCount,
                        iconColor: AppColors.statusNormal,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        isActive: _selectedTabIndex == 0,
                        icon: Icons.grid_view_rounded,
                        label: 'Dashboard',
                        count: totalCount,
                        iconColor: AppColors.statusBenign,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const CustomSearchBar(
              hintText: 'Search Scan History...',
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  ...dynamicCards,
                  const PromoCard(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
