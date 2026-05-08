import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/scan_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:lumira_ai_mobile/core/widgets/status_badge.dart';
import 'package:lumira_ai_mobile/core/widgets/custom_search_bar.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/promo_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/custom_bottom_nav.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/consult_ai_view.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/history_view.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_view.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/doctor_chat_list_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../statistics/presentation/controllers/statistics_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedTabIndex = 0; // 0: All, 1: In Review, 2: Done
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsControllerProvider.notifier).fetchActivities();
      ref.read(statisticsControllerProvider.notifier).fetchDashboardStats();
    });
  }

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
    final statsState = ref.watch(statisticsControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final activities = statsState.activities;
    final isPatient = authState.user?.role?.toLowerCase() == 'patient';

    int pendingCount = 0;
    int doneCount = 0;
    int totalCount = activities.length;

    for (final activity in activities) {
      final statusStr = activity['status']?.toString().toLowerCase() ?? '';
      if (statusStr == 'pending') {
        pendingCount++;
      } else if (statusStr == 'done' || statusStr == 'validated') {
        doneCount++;
      }
    }

    final List<Widget> dynamicCards = activities.isEmpty 
      ? [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text('No activities found.'),
          ),
        ]
      : activities.map((activity) {
          final id = activity['id']?.toString() ?? '#USG-???';
          final statusStr = activity['status']?.toString().toLowerCase();
          final resultLabel = activity['result_label'] ?? activity['classification_result'] ?? activity['result'];
          
          ScanStatus status = ScanStatus.done;
          if (statusStr == 'review' || statusStr == 'in_review') status = ScanStatus.inReview;
          if (statusStr == 'pending') status = ScanStatus.pending;

          if (_selectedTabIndex == 1 && status != ScanStatus.pending) return const SizedBox.shrink();
          if (_selectedTabIndex == 2 && status != ScanStatus.done) return const SizedBox.shrink();

          return ScanCard(
            scanId: id,
            status: status,
            patientName: activity['patient_name'],
            result: resultLabel,
            doctorName: activity['doctor_name'],
            doctorId: activity['doctor_id']?.toString(),
            queuePosition: activity['queue_position']?.toString(),
            verifiedDate: activity['verified_date']?.toString(),
            isPatientView: isPatient,
          );
        }).whereType<Widget>().toList();

    return Column(
      children: [
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
  }
}
