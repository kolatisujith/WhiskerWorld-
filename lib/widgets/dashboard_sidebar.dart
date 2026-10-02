import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../models/enums.dart';

/// Navigation item definition for DashboardSidebar
class SidebarItem {
  final String title;
  final String route;
  final IconData icon;
  final int? badgeCount;

  const SidebarItem({
    required this.title,
    required this.route,
    required this.icon,
    this.badgeCount,
  });
}

/// Reusable desktop sidebar for Pet Owner and Pet Adopter dashboards
class DashboardSidebar extends StatelessWidget {
  final UserRole role;
  final String activeRoute;
  final int pendingCount;
  final int? extraCount;

  const DashboardSidebar({
    super.key,
    required this.role,
    required this.activeRoute,
    this.pendingCount = 0,
    this.extraCount,
  });

  List<SidebarItem> _getItems() {
    if (role == UserRole.petOwner) {
      return [
        const SidebarItem(title: 'Overview', route: '/owner/dashboard', icon: Icons.dashboard_rounded),
        const SidebarItem(title: 'My Pets', route: '/owner/pets', icon: Icons.pets_rounded),
        const SidebarItem(title: 'Add New Pet', route: '/owner/pets/add', icon: Icons.add_circle_outline_rounded),
        const SidebarItem(title: 'My Stores', route: '/owner/stores', icon: Icons.storefront_rounded),
        SidebarItem(
          title: 'Adoption Inquiries',
          route: '/owner/requests',
          icon: Icons.mark_email_unread_outlined,
          badgeCount: pendingCount > 0 ? pendingCount : null,
        ),
        const SidebarItem(title: 'Pet & Store Map', route: '/map', icon: Icons.map_rounded),
        const SidebarItem(title: 'Profile Settings', route: '/profile', icon: Icons.person_outline_rounded),
      ];
    } else {
      return [
        const SidebarItem(title: 'Overview', route: '/adopter/dashboard', icon: Icons.dashboard_rounded),
        SidebarItem(
          title: 'Favorites',
          route: '/favorites',
          icon: Icons.favorite_border_rounded,
          badgeCount: extraCount,
        ),
        SidebarItem(
          title: 'Active Requests',
          route: '/adopter/requests',
          icon: Icons.assignment_outlined,
          badgeCount: pendingCount > 0 ? pendingCount : null,
        ),
        const SidebarItem(title: 'Adoption History', route: '/adopter/history', icon: Icons.history_rounded),
        const SidebarItem(title: 'Pet & Store Map', route: '/map', icon: Icons.map_rounded),
        const SidebarItem(title: 'Find Companions', route: '/pets', icon: Icons.search_rounded),
        const SidebarItem(title: 'Profile Settings', route: '/profile', icon: Icons.person_outline_rounded),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final items = _getItems();

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              role == UserRole.petOwner ? '🏠 Caregiver Portal' : '❤️ Adopter Portal',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryCoral,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Menu items
          ...items.map((item) {
            final isActive = activeRoute == item.route;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Material(
                color: isActive
                    ? AppTheme.primaryCoral.withValues(alpha: isDark ? 0.25 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => context.go(item.route),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isActive ? AppTheme.primaryCoral : textSec,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? AppTheme.primaryCoral : textPrim,
                            ),
                          ),
                        ),
                        if (item.badgeCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCoral,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${item.badgeCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
