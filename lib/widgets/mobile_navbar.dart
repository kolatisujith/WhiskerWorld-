import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/enums.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

/// Clean mobile bottom navigation bar for small screens
class MobileBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const MobileBottomNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final authProvider = context.watch<AuthProvider>();
    final isOwner = authProvider.currentUser?.role == UserRole.petOwner;

    final dashboardRoute = isOwner ? '/owner/dashboard' : '/adopter/dashboard';
    final isHome = currentRoute == '/';
    final isPets = currentRoute.startsWith('/pets');
    final isStores = currentRoute.startsWith('/stores');
    final isDashboard = currentRoute.startsWith('/adopter') || currentRoute.startsWith('/owner');
    final isFavorites = currentRoute == '/favorites';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: isHome,
                onTap: () => context.go('/'),
              ),
              _buildNavItem(
                context,
                icon: Icons.pets_rounded,
                label: 'Find Pets',
                isActive: isPets,
                onTap: () => context.go('/pets'),
              ),
              _buildNavItem(
                context,
                icon: Icons.storefront_rounded,
                label: 'Stores',
                isActive: isStores,
                onTap: () => context.go('/stores'),
              ),
              if (authProvider.isAuthenticated) ...[
                if (!isOwner)
                  _buildNavItem(
                    context,
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    isActive: isFavorites,
                    onTap: () => context.go('/favorites'),
                  ),
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isActive: isDashboard,
                  onTap: () => context.go(dashboardRoute),
                ),
              ] else ...[
                _buildNavItem(
                  context,
                  icon: Icons.login_rounded,
                  label: 'Sign In',
                  isActive: currentRoute == '/login',
                  onTap: () => context.go('/login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final textSec = AppTheme.textSecondary(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppTheme.primaryCoral : textSec,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppTheme.primaryCoral : textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile Navigation Drawer for comprehensive access to all links, themes, and accounts
class MobileNavDrawer extends StatelessWidget {
  const MobileNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;
    final isOwner = user?.role == UserRole.petOwner;

    return Drawer(
      backgroundColor: cardBg,
      child: Column(
        children: [
          // Drawer Header with Brand & User
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
              border: Border(bottom: BorderSide(color: AppTheme.border(context))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🐾', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Text(
                          'Whisker World',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrim,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: textPrim,
                        size: 20,
                      ),
                      tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onPressed: () => themeProvider.toggleTheme(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Every Paw Deserves a Loving Home.',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryDarkCoral, fontWeight: FontWeight.w600),
                ),
                if (authProvider.isAuthenticated && user != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isOwner
                              ? AppTheme.primaryCoral.withValues(alpha: 0.15)
                              : AppTheme.naturalSageGreen.withValues(alpha: 0.15),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isOwner ? AppTheme.primaryCoral : AppTheme.naturalSageGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrim),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isOwner ? 'Pet Caregiver' : 'Pet Adopter',
                                style: TextStyle(fontSize: 11, color: textSec),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Drawer Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(context, icon: Icons.home_rounded, title: 'Home', path: '/'),
                _buildDrawerItem(context, icon: Icons.pets_rounded, title: 'Find Young Pets', path: '/pets'),
                _buildDrawerItem(context, icon: Icons.storefront_rounded, title: 'Pet Stores & Shelters', path: '/stores'),
                _buildDrawerItem(context, icon: Icons.map_rounded, title: 'Pet & Store Map', path: '/map'),
                _buildDrawerItem(context, icon: Icons.help_outline_rounded, title: 'How It Works', path: '/how-it-works'),
                _buildDrawerItem(context, icon: Icons.info_outline_rounded, title: 'About Us', path: '/about'),
                if (authProvider.isAuthenticated) ...[
                  if (isOwner) ...[
                    _buildDrawerItem(context, icon: Icons.dashboard_rounded, title: 'Owner Dashboard', path: '/owner/dashboard'),
                    _buildDrawerItem(context, icon: Icons.pets_outlined, title: 'My Pets', path: '/owner/pets'),
                    _buildDrawerItem(context, icon: Icons.store_rounded, title: 'My Stores', path: '/owner/stores'),
                    _buildDrawerItem(context, icon: Icons.mark_email_unread_outlined, title: 'Adoption Inquiries', path: '/owner/requests'),
                  ] else ...[
                    _buildDrawerItem(context, icon: Icons.dashboard_rounded, title: 'Adopter Dashboard', path: '/adopter/dashboard'),
                    _buildDrawerItem(context, icon: Icons.favorite_rounded, title: 'Saved Favorites', path: '/favorites'),
                    _buildDrawerItem(context, icon: Icons.assignment_outlined, title: 'My Applications', path: '/adopter/requests'),
                    _buildDrawerItem(context, icon: Icons.history_rounded, title: 'Adoption History', path: '/adopter/history'),
                  ],
                  _buildDrawerItem(context, icon: Icons.person_outline_rounded, title: 'My Profile', path: '/profile'),
                ] else ...[
                  _buildDrawerItem(context, icon: Icons.login_rounded, title: 'Sign In', path: '/login'),
                  _buildDrawerItem(context, icon: Icons.person_add_outlined, title: 'Create Account', path: '/register'),
                ],
              ],
            ),
          ),

          // Drawer Bottom Logout
          if (authProvider.isAuthenticated)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await authProvider.logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFD32F2F)),
                  label: const Text('Sign Out', style: TextStyle(color: Color(0xFFD32F2F))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF9A9A)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required String path}) {
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return ListTile(
      leading: Icon(icon, color: textSec, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrim),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(path);
      },
    );
  }
}
