import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/widgets/chat_date_divider.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(AppAssets.doctor), 
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Dr. Sarah',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Surgical Oncologist',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: const [
          ChatDateDivider(dateString: 'January 07, 2023'),
          ChatBubble(
            message: 'Berdasarkan hasil analisis saya, terdapat indikasi malignant. Namun, perlu pemeriksaan lanjutan untuk memastikan diagnosis.',
            time: '12:22',
            isPatient: false,
          ),
          ChatBubble(
            message: 'Saya sarankan untuk segera melakukan pemeriksaan lanjutan di rumah sakit terdekat ya.',
            time: '12:22',
            isPatient: false,
          ),
          ChatBubble(
            message: 'Baik dok, terima kasih banyak',
            time: '12:23',
            isPatient: true,
          ),
          
          ChatDateDivider(dateString: 'October 16, 2025'),
          ChatBubble(
            message: 'Ya, memar ringan dan sedikit rasa nyeri cukup umum terjadi selama 48-72 jam pertama. Anda dapat mengompres dingin selama 15 menit setiap beberapa jam hari ini.',
            time: '21:30',
            isPatient: false,
          ),
          ChatBubble(
            message: 'Saya sudah melampirkan laporan lengkapnya di profil Anda di bawah bagian \'Laporan\'. Mari kita jadwalkan kontrol dalam tiga bulan untuk memantau area tersebut.',
            time: '21:30',
            isPatient: false,
          ),
          ChatBubble(
            message: 'Baik dok, terima kasih banyak',
            time: '21:31',
            isPatient: true,
          ),
        ],
      ),
    );
  }
}
