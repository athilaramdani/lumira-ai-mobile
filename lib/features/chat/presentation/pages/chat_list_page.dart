import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import 'patient_chat_page.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Use /chat/rooms API — same endpoint as the web, sorted by backend
    final chatRoomsAsync = ref.watch(chatRoomsProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Chat List',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            CustomSearchBar(
              hintText: 'Search Patient...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: chatRoomsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Gagal memuat chat: $err')),
                data: (rooms) {
                  final filtered = rooms.where((room) {
                    if (_searchQuery.isEmpty) return true;
                    final query = _searchQuery.toLowerCase();
                    final name = (room['counterpartName'] ?? '').toString().toLowerCase();
                    final id = (room['counterpartId'] ?? '').toString().toLowerCase();
                    return name.contains(query) || id.contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Tidak ada pasien ditemukan.'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final room = filtered[index];
                      final patientName = room['counterpartName'] ?? 'Unknown';
                      final patientId = room['patientId'] ?? '';
                      final medicalRecordId = room['medicalRecordId'] ?? '';
                      final lastMessage = room['lastMessage'] as String?;

                      return _buildChatListItem(
                        context,
                        name: patientName,
                        id: patientId,
                        medicalRecordId: medicalRecordId,
                        message: lastMessage ?? 'Ketuk untuk mulai chat',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListItem(
    BuildContext context, {
    required String name,
    required String id,
    required String medicalRecordId,
    required String message,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientChatPage(
                patientName: name,
                patientId: id,
                medicalRecordId: medicalRecordId,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.doctorProfile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'ID: $id',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
