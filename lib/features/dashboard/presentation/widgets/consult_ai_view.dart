import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/pages/medgemma_chat_page.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/controllers/medgemma_history_controller.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/ai_result_interpretation_page.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/pages/medgemma_history_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../statistics/presentation/controllers/statistics_controller.dart';

class ConsultAiView extends ConsumerWidget {
  const ConsultAiView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historySessions = ref.watch(medgemmaHistoryProvider);

    final List<Widget> chatCards = historySessions.isEmpty
      ? [const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No recent AI chats found.', style: TextStyle(color: AppColors.textSecondary)))]
      : historySessions.take(3).map((session) {
          return _buildChatCard(
            title: session.title,
            snippet: session.snippet,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MedgemmaChatPage(sessionId: session.id)),
              );
            },
          );
        }).toList();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MedGemma is ready\nto assist you today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Access expert clinical analysis, symptom tracking, and lifestyle guidance powered by empathetic AI. Your sanctuary for informed breast health decisions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MedgemmaChatPage()),
                      );
                    },
                    icon: const Icon(Icons.bolt, color: AppColors.primary, size: 20),
                    label: const Text(
                      'Start New Consultation',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Chats Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Chats',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedgemmaHistoryPage(),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent Chat List (using Stack to overlay the button inside this list area if needed, but we'll return simple column and rely on Scaffold FAB for floating button)
          ...chatCards,
          
          const SizedBox(height: 24),
          
          // Knowledge Domains Header
          const Text(
            'Knowledge Domains',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Knowledge Domains Grid (Row of 2)
          Row(
            children: [
              Expanded(
                child: _buildKnowledgeCard(
                  icon: Icons.receipt_long,
                  title: 'Result\nInterpretation',
                  description: 'Decode complex medical reports with clarity',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKnowledgeCard(
                  icon: Icons.insights,
                  title: 'Symptoms\nTracking',
                  description: 'Analyze changes and patterns over time',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 80), // Padding for bottom nav
        ],
      ),
    );
  }

  Widget _buildChatCard({
    required String title,
    required String snippet,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeCard({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
