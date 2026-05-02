import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/category_tabs.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/scan_card.dart';
import 'package:lumira_ai_mobile/core/widgets/status_badge.dart';
import 'package:lumira_ai_mobile/core/widgets/custom_search_bar.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/promo_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/custom_bottom_nav.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/consult_ai_view.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/history_view.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/medgemma_chat_page.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/profile_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../statistics/presentation/controllers/statistics_controller.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedTabIndex = 0;
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
      floatingActionButton: _currentNavIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedgemmaChatPage()),
                );
              },
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_currentNavIndex != 3)
              const DashboardHeader(),
            
            if (_currentNavIndex == 0)
              _buildStatsContent(),
              
            if (_currentNavIndex == 1)
              const ConsultAiView(),
              
            if (_currentNavIndex == 2)
              const HistoryView(),
              
            if (_currentNavIndex == 3)
              const ProfileView(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    final statsState = ref.watch(statisticsControllerProvider);
    final activities = statsState.activities;

    final List<Widget> dynamicCards = activities.isEmpty 
      ? [const Padding(padding: EdgeInsets.all(20), child: Text('No activities found.'))]
      : activities.map((activity) {
          final id = activity['id']?.toString() ?? '#USG-???';
          final statusStr = activity['status']?.toString().toLowerCase();
          
          ScanStatus status = ScanStatus.done;
          if (statusStr == 'review' || statusStr == 'in_review') status = ScanStatus.inReview;
          if (statusStr == 'pending') status = ScanStatus.pending;

          if (_selectedTabIndex == 1 && status != ScanStatus.pending) return const SizedBox.shrink();
          if (_selectedTabIndex == 2 && status != ScanStatus.inReview) return const SizedBox.shrink();
          if (_selectedTabIndex == 3 && status != ScanStatus.done) return const SizedBox.shrink();

          return ScanCard(
            scanId: id,
            status: status,
            patientName: activity['patient_name'],
            result: activity['result_label'] ?? activity['classification_result'] ?? activity['result'],
          );
        }).whereType<Widget>().toList();

    return Column(
      children: [
        // Search Bar
        const CustomSearchBar(
          hintText: 'Search...',
        ),
        
        // Category Tabs
        CategoryTabs(
          selectedIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
        
        // Scan Cards List
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ...dynamicCards,
              // Promo Card
              const PromoCard(),
            ],
          ),
        ),
      ],
    );
  }
}
