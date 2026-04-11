import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/doctor_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/patient_search_bar.dart';
import '../widgets/patient_card.dart';
import '../widgets/doctor_bottom_nav_bar.dart';
import '../../../auth/presentation/pages/landing_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';

class PatientData {
  final String name;
  final String id;
  final AIResult aiResult;
  final ImageStatus imageStatus;
  final String actionLabel;
  final Color actionColor;
  final String filterCategory; // 'waiting', 'done', 'attention'

  PatientData({
    required this.name,
    required this.id,
    required this.aiResult,
    required this.imageStatus,
    required this.actionLabel,
    required this.actionColor,
    required this.filterCategory,
  });
}

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  int _currentIndex = 2; // Default to "Grid/All" (Screen 1 in image)
  String _searchQuery = '';

  final List<PatientData> _allPatients = [
    PatientData(
      name: 'Bachtiar',
      id: 'P001',
      aiResult: AIResult.normal,
      imageStatus: ImageStatus.yes,
      actionLabel: "Let's Review",
      actionColor: AppColors.btnReview,
      filterCategory: 'waiting',
    ),
    PatientData(
      name: 'Rani',
      id: 'P002',
      aiResult: AIResult.unknown,
      imageStatus: ImageStatus.missing,
      actionLabel: 'Review Needed',
      actionColor: AppColors.btnReviewNeeded,
      filterCategory: 'attention',
    ),
    PatientData(
      name: 'Mufid',
      id: 'P003',
      aiResult: AIResult.benign,
      imageStatus: ImageStatus.yes,
      actionLabel: "Let's Review",
      actionColor: AppColors.btnReview,
      filterCategory: 'waiting',
    ),
    PatientData(
      name: 'Rizky',
      id: 'P004',
      aiResult: AIResult.malignant,
      imageStatus: ImageStatus.yes,
      actionLabel: 'Done',
      actionColor: AppColors.btnDone,
      filterCategory: 'done',
    ),
  ];

  List<PatientData> get _filteredPatients {
    // 1. First filter by search query
    List<PatientData> searchResults = _allPatients.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) || p.id.toLowerCase().contains(query);
    }).toList();

    // 2. Then filter by category tab
    switch (_currentIndex) {
      case 0:
        return searchResults.where((p) => p.filterCategory == 'waiting').toList();
      case 1:
        return searchResults.where((p) => p.filterCategory == 'done').toList();
      case 3:
        return searchResults.where((p) => p.filterCategory == 'attention').toList();
      case 2:
      default:
        return searchResults;
    }
  }

  void _showLogoutDialog() {
    setState(() {
      _currentIndex = 4; // Highlight logout icon during dialog
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Center(
          child: Text(
            'Are You Sure Want To Leave?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 2; // Return to grid or previous index
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorHeader(doctorName: 'Anne'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      child: Text(
                        'Hi, Dr. Anne!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildStatCards(),
                    const SizedBox(height: 10),
                    PatientSearchBar(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildPatientList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4) {
            _showLogoutDialog();
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _buildChatFAB(),
    );
  }

  Widget _buildStatCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          StatCard(
            isActive: _currentIndex == 0,
            icon: Icons.timer,
            label: 'Waiting\nFor Review',
            count: 3,
            iconColor: AppColors.error,
          ),
          const SizedBox(width: 12),
          StatCard(
            isActive: _currentIndex == 1,
            icon: Icons.timer,
            label: 'Done',
            count: 1,
            iconColor: AppColors.statusNormal,
          ),
          const SizedBox(width: 12),
          StatCard(
            isActive: false, // Total Images is never active in design
            icon: Icons.image,
            label: 'Total\nImages',
            count: 4,
            iconColor: AppColors.statusBenign,
          ),
          const SizedBox(width: 12),
          StatCard(
            isActive: _currentIndex == 3,
            icon: Icons.warning_amber_rounded,
            label: 'Need\nAttention',
            count: 1,
            iconColor: AppColors.statusUnknown,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    final patients = _filteredPatients;
    return Column(
      children: patients.map((p) => PatientCard(
        patientName: p.name,
        patientId: p.id,
        aiResult: p.aiResult,
        imageStatus: p.imageStatus,
        actionLabel: p.actionLabel,
        actionColor: p.actionColor,
      )).toList(),
    );
  }

  Widget _buildChatFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
            },
            backgroundColor: AppColors.btnChat,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: const Icon(Icons.email_outlined, color: Colors.black),
            label: const Text(
              'Chat',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
