import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isPatient;

  const ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isPatient,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isPatient ? const Color(0xFF40B4FF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isPatient ? const Radius.circular(16) : Radius.zero,
            topRight: isPatient ? Radius.zero : const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          boxShadow: isPatient
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isPatient ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isPatient ? Colors.white.withOpacity(0.8) : AppColors.textSecondary.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                if (isPatient) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
