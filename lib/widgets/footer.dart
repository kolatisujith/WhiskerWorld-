import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import 'responsive_layout.dart';

/// Clean, responsive footer widget for Whisker World with dark mode support
class WhiskerFooter extends StatelessWidget {
  const WhiskerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final footerBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      color: footerBg,
      child: Column(
        children: [
          Divider(height: 1, color: border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: ResponsiveContentWrapper(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 32,
                spacing: 40,
                children: [
                  // Left section: Brand & Tagline
                  SizedBox(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('🐾', style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Whisker World',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textPrim,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Every Paw Deserves a Loving Home. Whisker World connects loving families with adorable newborn and young companions through verified pet stores and ethical caregivers.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSec,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle section: Quick Links
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrim),
                      ),
                      const SizedBox(height: 14),
                      const _FooterLink(title: 'Find Companions', path: '/pets'),
                      const _FooterLink(title: 'Pet Stores & Nurseries', path: '/stores'),
                      const _FooterLink(title: 'Saved Favorites', path: '/favorites'),
                      const _FooterLink(title: 'How It Works', path: '/how-it-works'),
                    ],
                  ),

                  // Legal & Support
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Care & Support',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrim),
                      ),
                      const SizedBox(height: 14),
                      const _FooterLink(title: 'Adoption Guidelines', path: '/responsible-adoption'),
                      const _FooterLink(title: 'Health Guarantee', path: '/about'),
                      const _FooterLink(title: 'Owner Portal', path: '/owner/dashboard'),
                      const _FooterLink(title: 'Adopter Portal', path: '/adopter/dashboard'),
                    ],
                  ),

                  // Right section: Technology & Foundation
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform Foundation',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textPrim),
                      ),
                      const SizedBox(height: 14),
                      _buildTechBadge('Flutter Web Material 3', textSec),
                      const SizedBox(height: 6),
                      _buildTechBadge('SQLite WASM Database', textSec),
                      const SizedBox(height: 6),
                      _buildTechBadge('Provider Architecture', textSec),
                      const SizedBox(height: 6),
                      _buildTechBadge('End-to-End Encryption', textSec),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                '© 2026 Whisker World. Every Paw Deserves a Loving Home.',
                style: TextStyle(fontSize: 12, color: textSec, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechBadge(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.primaryCoral, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String title;
  final String path;

  const _FooterLink({required this.title, required this.path});

  @override
  Widget build(BuildContext context) {
    final textSec = AppTheme.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () => context.go(path),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: textSec,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
