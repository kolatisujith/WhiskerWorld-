import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../widgets/animations/floating_widget.dart';
import '../widgets/animations/hover_card.dart';
import '../widgets/animations/scroll_fade_slide.dart';
import '../widgets/footer.dart';
import '../widgets/mobile_navbar.dart';
import '../widgets/navbar.dart';
import '../widgets/responsive_layout.dart';

/// Official About Screen detailing Whisker World's mission, story,
/// ethical standards, veterinary health guarantee, platform features, and team.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/about') : null,
      backgroundColor: AppTheme.background(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HERO BANNER
            _buildHeroBanner(context, isMobile, isDark),

            // 2. IMPACT STATS BAR
            _buildImpactStats(context, isMobile, isDark),

            // 3. MISSION & STORY SECTION
            _buildMissionAndStory(context, isMobile, isDark),

            // 4. CORE VALUES & ETHICAL STANDARDS
            _buildCoreValues(context, isMobile, isDark),

            // 5. OFFICIAL WEB APPLICATION CAPABILITIES
            _buildPlatformCapabilities(context, isMobile, isDark),

            // 6. LEADERSHIP & VETERINARY ADVISORY TEAM
            _buildTeamSection(context, isMobile, isDark),

            // 7. OUR 5-POINT ETHICAL GUARANTEE
            _buildEthicalGuaranteeSection(context, isMobile, isDark),

            // 8. INTERACTIVE DEMO & CALL TO ACTION
            _buildCallToAction(context, isMobile, isDark),

            // 9. FOOTER
            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  // ================= 1. HERO BANNER =================
  Widget _buildHeroBanner(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 48 : 80,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.border(context)),
        ),
      ),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              // Badge
              FloatingWidget(
                verticalDistance: 4,
                duration: const Duration(milliseconds: 3000),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(
                        'ABOUT WHISKER WORLD • OFFICIAL APPLICATION',
                        style: TextStyle(
                          color: isDark ? AppTheme.darkCoral : AppTheme.primaryDarkCoral,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Headline
              Text(
                'Every Paw Deserves a Loving Home',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 54,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -1.2,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subheading
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  'Whisker World is the official ethical companion adoption and discovery web application. We bridge compassionate pet adopters with verified local pet stores, licensed nurseries, and certified ethical caregivers—empowered by transparent veterinary health passports and interactive geospatial search.',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    color: textSec,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Action Group
              Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  HoverCard(
                    liftDistance: 4,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/pets'),
                      icon: const Icon(Icons.pets_rounded, size: 18),
                      label: const Text('Explore Available Pets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCoral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                        shadowColor: AppTheme.primaryCoral.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  HoverCard(
                    liftDistance: 3,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/how-it-works'),
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: const Text('How It Works'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: AppTheme.border(context), width: 1.5),
                        foregroundColor: textPrim,
                      ),
                    ),
                  ),
                  HoverCard(
                    liftDistance: 3,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/?scrollTo=demo'),
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 18, color: AppTheme.primaryCoral),
                      label: const Text('Watch Platform Demo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: AppTheme.border(context), width: 1.5),
                        foregroundColor: textPrim,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 2. IMPACT STATS BAR =================
  Widget _buildImpactStats(BuildContext context, bool isMobile, bool isDark) {
    final stats = [
      {'val': '1,250+', 'label': 'Loving Adoptions', 'icon': Icons.favorite_rounded, 'color': AppTheme.primaryCoral},
      {'val': '48', 'label': 'Verified Nurseries', 'icon': Icons.storefront_rounded, 'color': const Color(0xFF3B82F6)},
      {'val': '100%', 'label': 'Vet Certified Passports', 'icon': Icons.verified_user_rounded, 'color': AppTheme.naturalSageGreen},
      {'val': '0%', 'label': 'Puppy Mill Tolerance', 'icon': Icons.shield_rounded, 'color': const Color(0xFF8B5CF6)},
    ];

    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF181B20) : const Color(0xFFF6F3ED),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 32 : 44),
      child: ResponsiveContentWrapper(
        child: Wrap(
          spacing: 24,
          runSpacing: 20,
          alignment: WrapAlignment.spaceAround,
          children: stats.map((s) {
            final col = s['color'] as Color;
            return Container(
              constraints: BoxConstraints(minWidth: isMobile ? 140 : 180),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s['icon'] as IconData, color: col, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['val'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary(context),
                          letterSpacing: -0.6,
                        ),
                      ),
                      Text(
                        s['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= 3. MISSION & STORY SECTION =================
  Widget _buildMissionAndStory(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Text(
                'Our Mission & Founding Story',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 36,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Whisker World was built with a singular conviction: adopting a pet should be a transparent, joyful, and completely trustworthy journey.',
                  style: TextStyle(
                    fontSize: 15,
                    color: textSec,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  // Story Card 1
                  _buildContentCard(
                    context: context,
                    isMobile: isMobile,
                    isDark: isDark,
                    cardBg: cardBg,
                    border: border,
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'The Challenge We Addressed',
                    body:
                        'For years, families looking for puppies, kittens, baby rabbits, and young companions faced a fragmented landscape plagued by unlicensed brokers, hidden health defects, and opaque origins. At the same time, ethical pet stores and licensed nurseries lacked a dedicated, modern digital platform to showcase their genuine care and medical records.',
                  ),
                  // Story Card 2
                  _buildContentCard(
                    context: context,
                    isMobile: isMobile,
                    isDark: isDark,
                    cardBg: cardBg,
                    border: border,
                    icon: Icons.rocket_launch_rounded,
                    iconColor: AppTheme.primaryCoral,
                    title: 'The Whisker World Solution',
                    body:
                        'We engineered Whisker World as a secure, certified adoption ecosystem. Every pet listing requires certified veterinary vaccination history, microchip documentation, and verified store accreditation. Our interactive Live Map and real-time adoption questionnaires ensure seamless, verified matches between adopters and licensed caregivers.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 4. CORE VALUES & ETHICAL STANDARDS =================
  Widget _buildCoreValues(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final values = [
      {
        'icon': Icons.health_and_safety_rounded,
        'title': 'Certified Health First',
        'desc': 'No companion is ever listed without signed veterinary records, core vaccination timelines, and complete deworming history.',
        'color': AppTheme.naturalSageGreen,
      },
      {
        'icon': Icons.location_city_rounded,
        'title': 'Zero Tolerance for Mills',
        'desc': 'We physically and legally verify every nursery, requiring verified business licenses, sanitary housing audits, and strict ethical standards.',
        'color': const Color(0xFFEF4444),
      },
      {
        'icon': Icons.handshake_rounded,
        'title': 'Radical Transparency',
        'desc': 'No hidden fees or misleading claims. Adopters inspect comprehensive pet dossiers and communicate directly with licensed caregivers.',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.favorite_border_rounded,
        'title': 'Lifelong Compassion',
        'desc': 'Adoption is a lifetime promise. We provide care education, post-adoption support, and transition counseling for all new pet parents.',
        'color': AppTheme.primaryCoral,
      },
    ];

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : const Color(0xFFF9F6F0),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.3)),
              ),
              child: Text(
                'GUIDING PRINCIPLES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.darkCoral : AppTheme.primaryDarkCoral,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our Core Values & Guarantees',
              style: TextStyle(
                fontSize: isMobile ? 24 : 36,
                fontWeight: FontWeight.w900,
                color: textPrim,
                letterSpacing: -0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'How we protect the welfare of animals and the peace of mind of adopting families.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: values.map((v) {
                final vColor = v['color'] as Color;
                return HoverCard(
                  liftDistance: 4,
                  child: Container(
                    width: isMobile ? double.infinity : 270,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: vColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(v['icon'] as IconData, color: vColor, size: 24),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          v['title'] as String,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textPrim,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          v['desc'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary(context),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 5. OFFICIAL WEB APPLICATION CAPABILITIES =================
  Widget _buildPlatformCapabilities(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final capabilities = [
      {
        'icon': Icons.search_rounded,
        'title': 'Smart Companion Search',
        'desc': 'Filter by species (Puppies, Kittens, Birds, Bunnies, Small & Furry), age in weeks, breed pedigree, size, and temperament traits.',
      },
      {
        'icon': Icons.map_rounded,
        'title': 'Interactive Pet Discovery Map',
        'desc': 'Real-time GPS mapping displays licensed partner stores, nearby young pets, driving distances, store ratings, and directions.',
      },
      {
        'icon': Icons.medical_services_rounded,
        'title': 'Certified Health Passports',
        'desc': 'Immutable digital dossiers detailing DHPP, Rabies, Bordetella, deworming dates, microchip IDs, and veterinary clinic notes.',
      },
      {
        'icon': Icons.assignment_outlined,
        'title': 'Structured Adoption Pipeline',
        'desc': 'Prospective families submit housing questionnaires and track status directly: Submitted, Under Review, Approved, or Adopted.',
      },
      {
        'icon': Icons.dashboard_customize_rounded,
        'title': 'Caregiver & Store Portal',
        'desc': 'Dedicated manager for pet stores to manage listings, update health passports, review applicant profiles, and schedule visits.',
      },
      {
        'icon': Icons.dark_mode_rounded,
        'title': 'Theme Toggle & Responsive UI',
        'desc': 'Fluid design crafted with Material 3 principles, instant Dark and Light mode toggling, and mobile-optimized layouts.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Text(
              'What the Official Web Application Delivers',
              style: TextStyle(
                fontSize: isMobile ? 22 : 34,
                fontWeight: FontWeight.w900,
                color: textPrim,
                letterSpacing: -0.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'Explore the built-in technological features designed to make adopting a companion effortless and safe.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(context),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: capabilities.map((c) {
                return HoverCard(
                  liftDistance: 3,
                  child: Container(
                    width: isMobile ? double.infinity : 360,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(c['icon'] as IconData, color: AppTheme.primaryCoral, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textPrim,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c['desc'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary(context),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 6. LEADERSHIP & VETERINARY ADVISORY TEAM =================
  Widget _buildTeamSection(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final team = [
      {
        'name': 'Dr. Evelyn Harper, DVM',
        'role': 'Chief Veterinary Officer',
        'bio': '14+ years in pediatric animal care and vaccination immunology. Oversees health passport standards and clinic compliance.',
        'icon': Icons.medical_services_rounded,
        'color': AppTheme.naturalSageGreen,
      },
      {
        'name': 'Marcus Sterling',
        'role': 'Founder & Executive Director',
        'bio': 'Passionate animal rescue advocate and software technologist dedicated to building humane companion adoption systems.',
        'icon': Icons.pets_rounded,
        'color': AppTheme.primaryCoral,
      },
      {
        'name': 'Sophia Chen',
        'role': 'Head of Store & Breeder Audits',
        'bio': 'Leads on-site inspection teams ensuring every registered store meets strict ethical standards and sanitary guidelines.',
        'icon': Icons.verified_user_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'David Ramirez',
        'role': 'Adoption Support Coordinator',
        'bio': 'Guides prospective families through the questionnaire process, meet-and-greets, and first-time companion onboarding.',
        'icon': Icons.support_agent_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : const Color(0xFFFAF7F2),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Text(
              'Leadership & Veterinary Advisory Board',
              style: TextStyle(
                fontSize: isMobile ? 22 : 34,
                fontWeight: FontWeight.w900,
                color: textPrim,
                letterSpacing: -0.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Driven by dedicated veterinarians, animal welfare experts, and community coordinators.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: team.map((member) {
                final mColor = member['color'] as Color;
                return HoverCard(
                  liftDistance: 4,
                  child: Container(
                    width: isMobile ? double.infinity : 270,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: mColor.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(member['icon'] as IconData, color: mColor, size: 30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          member['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrim,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member['role'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkCoral : AppTheme.primaryDarkCoral,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          member['bio'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(context),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 7. OUR 5-POINT ETHICAL GUARANTEE =================
  Widget _buildEthicalGuaranteeSection(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final points = [
      '1. Minimum 8-Week Mother Bond: Young companions never transition before safe, natural developmental weaning.',
      '2. Up-to-Date Core Immunizations: Mandatory vaccines logged with veterinary clinic signatures and dates.',
      '3. Microchip Identification: Permanent registration records provided with every finalized adoption.',
      '4. Transparent Medical History: Any pre-existing observations or allergy sensitivities disclosed upfront.',
      '5. Rehoming Safety Net: If family circumstances change, our partner stores offer dedicated safe-surrender support.',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: [
                  const Icon(Icons.verified_rounded, color: AppTheme.naturalSageGreen, size: 28),
                  Text(
                    'The Whisker World 5-Point Ethical Guarantee',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 24,
                      fontWeight: FontWeight.w900,
                      color: textPrim,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Our strict promise to every prospective pet adopter and every young companion.',
                style: TextStyle(fontSize: 14, color: textSec),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: points.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E222A) : const Color(0xFFF9F7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.naturalSageGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            points[index],
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w600,
                              color: textPrim,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 8. INTERACTIVE DEMO & CALL TO ACTION =================
  Widget _buildCallToAction(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1B1E24) : const Color(0xFFFFF3EE),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, size: 16, color: AppTheme.primaryCoral),
                    const SizedBox(width: 8),
                    Text(
                      'READY TO SEE IT IN ACTION?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.darkCoral : AppTheme.primaryDarkCoral,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Experience Whisker World Today',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary(context),
                  letterSpacing: -0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Watch our interactive platform demo on the Home page to see how companion discovery, live interactive maps, and certified health passports operate in real time.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary(context),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  HoverCard(
                    liftDistance: 4,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/?scrollTo=demo'),
                      icon: const Icon(Icons.home_rounded, size: 20),
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Tap Home to See Demo Video'),
                          SizedBox(width: 6),
                          Icon(Icons.play_circle_fill_rounded, size: 18),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryCoral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  HoverCard(
                    liftDistance: 3,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/pets'),
                      icon: const Icon(Icons.pets_rounded, size: 18),
                      label: const Text('Browse Young Pets'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: AppTheme.border(context), width: 1.5),
                        foregroundColor: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                  HoverCard(
                    liftDistance: 3,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/map'),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('View Pet Map'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: AppTheme.border(context), width: 1.5),
                        foregroundColor: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required BuildContext context,
    required bool isMobile,
    required bool isDark,
    required Color cardBg,
    required Color border,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return HoverCard(
      liftDistance: 4,
      child: Container(
        width: isMobile ? double.infinity : 550,
        padding: EdgeInsets.all(isMobile ? 22 : 32),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w800,
                color: textPrim,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: textSec,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
