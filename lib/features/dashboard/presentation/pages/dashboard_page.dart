import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/category_tabs.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/scan_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/status_badge.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/promo_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/custom_bottom_nav.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/consult_ai_view.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/history_view.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/medgemma_chat_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTabIndex = 0;
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
            const DashboardHeader(),
            
            if (_currentNavIndex == 0)
              _buildStatsContent(),
              
            if (_currentNavIndex == 1)
              const ConsultAiView(),
              
            if (_currentNavIndex == 2)
              const HistoryView(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
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
              if (_selectedTabIndex == 0 || _selectedTabIndex == 2)
                const ScanCard(
                  scanId: '#USG-99281',
                  status: ScanStatus.inReview,
                ),
              if (_selectedTabIndex == 0 || _selectedTabIndex == 1)
                const ScanCard(
                  scanId: '#USG-98281',
                  status: ScanStatus.pending,
                ),
              if (_selectedTabIndex == 0 || _selectedTabIndex == 3)
                const ScanCard(
                  scanId: '#USG-98281',
                  status: ScanStatus.done,
                ),
              
              // Promo Card
              const PromoCard(),
            ],
          ),
        ),
      ],
    );
  }
}
