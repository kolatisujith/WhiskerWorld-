import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/enums.dart';

/// Reusable status badge for Pet Availability and Adoption Request status
class StatusBadge extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    this.icon,
  });

  /// Factory for PetAvailabilityStatus
  factory StatusBadge.forPet(PetAvailabilityStatus status) {
    switch (status) {
      case PetAvailabilityStatus.available:
        return const StatusBadge(
          label: 'Available',
          foregroundColor: Color(0xFF2E7D32),
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: Color(0xFFA5D6A7),
          icon: Icons.check_circle_outline_rounded,
        );
      case PetAvailabilityStatus.pending:
        return const StatusBadge(
          label: 'Pending Adoption',
          foregroundColor: Color(0xFFE65100),
          backgroundColor: Color(0xFFFFF3E0),
          borderColor: Color(0xFFFFCC80),
          icon: Icons.hourglass_top_rounded,
        );
      case PetAvailabilityStatus.adopted:
        return const StatusBadge(
          label: 'Adopted',
          foregroundColor: Color(0xFF5A5E67),
          backgroundColor: Color(0xFFECEFF1),
          borderColor: Color(0xFFCFD8DC),
          icon: Icons.home_rounded,
        );
      case PetAvailabilityStatus.unavailable:
        return const StatusBadge(
          label: 'Unavailable',
          foregroundColor: Color(0xFF757575),
          backgroundColor: Color(0xFFEEEEEE),
          borderColor: Color(0xFFE0E0E0),
          icon: Icons.pause_circle_outline_rounded,
        );
    }
  }

  /// Factory for AdoptionRequestStatus
  factory StatusBadge.forRequest(AdoptionRequestStatus status) {
    switch (status) {
      case AdoptionRequestStatus.pending:
        return const StatusBadge(
          label: 'Pending Review',
          foregroundColor: Color(0xFFE65100),
          backgroundColor: Color(0xFFFFF3E0),
          borderColor: Color(0xFFFFCC80),
          icon: Icons.schedule_rounded,
        );
      case AdoptionRequestStatus.approved:
        return const StatusBadge(
          label: 'Approved',
          foregroundColor: Color(0xFF1565C0),
          backgroundColor: Color(0xFFE3F2FD),
          borderColor: Color(0xFF90CAF9),
          icon: Icons.thumb_up_alt_rounded,
        );
      case AdoptionRequestStatus.rejected:
        return const StatusBadge(
          label: 'Declined',
          foregroundColor: Color(0xFFC62828),
          backgroundColor: Color(0xFFFFEBEE),
          borderColor: Color(0xFFEF9A9A),
          icon: Icons.cancel_outlined,
        );
      case AdoptionRequestStatus.completed:
        return const StatusBadge(
          label: 'Finalized / Adopted',
          foregroundColor: Color(0xFF2E7D32),
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: Color(0xFFA5D6A7),
          icon: Icons.favorite_rounded,
        );
      case AdoptionRequestStatus.cancelled:
        return const StatusBadge(
          label: 'Cancelled',
          foregroundColor: Color(0xFF5A5E67),
          backgroundColor: Color(0xFFECEFF1),
          borderColor: Color(0xFFCFD8DC),
          icon: Icons.block_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    // Subtle dark adjustment for readability
    final effectiveBg = isDark ? backgroundColor.withValues(alpha: 0.15) : backgroundColor;
    final effectiveFg = isDark ? _lighten(foregroundColor) : foregroundColor;
    final effectiveBorder = isDark ? borderColor.withValues(alpha: 0.4) : borderColor;

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: effectiveFg),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: effectiveFg,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _lighten(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor();
  }
}
