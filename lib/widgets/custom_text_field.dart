import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }
}
