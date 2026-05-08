import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import 'chat_page.dart';

class DoctorChatListPage extends StatefulWidget {
  const DoctorChatListPage({super.key});

  @override
  State<DoctorChatListPage> createState() => _DoctorChatListPageState();
}

class _DoctorChatListPageState extends State<DoctorChatListPage> {
  String _searchQuery = '';

  // Mock list of doctors
  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Tirta',
      'id': 'DOC-222858',
      'specialty': 'Oncology',
      'isOnline': true,
    },
    {
      'name': 'Dr. Boyke',
      'id': 'DOC-506218',
      'specialty': 'Radiology',
      'isOnline': true,
    },
    {
      'name': 'Dr. Sarah',
      'id': 'DOC-503495',
      'specialty': 'Oncology',
      'isOnline': false,
    },
    {
      'name': 'Dr. Budi',
      'id': 'DOC-433580',
      'specialty': 'Radiology',
      'isOnline': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _doctors.where((doc) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = doc['name']?.toLowerCase() ?? '';
      final id = doc['id']?.toLowerCase() ?? '';
      return name.contains(query) || id.contains(query);
    }).toList();

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
          automaticallyImplyLeading: false,
          title: const Text(
            'Chat List',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            CustomSearchBar(
              hintText: 'Search Doctor...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: filteredDoctors.isEmpty
                  ? const Center(child: Text('Tidak ada dokter ditemukan.'))
                  : ListView.builder(
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return _buildChatListItem(
                          context,
                          name: doctor['name'],
                          id: doctor['id'],
                          message: 'Ketuk untuk mulai chat',
                          time: '',
                          isOnline: doctor['isOnline'],
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
    required String message,
    required String time,
    required bool isOnline,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigates to actual chat room. Here we can use ChatPage with empty room ID logic 
          // or pass the doctor info to initiate the chat.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                doctorId: id,
                doctorName: name,
                medicalRecordId: '',
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
              Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                      image: const DecorationImage(
                        image: AssetImage(AppAssets.doctor), // Assuming doctor image is available
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'ID: $id',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const Spacer(),
                        if (time.isNotEmpty)
                          Text(
                            time,
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
