import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/doctor_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/doctor_bottom_nav_bar.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/medical_image_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/review_controls.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/patient_info_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/classification_results_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/doctor_diagnosis_card.dart';
import '../../domain/models/drawing_stroke.dart';
import '../widgets/drawing_painter.dart';
import '../widgets/annotation_popup.dart';
import 'medical_review_summary_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/patient_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/pages/doctor_dashboard_page.dart';

class MedicalReviewPage extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final AIResult aiResult;

  const MedicalReviewPage({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.aiResult,
  });

  @override
  ConsumerState<MedicalReviewPage> createState() => _MedicalReviewPageState();
}

class _MedicalReviewPageState extends ConsumerState<MedicalReviewPage> {
  VisualMode _visualMode = VisualMode.raw;
  
  // Annotation Tool States
  List<DrawingStroke> _strokes = [];

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
        child: Column(
          children: [
            DoctorHeader(doctorName: doctorName),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Welcome $doctorName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    ReviewControls(
                      visualMode: _visualMode,
                      onVisualModeChanged: (val) => setState(() => _visualMode = val),
                    ),
                    const SizedBox(height: 20),
                    _buildDiagnosisGrid(),
                    const SizedBox(height: 20),
                  ],
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
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      ),
    );
  }

  ClassificationStatus _mapToClassificationStatus(AIResult aiResult) {
    switch (aiResult) {
      case AIResult.malignant:
        return ClassificationStatus.malignant;
      case AIResult.benign:
        return ClassificationStatus.benign;
      case AIResult.normal:
      case AIResult.unknown:
      default:
        return ClassificationStatus.normal;
    }
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          const Expanded(
            child: MedicalImageCard(
              label: 'AI RESULT',
              imagePath: AppAssets.aiGradcam,
              badgeText: 'AI GradCam',
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: _showAnnotationTools,
              child: MedicalImageCard(
                label: _visualMode == VisualMode.raw ? 'RAW VIEW' : 'NORMALIZED VIEW',
                imagePath: _visualMode == VisualMode.raw 
                    ? AppAssets.rawPixels 
                    : AppAssets.normalizedView,
                overlay: CustomPaint(
                  size: Size.infinite,
                  painter: DrawingPainter(
                    strokes: _strokes,
                    currentStroke: null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _saveAnnotations() async {
    // Show saving dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Saving annotations...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate network/saving delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    
    // Close loading dialog
    Navigator.of(context).pop();

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Annotations saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDiagnosisGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PatientInfoCard(
            id: widget.patientId,
            name: widget.patientName,
            phone: '08123456789',
          ),
          const SizedBox(height: 24),
          ClassificationResultsCard(
            activeStatus: _mapToClassificationStatus(widget.aiResult),
            onStatusTap: (status) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicalReviewSummaryPage(
                    aiResult: status,
                    strokes: _strokes,
                    visualMode: _visualMode,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const DoctorDiagnosisCard(),
        ],
      ),
    );
  }

  void _showAnnotationTools() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnotationPopup(
        imagePath: _visualMode == VisualMode.raw ? AppAssets.rawPixels : AppAssets.normalizedView,
        initialStrokes: _strokes,
        onSave: (newStrokes) {
          setState(() {
            _strokes = newStrokes;
          });
        },
        onSaveAndNavigate: (newStrokes) {
          setState(() {
            _strokes = newStrokes;
          });
          Navigator.of(context).pop(); // Close popup
          _saveAnnotations(); // Trigger saving logic
        },
      ),
    );
  }
}
