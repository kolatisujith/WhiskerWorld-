import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/enums.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'responsive_layout.dart';

/// Top Navigation Bar for Whisker World with Theme Toggle, Auth, and Responsive Layout
class WhiskerNavBar extends StatelessWidget implements PreferredSizeWidget {
  const WhiskerNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = Provider.of<ThemeProvider?>(context, listen: true);
    final isDarkMode = themeProvider?.isDarkMode ?? false;
    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.currentUser;
    final border = AppTheme.border(context);
    final navBg = AppTheme.background(context);
    final textPrim = AppTheme.textPrimary(context);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      child: ResponsiveContentWrapper(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Brand Logo
              _buildBrand(context, textPrim),

              // Middle: Navigation Links (Desktop)
              if (isDesktop) ...[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _NavLink(title: 'Home', path: '/'),
                        const SizedBox(width: 4),
                        const _NavLink(title: 'Find Pets', path: '/pets'),
                        const SizedBox(width: 4),
                        const _NavLink(title: 'Pet Stores', path: '/stores'),
                        const SizedBox(width: 4),
                        const _NavLink(title: 'Pet Map', path: '/map'),
                        const SizedBox(width: 4),
                        if (isAuthenticated) ...[
                          if (user?.role == UserRole.petOwner) ...[
                            const _NavLink(title: 'Dashboard', path: '/owner/dashboard'),
                            const SizedBox(width: 4),
                            const _NavLink(title: 'My Pets', path: '/owner/pets'),
                            const SizedBox(width: 4),
                            const _NavLink(title: 'Inquiries', path: '/owner/requests'),
                          ] else ...[
                            const _NavLink(title: 'Dashboard', path: '/adopter/dashboard'),
                            const SizedBox(width: 4),
                            const _NavLink(title: 'Favorites', path: '/favorites'),
                            const SizedBox(width: 4),
                            const _NavLink(title: 'My Requests', path: '/adopter/requests'),
                          ],
                        ] else ...[
                          const _NavLink(title: 'How It Works', path: '/how-it-works'),
                          const SizedBox(width: 4),
                          const _NavLink(title: 'About', path: '/about'),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right Actions: Theme Toggle + Auth
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Search Button
                    IconButton(
                      icon: const Icon(Icons.search_rounded, size: 22),
                      color: textPrim,
                      tooltip: 'Search Pets',
                      onPressed: () => context.go('/pets'),
                    ),
                    const SizedBox(width: 4),

                    // Theme Toggle Button
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                        color: isDarkMode ? const Color(0xFFFFB74D) : AppTheme.charcoal,
                      ),
                      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onPressed: () => themeProvider?.toggleTheme(),
                    ),
                    const SizedBox(width: 8),

                    if (isAuthenticated) ...[
                      InkWell(
                        onTap: () => context.go('/profile'),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground(context),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: user?.role == UserRole.petOwner
                                    ? AppTheme.primaryCoral.withValues(alpha: 0.15)
                                    : AppTheme.naturalSageGreen.withValues(alpha: 0.15),
                                child: Text(
                                  user != null && user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '🐾',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: user?.role == UserRole.petOwner
                                        ? AppTheme.primaryDarkCoral
                                        : AppTheme.naturalSageGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user?.name.split(' ').first ?? 'Profile',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textPrim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) context.go('/login');
                        },
                        icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFD32F2F)),
                        tooltip: 'Logout',
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          foregroundColor: textPrim,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Get Started', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                // Mobile Right Actions: Theme Toggle + Menu Drawer Trigger
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 20,
                        color: isDarkMode ? const Color(0xFFFFB74D) : AppTheme.charcoal,
                      ),
                      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onPressed: () => themeProvider?.toggleTheme(),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu_rounded, size: 26, color: textPrim),
                      tooltip: 'Navigation Menu',
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context, Color textPrim) {
    return InkWell(
      onTap: () => context.go('/'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🐾', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Whisker World',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: textPrim,
                  ),
                ),
                Text(
                  'Every Paw Deserves a Loving Home',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDarkCoral,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final String path;

  const _NavLink({required this.title, required this.path});

  @override
  Widget build(BuildContext context) {
    final currentLoc = GoRouterState.of(context).uri.toString();
    final isActive = currentLoc == path || (path != '/' && currentLoc.startsWith(path));
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppTheme.primaryCoral : (isActive ? textPrim : textSec),
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 2,
              width: isActive ? 16 : 0,
              decoration: BoxDecoration(
                color: AppTheme.primaryCoral,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
