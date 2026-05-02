import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class DoctorDiagnosisCard extends StatefulWidget {
  final bool? agree;
  final String? initialNote;
  final ValueChanged<bool>? onAgreeChanged;
  final ValueChanged<String>? onNoteChanged;

  const DoctorDiagnosisCard({
    super.key,
    this.agree,
    this.initialNote,
    this.onAgreeChanged,
    this.onNoteChanged,
  });

  @override
  State<DoctorDiagnosisCard> createState() => _DoctorDiagnosisCardState();
}

class _DoctorDiagnosisCardState extends State<DoctorDiagnosisCard> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Doctor's Diagnosis",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Agree With AI Diagnosis?",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => widget.onAgreeChanged?.call(true),
            child: _buildRadioOption("Agree", true, AppColors.statusNormal),
          ),
          GestureDetector(
            onTap: () => widget.onAgreeChanged?.call(false),
            child: _buildRadioOption("Disagree", false, AppColors.statusMalignant),
          ),
          const SizedBox(height: 20),
          const Text(
            "Add Note",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _noteController,
              onChanged: widget.onNoteChanged,
              decoration: InputDecoration(
                hintText: 'Type here...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, bool value, Color color) {
    bool isSelected = widget.agree == value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
