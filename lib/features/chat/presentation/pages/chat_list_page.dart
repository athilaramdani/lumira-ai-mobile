import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:lumira_ai_mobile/core/widgets/creative_medical_loading.dart';
import 'patient_chat_page.dart';
import 'chat_page.dart';

class ChatListPage extends ConsumerStatefulWidget {
  final bool showBackButton;
  const ChatListPage({super.key, this.showBackButton = true});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Use /chat/rooms API — same endpoint as the web, sorted by backend
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final authState = ref.watch(authControllerProvider);
    final isPatientRole = authState.user?.role == 'patient';
    final counterpartImage = isPatientRole ? AppAssets.doctor : AppAssets.dummyProfile;

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
          leading: widget.showBackButton 
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          automaticallyImplyLeading: widget.showBackButton,
          title: const Text(
            'Chat List',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            CustomSearchBar(
              hintText: isPatientRole ? 'Search Doctor...' : 'Search Patient...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  try {
                    ref.invalidate(chatRoomsProvider);
                    await ref.read(chatRoomsProvider.future);
                  } catch (e) {
                    debugPrint('Refresh error: $e');
                  }
                },
                child: chatRoomsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CreativeMedicalLoading(text: 'Loading chats...'),
                    ),
                  ),
                  error: (err, _) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(child: Text('Gagal memuat chat: $err')),
                    ),
                  ),
                  data: (rooms) {
                    final filtered = rooms.where((room) {
                      if (_searchQuery.isEmpty) return true;
                      final query = _searchQuery.toLowerCase();
                      final name = (room['counterpartName'] ?? '').toString().toLowerCase();
                      final id = (room['counterpartId'] ?? '').toString().toLowerCase();
                      return name.contains(query) || id.contains(query);
                    }).toList();

                    if (filtered.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(child: Text('Belum ada percakapan chat.')),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final room = filtered[index];
                        final counterpartName = room['counterpartName'] ?? 'Unknown';
                        // counterpartId is the other person's ID (doctor ID for patient, patient ID for doctor)
                        final counterpartId = room['counterpartId'] ?? '';
                        final medicalRecordId = room['medicalRecordId'] ?? '';
                        final lastMessage = room['lastMessage'] as String?;

                        return _buildChatListItem(
                          context,
                          name: counterpartName,
                          id: counterpartId,
                          medicalRecordId: medicalRecordId,
                          message: lastMessage ?? 'Ketuk untuk mulai chat',
                          imagePath: counterpartImage,
                          isPatientRole: isPatientRole,
                        );
                      },
                    );
                  },
                ),
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
    required String imagePath,
    required bool isPatientRole,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final targetPage = isPatientRole
              ? ChatPage(
                  doctorName: name,
                  doctorId: id,
                  medicalRecordId: medicalRecordId,
                )
              : PatientChatPage(
                  patientName: name,
                  patientId: id,
                  medicalRecordId: medicalRecordId,
                );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => targetPage,
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
                  color: const Color(0xFFE3F2FD),
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
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
