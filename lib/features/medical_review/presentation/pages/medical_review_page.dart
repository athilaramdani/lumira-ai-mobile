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
import 'package:lumira_ai_mobile/features/medical_records/presentation/controllers/medical_records_controller.dart';

class MedicalReviewPage extends ConsumerStatefulWidget {
  final String patientId;
  final String? recordId;
  final String patientName;
  final AIResult aiResult;
  final String phone;
  final String? rawImage;
  final String? gradCamImage;
  final bool isDone; // true = PATCH (edit), false = POST (new review)
  
  final String? initialDoctorDiagnosis;
  final String? initialDoctorNote;
  final String? initialAgreement;

  const MedicalReviewPage({
    super.key,
    required this.patientId,
    this.recordId,
    required this.patientName,
    required this.aiResult,
    required this.phone,
    this.rawImage,
    this.gradCamImage,
    this.isDone = false,
    this.initialDoctorDiagnosis,
    this.initialDoctorNote,
    this.initialAgreement,
  });

  @override
  ConsumerState<MedicalReviewPage> createState() => _MedicalReviewPageState();
}

class _MedicalReviewPageState extends ConsumerState<MedicalReviewPage> {
  bool _isSubmitted = false;
  bool? _doctorAgree;
  String _doctorNote = '';
  late ClassificationStatus _selectedClassification;
  
  // Annotation Tool States
  List<DrawingStroke> _strokes = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize classification based on doctor's previous diagnosis if it exists, otherwise use AI Result
    if (widget.initialDoctorDiagnosis != null && widget.initialDoctorDiagnosis!.isNotEmpty) {
      final diag = widget.initialDoctorDiagnosis!.toLowerCase();
      if (diag.contains('malignant')) {
        _selectedClassification = ClassificationStatus.malignant;
      } else if (diag.contains('benign')) {
        _selectedClassification = ClassificationStatus.benign;
      } else {
        _selectedClassification = ClassificationStatus.normal;
      }
    } else {
      _selectedClassification = _mapToClassificationStatus(widget.aiResult);
    }
    
    // Initialize agreement status
    if (widget.initialAgreement != null) {
      _doctorAgree = widget.initialAgreement!.toLowerCase() == 'agree';
    } else {
      _doctorAgree = true; // default
    }
    
    // Initialize notes
    if (widget.initialDoctorNote != null) {
      _doctorNote = widget.initialDoctorNote!;
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
          Expanded(
            child: GestureDetector(
              onTap: () => _showAnnotationTools(isReadOnly: true),
              child: MedicalImageCard(
                label: 'AI RESULT',
                imagePath: widget.gradCamImage ?? AppAssets.aiGradcam,
                badgeText: 'AI GradCam',
                isNetwork: widget.gradCamImage != null,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () => _showAnnotationTools(isReadOnly: false),
              child: MedicalImageCard(
                label: 'RAW VIEW',
                imagePath: widget.rawImage ?? AppAssets.rawPixels,
                isNetwork: widget.rawImage != null,
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
            phone: widget.phone,
          ),
          const SizedBox(height: 24),
          ClassificationResultsCard(
            activeStatus: _selectedClassification,
            onStatusTap: (status) {
              setState(() {
                _selectedClassification = status;
                if (status == _mapToClassificationStatus(widget.aiResult)) {
                  _doctorAgree = true;
                } else {
                  _doctorAgree = false;
                }
              });
            },
          ),
          const SizedBox(height: 24),
          DoctorDiagnosisCard(
            agree: _doctorAgree,
            initialNote: widget.initialDoctorNote,
            onAgreeChanged: (val) => setState(() => _doctorAgree = val),
            onNoteChanged: (val) => setState(() => _doctorNote = val),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () async {
                if (widget.recordId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: No record ID found.')),
                  );
                  return;
                }
                
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                
                final agreement = _doctorAgree == true ? 'agree' : 'disagree';
                final diagnosisLabel = _selectedClassification == ClassificationStatus.benign
                    ? 'Benign'
                    : (_selectedClassification == ClassificationStatus.malignant
                        ? 'Malignant'
                        : 'Normal');
                
                // Use PATCH if editing existing (Done), POST if new review
                final bool success;
                if (widget.isDone) {
                  success = await ref.read(medicalRecordsControllerProvider.notifier).editReviewMedicalRecord(
                    recordId: widget.recordId!,
                    agreement: agreement,
                    note: _doctorNote,
                    doctorDiagnosis: diagnosisLabel,
                  );
                } else {
                  success = await ref.read(medicalRecordsControllerProvider.notifier).reviewMedicalRecord(
                    recordId: widget.recordId!,
                    agreement: agreement,
                    note: _doctorNote,
                    doctorDiagnosis: diagnosisLabel,
                  );
                }
                
                if (!mounted) return;
                Navigator.pop(context); // hide loading
                
                if (success) {
                  setState(() {
                    _isSubmitted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Diagnosis submitted successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  final error = ref.read(medicalRecordsControllerProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to submit: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Submit Diagnosis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_isSubmitted) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Result By Doctor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: 342, // Approximate width of original canvas
                            height: 400, // Approximate height of original canvas
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: widget.rawImage != null 
                                      ? Image.network(
                                          widget.rawImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          AppAssets.rawPixels,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: DrawingPainter(
                                      strokes: _strokes,
                                      currentStroke: null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Agree With AI? ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _doctorAgree == null 
                                      ? '-' 
                                      : (_doctorAgree! ? 'Agree' : 'Disagree'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _doctorAgree == true 
                                        ? AppColors.statusNormal 
                                        : (_doctorAgree == false ? AppColors.statusMalignant : AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Note:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _doctorNote.isEmpty ? '-' : _doctorNote,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Classification Result By AI',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: _selectedClassification == ClassificationStatus.benign
                                    ? AppColors.statusBenign
                                    : (_selectedClassification == ClassificationStatus.malignant
                                        ? AppColors.statusMalignant
                                        : AppColors.statusNormal),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedClassification == ClassificationStatus.benign
                                    ? 'Benign'
                                    : (_selectedClassification == ClassificationStatus.malignant
                                        ? 'Malignant'
                                        : 'Normal'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedClassification == ClassificationStatus.benign
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAnnotationTools({required bool isReadOnly}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnnotationPopup(
        imagePath: isReadOnly ? (widget.gradCamImage ?? AppAssets.aiGradcam) : (widget.rawImage ?? AppAssets.rawPixels),
        isNetwork: isReadOnly ? (widget.gradCamImage != null) : (widget.rawImage != null),
        initialStrokes: _strokes,
        isReadOnly: isReadOnly,
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
