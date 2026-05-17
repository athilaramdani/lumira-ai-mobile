import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';
import '../../../statistics/presentation/controllers/statistics_controller.dart';
import '../widgets/doctor_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/patient_card.dart';
import '../widgets/doctor_bottom_nav_bar.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../chat/presentation/controllers/chat_controller.dart';
import '../widgets/profile_view.dart';
import '../../../../core/widgets/creative_medical_loading.dart';
class PatientData {
  final String name;
  final String id;
  final String? recordId;
  final AIResult aiResult;
  final ImageStatus imageStatus;
  final String actionLabel;
  final Color actionColor;
  final String filterCategory; // 'waiting', 'done', 'attention'
  final String phone;
  final String? rawImage;
  final String? gradCamImage;
  final String? initialDoctorDiagnosis;
  final String? initialDoctorNote;
  final String? initialAgreement;

  PatientData({
    required this.name,
    required this.id,
    this.recordId,
    required this.aiResult,
    required this.imageStatus,
    required this.actionLabel,
    required this.actionColor,
    required this.filterCategory,
    required this.phone,
    this.rawImage,
    this.gradCamImage,
    this.initialDoctorDiagnosis,
    this.initialDoctorNote,
    this.initialAgreement,
  });
}

class DoctorDashboardPage extends ConsumerStatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  ConsumerState<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final dashboardFilterProvider = StateProvider<String>((ref) => 'all');

class _DoctorDashboardPageState extends ConsumerState<DoctorDashboardPage> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _silentRefresh();
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentRefresh();
    });
  }

  Future<void> _silentRefresh() async {
    await ref.read(patientsControllerProvider.notifier).fetchPatients(silentRefresh: true);
    await ref.read(statisticsControllerProvider.notifier).fetchDoctorStats();
    ref.invalidate(chatRoomsProvider);
  }

  void _onScroll() {
    // Load more: near bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(patientsControllerProvider.notifier).fetchPatients(loadMore: true);
    }
  }

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await ref.read(patientsControllerProvider.notifier).fetchPatients();
    await ref.read(statisticsControllerProvider.notifier).fetchDoctorStats();
    ref.invalidate(chatRoomsProvider);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  List<PatientData> get _allMappedPatients {
    final patientsState = ref.watch(patientsControllerProvider);
    return patientsState.patients.map((patient) {
      final id = patient.id ?? '';
      final latestRecord = patient.latestRecord ?? 
          (patient.medicalRecords?.isNotEmpty == true ? patient.medicalRecords!.first : null);
          
      final status = latestRecord?.validationStatus?.toUpperCase();
      
      // Determine if a review already exists.
      // Backend might return empty strings or "null" literal if no review exists yet.
      bool hasReview = false;
      final diag = latestRecord?.doctorDiagnosis?.trim().toLowerCase();
      if (diag != null && diag.isNotEmpty && diag != 'null') {
        hasReview = true;
      }
      final agree = latestRecord?.agreement?.trim().toLowerCase();
      if (agree != null && agree.isNotEmpty && agree != 'null') {
        hasReview = true;
      }
      
      final isDone = status == 'DONE' || status == 'VALIDATED' || hasReview;
      
      final aiDiagnosisRaw = latestRecord?.resultLabel?.toLowerCase() ?? '';
      AIResult aiResultVar = AIResult.unknown;
      if (aiDiagnosisRaw.contains('malignant')) {
        aiResultVar = AIResult.malignant;
      } else if (aiDiagnosisRaw.contains('benign')) {
        aiResultVar = AIResult.benign;
      } else if (aiDiagnosisRaw.contains('normal')) {
        aiResultVar = AIResult.normal;
      }

      return PatientData(
        name: patient.name ?? 'Unknown',
        id: id,
        recordId: latestRecord?.id,
        aiResult: aiResultVar,
        imageStatus: latestRecord?.imageUrl != null ? ImageStatus.yes : ImageStatus.missing,
        actionLabel: isDone ? 'Done' : 'Review Needed',
        actionColor: isDone ? AppColors.btnDone : AppColors.btnReviewNeeded,
        filterCategory: isDone ? 'done' : 'waiting',
        phone: patient.contactNumber ?? '08123456789',
        rawImage: latestRecord?.imageUrl,
        gradCamImage: latestRecord?.gradcamImageUrl,
        initialDoctorDiagnosis: latestRecord?.doctorDiagnosis,
        initialDoctorNote: latestRecord?.doctorNotes,
        initialAgreement: latestRecord?.agreement,
      );
    }).toList();
  }

  List<PatientData> get _filteredPatients {
    final mappedPatients = _allMappedPatients;

    // 1. First filter by search query
    List<PatientData> searchResults = mappedPatients.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(query) || p.id.toLowerCase().contains(query);
    }).toList();

    final currentFilter = ref.watch(dashboardFilterProvider);

    // 2. Then filter by category tab
    switch (currentFilter) {
      case 'waiting':
        return searchResults.where((p) => p.filterCategory == 'waiting').toList();
      case 'done':
        return searchResults.where((p) => p.filterCategory == 'done').toList();
      case 'attention':
        return searchResults.where((p) => p.filterCategory == 'attention').toList();
      case 'all':
      default:
        return searchResults;
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final authState = ref.watch(authControllerProvider);
    final doctorName = authState.user?.name ?? 'Doctor';

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: Stack(
          children: [
            Column(
          children: [
            if (currentIndex == 0) DoctorHeader(doctorName: doctorName),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _triggerRefresh,
                color: AppColors.primary,
                child: currentIndex == 1
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: const ProfileView(),
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                              child: Text(
                                'Hi, ${doctorName.startsWith('Dr') ? doctorName : 'Dr. $doctorName'}!',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: _buildStatCards()),
                          const SliverToBoxAdapter(child: SizedBox(height: 10)),
                          SliverToBoxAdapter(
                            child: CustomSearchBar(
                              hintText: 'Search Patient...',
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 10)),
                          _buildPatientSliverList(),
                          SliverToBoxAdapter(
                            child: ref.watch(patientsControllerProvider).isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: CreativeMedicalLoading(text: 'Loading more...'),
                                    ),
                                  )
                                : const SizedBox(height: 20),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
            // ─── Pull-to-refresh overlay ──────────────────────────────────
            if (_isRefreshing)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.88),
                  child: const Center(
                    child: CreativeMedicalLoading(text: 'Refreshing data...'),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          _silentRefresh(); // Refresh when changing tabs
        },
      ),
      floatingActionButton: currentIndex == 0 ? _buildChatFAB() : null,
      ),
    );
  }

  Widget _buildStatCards() {
    final currentFilter = ref.watch(dashboardFilterProvider);
    final statisticsState = ref.watch(statisticsControllerProvider);
    final doctorStats = statisticsState.doctorStats;

    final mapped = _allMappedPatients;
    int waitingCount = mapped.where((p) => p.filterCategory == 'waiting').length;
    int doneCount = mapped.where((p) => p.filterCategory == 'done').length;
    int totalImages = mapped.length;
    int needAttention = mapped.where((p) => p.filterCategory == 'attention').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatCard(
                isActive: currentFilter == 'waiting',
                icon: Icons.timer_outlined,
                label: 'Waiting\nFor Review',
                count: waitingCount,
                iconColor: AppColors.error,
                onTap: () {
                  ref.read(dashboardFilterProvider.notifier).state = 'waiting';
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                isActive: currentFilter == 'done',
                icon: Icons.check_circle_outline,
                label: 'Done',
                count: doneCount,
                iconColor: AppColors.statusNormal,
                onTap: () {
                  ref.read(dashboardFilterProvider.notifier).state = 'done';
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                isActive: currentFilter == 'all',
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                count: totalImages,
                iconColor: AppColors.statusBenign,
                onTap: () {
                  ref.read(dashboardFilterProvider.notifier).state = 'all';
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                isActive: currentFilter == 'attention',
                icon: Icons.warning_amber_rounded,
                label: 'Need\nAttention',
                count: needAttention,
                iconColor: AppColors.statusUnknown,
                onTap: () {
                  ref.read(dashboardFilterProvider.notifier).state = 'attention';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSliverList() {
    final patients = _filteredPatients;
    
    if (patients.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'No patients found in this category.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final p = patients[index];
          return PatientCard(
            patientName: p.name,
            patientId: p.id,
            recordId: p.recordId,
            aiResult: p.aiResult,
            imageStatus: p.imageStatus,
            actionLabel: p.actionLabel,
            actionColor: p.actionColor,
            phone: p.phone,
            rawImage: p.rawImage,
            gradCamImage: p.gradCamImage,
            initialDoctorDiagnosis: p.initialDoctorDiagnosis,
            initialDoctorNote: p.initialDoctorNote,
            initialAgreement: p.initialAgreement,
          );
        },
        childCount: patients.length,
      ),
    );
  }

  Widget _buildChatFAB() {
    final unreadCount = ref.watch(unreadChatCountProvider);
    
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
              ).then((_) => _silentRefresh()); // Auto-refresh when back from chat
            },
            backgroundColor: AppColors.btnChat,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: const Icon(Icons.email_outlined, color: Colors.white),
            label: const Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
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
