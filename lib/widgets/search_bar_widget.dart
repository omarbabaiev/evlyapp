import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        readOnly: readOnly,
        onTap: readOnly ? () => Get.toNamed('/search') : null,
        onChanged: onChanged,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Elan axtar...',
          hintStyle:
              GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: AppColors.gray400, size: 20),
          suffixIcon: readOnly
              ? GestureDetector(
                  onTap: () => Get.toNamed('/filter'),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune,
                      color:
                          Theme.of(context).colorScheme.primary.withOpacity(.8),
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
