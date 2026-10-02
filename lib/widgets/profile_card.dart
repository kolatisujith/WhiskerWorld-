import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/enums.dart';
import '../models/user_model.dart';

/// Clean, responsive user profile summary card
class ProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onLogout;

  const ProfileCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final isOwner = user.role == UserRole.petOwner;
    final roleColor = isOwner ? AppTheme.primaryCoral : AppTheme.naturalSageGreen;
    final roleTitle = isOwner ? 'Verified Pet Owner / Caregiver' : 'Approved Pet Adopter';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '🐾',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: roleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textPrim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleTitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Details List
          _buildInfoRow(Icons.email_outlined, user.email, textPrim, textSec),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, user.phone!, textPrim, textSec),
          ],
          if (user.location != null && user.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, user.location!, textPrim, textSec),
          ],

          if (onEdit != null || onLogout != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                if (onEdit != null && onLogout != null) const SizedBox(width: 12),
                if (onLogout != null)
                  IconButton(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
                    tooltip: 'Sign Out',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textPrim, Color textSec) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSec),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: textPrim, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
