import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Modern, accessible search bar with clear button, submit, and optional filter trigger
class WhiskerSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const WhiskerSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search by name, breed, species or location...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppTheme.primaryCoral,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textPrim,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: textSec.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: textSec,
              tooltip: 'Clear search',
              onPressed: () {
                controller.clear();
                if (onClear != null) {
                  onClear!();
                } else if (onChanged != null) {
                  onChanged!('');
                }
              },
            ),
          if (onFilterTap != null) ...[
            Container(
              height: 24,
              width: 1,
              color: border,
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.tune_rounded, size: 20),
                  if (hasActiveFilters)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryCoral,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              color: hasActiveFilters ? AppTheme.primaryCoral : textSec,
              tooltip: 'Filters',
              onPressed: onFilterTap,
            ),
          ],
        ],
      ),
    );
  }
}
