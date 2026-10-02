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

/// Comprehensive How It Works Screen detailing platform features,
/// adoption workflows, caregiver processes, and direct access to the Home demo video.
class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  // 0 = Adopter Journey, 1 = Caregiver & Store Journey
  int _selectedRoleIndex = 0;

  void _navigateToHomeDemo() {
    context.go('/?scrollTo=demo');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/how-it-works') : null,
      backgroundColor: AppTheme.background(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. TOP DEMO VIDEO NOTIFICATION BANNER
            _buildTopDemoBanner(context, isMobile, isDark),

            // 2. HERO HEADER
            _buildHeroHeader(context, isMobile, isDark),

            // 3. CORE PILLARS OVERVIEW
            _buildCorePillarsSection(context, isMobile, isDark),

            // 4. ROLE-BASED STEP-BY-STEP WORKFLOW
            _buildRoleWorkflowSection(context, isMobile, isDark),

            // 5. UNDER THE HOOD: HOW THE WEB PLATFORM WORKS
            _buildPlatformArchitectureSection(context, isMobile, isDark),

            // 6. DEDICATED DEMO VIDEO PROMOTION STAGE
            _buildDemoVideoPromoSection(context, isMobile, isDark),

            // 7. FREQUENTLY ASKED QUESTIONS (FAQ)
            _buildFaqSection(context, isMobile, isDark),

            // 8. FINAL CALL TO ACTION
            _buildBottomCta(context, isMobile, isDark),

            // 9. FOOTER
            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  // ================= 1. TOP DEMO VIDEO BANNER =================
  Widget _buildTopDemoBanner(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C1E1B), const Color(0xFF1F242D)]
              : [const Color(0xFFFFF0EC), const Color(0xFFF3F8F5)],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryCoral.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: ResponsiveContentWrapper(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryCoral,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'Want to see Whisker World in action? ',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                  children: [
                    TextSpan(
                      text: 'Watch our cinema platform walkthrough on the Home page.',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                maxLines: isMobile ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _navigateToHomeDemo,
              icon: const Icon(Icons.home_rounded, size: 15),
              label: Text(isMobile ? 'Demo' : 'Tap Home to Watch Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCoral,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 8 : 10,
                ),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 2. HERO HEADER =================
  Widget _buildHeroHeader(BuildContext context, bool isMobile, bool isDark) {
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
                        'COMPLETE APPLICATION & PLATFORM GUIDE',
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

              // Title
              Text(
                'How Whisker World Works',
                style: TextStyle(
                  fontSize: isMobile ? 32 : 52,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -1.2,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'Whisker World is an ethical companion adoption platform connecting loving families with newborn and young pets from certified stores and licensed caregivers. Explore how our search, live discovery map, certified veterinary passports, and adoption applications seamlessly operate.',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    color: textSec,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Action buttons (including prominent TAP HOME button for demo video!)
              Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  HoverCard(
                    liftDistance: 4,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToHomeDemo,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      onPressed: () => context.go('/pets'),
                      icon: const Icon(Icons.pets_rounded, size: 18),
                      label: const Text('Browse Young Pets'),
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
                      onPressed: () => context.go('/map'),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('Open Interactive Map'),
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

  // ================= 3. CORE PILLARS OVERVIEW =================
  Widget _buildCorePillarsSection(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final pillars = [
      {
        'icon': Icons.verified_user_rounded,
        'title': '100% Verified Caregivers',
        'desc':
            'Zero puppy mills or backyard breeders. Every nursery and pet store undergoes identity checks, physical facility inspection, and license confirmation.',
        'color': AppTheme.naturalSageGreen,
      },
      {
        'icon': Icons.medical_services_rounded,
        'title': 'Certified Health Passports',
        'desc':
            'Immutable veterinary records for every companion. Detailed timelines for DHPP, Rabies, deworming, microchip identifiers, and veterinary health notes.',
        'color': AppTheme.primaryCoral,
      },
      {
        'icon': Icons.map_rounded,
        'title': 'Live Discovery Map',
        'desc':
            'Geospatial mapping engine that pinpoints local pet stores, puppy nurseries, and companion coordinates with real-time distance calculations.',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'title': 'Transparent Adoption',
        'desc':
            'Structured questionnaires ensure ideal pet-parent matching. Track your inquiry progress live from "Submitted" to "Under Review" to "Approved".',
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 64),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Text(
              'Built on Trust, Care, and Transparency',
              style: TextStyle(
                fontSize: isMobile ? 22 : 32,
                fontWeight: FontWeight.w900,
                color: textPrim,
                letterSpacing: -0.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Four essential pillars powering the Whisker World digital experience.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: pillars.map((p) {
                final pColor = p['color'] as Color;
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
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: pColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(p['icon'] as IconData, color: pColor, size: 24),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p['title'] as String,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textPrim,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p['desc'] as String,
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

  // ================= 4. ROLE-BASED STEP-BY-STEP WORKFLOW =================
  Widget _buildRoleWorkflowSection(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final adopterSteps = [
      {
        'step': '01',
        'title': 'Discover & Filter Companions',
        'desc':
            'Filter by species (Puppies, Kittens, Birds, Rabbits, Small & Furry), age in weeks, breed pedigree, size, and temperament personality tags.',
        'icon': Icons.search_rounded,
        'badge': 'Find Pets',
      },
      {
        'step': '02',
        'title': 'Explore Nearby on the Live Map',
        'desc':
            'Switch to the interactive Map View to see physical store nurseries, companion locations, opening hours, and driving distances in your area.',
        'icon': Icons.location_on_rounded,
        'badge': 'Pet Map',
      },
      {
        'step': '03',
        'title': 'Inspect Certified Medical Passports',
        'desc':
            'Check comprehensive health status: DHPP & Rabies vaccine dates, deworming history, microchip IDs, and veterinary guarantee documentation.',
        'icon': Icons.assignment_outlined,
        'badge': 'Health Record',
      },
      {
        'step': '04',
        'title': 'Submit Direct Adoption Application',
        'desc':
            'Complete our structured questionnaire covering your home environment, schedule, and experience to send directly to the pet store caregiver.',
        'icon': Icons.rate_review_outlined,
        'badge': 'Inquiry Form',
      },
      {
        'step': '05',
        'title': 'Track Status & Schedule Meet-and-Greet',
        'desc':
            'Follow real-time progress on your Adopter Dashboard. Receive caregiver responses, schedule visitations, and finalize the adoption safely.',
        'icon': Icons.favorite_border_rounded,
        'badge': 'Welcome Home',
      },
    ];

    final ownerSteps = [
      {
        'step': '01',
        'title': 'Register Verified Store Profile',
        'desc':
            'Submit your pet store or licensed breeding nursery profile with verified licensing, physical location, opening hours, and humane care guidelines.',
        'icon': Icons.storefront_rounded,
        'badge': 'Store Setup',
      },
      {
        'step': '02',
        'title': 'List Newborn & Young Companions',
        'desc':
            'Add adorable puppy and kitten listings with high-resolution photo galleries, birth dates, breed lineage, and personality traits.',
        'icon': Icons.pets_rounded,
        'badge': 'Pet Listings',
      },
      {
        'step': '03',
        'title': 'Maintain Digital Vaccine Passports',
        'desc':
            'Log vaccination milestones, vet clinic visits, deworming administration, and microchip registration directly into the pet dossier.',
        'icon': Icons.medical_information_rounded,
        'badge': 'Vet Passport',
      },
      {
        'step': '04',
        'title': 'Screen Inquiries & Review Applicants',
        'desc':
            'Receive notifications for incoming adoption applications. Review household questionnaires, communicate with families, and approve matches.',
        'icon': Icons.mark_email_unread_outlined,
        'badge': 'Inquiries',
      },
      {
        'step': '05',
        'title': 'Handover & Transfer of Care',
        'desc':
            'Coordinate safe in-store handover, transfer official medical passports to the new family, and mark the companion as successfully adopted.',
        'icon': Icons.thumb_up_alt_outlined,
        'badge': 'Handover',
      },
    ];

    final currentSteps = _selectedRoleIndex == 0 ? adopterSteps : ownerSteps;

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : const Color(0xFFF7F4EE),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            // Section Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.3)),
              ),
              child: Text(
                'END-TO-END WORKFLOW GUIDE',
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
              'How the Process Works For You',
              style: TextStyle(
                fontSize: isMobile ? 26 : 38,
                fontWeight: FontWeight.w900,
                color: textPrim,
                letterSpacing: -0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Choose your role to inspect the tailored step-by-step experience.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Role Toggle Buttons
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRoleTabButton(
                    context: context,
                    title: 'For Pet Adopters & Families',
                    icon: Icons.favorite_rounded,
                    isSelected: _selectedRoleIndex == 0,
                    onTap: () => setState(() => _selectedRoleIndex = 0),
                  ),
                  _buildRoleTabButton(
                    context: context,
                    title: 'For Pet Stores & Caregivers',
                    icon: Icons.storefront_rounded,
                    isSelected: _selectedRoleIndex == 1,
                    onTap: () => setState(() => _selectedRoleIndex = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Steps Grid
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentSteps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final s = currentSteps[index];
                return HoverCard(
                  liftDistance: 3,
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 18 : 24),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Number Pill
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryCoral, AppTheme.primaryDarkCoral],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCoral.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              s['step'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Step Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s['title'] as String,
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.w800,
                                        color: textPrim,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryCoral.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      s['badge'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppTheme.darkCoral : AppTheme.primaryDarkCoral,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s['desc'] as String,
                                style: TextStyle(
                                  fontSize: 14,
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTabButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 22,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCoral : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCoral.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 5. UNDER THE HOOD: HOW THE WEB PLATFORM WORKS =================
  Widget _buildPlatformArchitectureSection(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final techFeatures = [
      {
        'icon': Icons.bolt_rounded,
        'title': 'Reactive Client State Management',
        'desc':
            'Powered by Flutter Provider with immediate local synchronization. When an adopter sends an inquiry or a caregiver updates a pet status, UI elements reflect changes instantaneously.',
      },
      {
        'icon': Icons.pin_drop_rounded,
        'title': 'Integrated Proximity Geolocation',
        'desc':
            'Calculates distance matrices between your current location and registered pet nurseries, enabling real-time distance sorting and interactive pin previews on the Pet Map.',
      },
      {
        'icon': Icons.shield_rounded,
        'title': 'Role Guarding & Security',
        'desc':
            'Strict GoRouter navigation guards separate Adopter and Caregiver routes. Sensitive medical records and personal questionnaires are strictly shielded by role authorization.',
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'title': 'Adaptive Modern Design System',
        'desc':
            'Designed with fluid typography, responsive flex grids, micro-interactions, and instant theme switching between light and dark modes across mobile, tablet, and desktop.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Text(
              'Under the Hood: Web Application Architecture',
              style: TextStyle(
                fontSize: isMobile ? 22 : 32,
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
                'Whisker World is engineered for high performance, verified security, and fluid usability.',
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
              children: techFeatures.map((f) {
                return HoverCard(
                  liftDistance: 4,
                  child: Container(
                    width: isMobile ? double.infinity : 550,
                    padding: const EdgeInsets.all(22),
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
                          child: Icon(f['icon'] as IconData, color: AppTheme.primaryCoral, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f['title'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textPrim,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                f['desc'] as String,
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

  // ================= 6. DEDICATED DEMO VIDEO PROMO SECTION =================
  Widget _buildDemoVideoPromoSection(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF17191E) : const Color(0xFFFAF0EB),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Container(
            padding: EdgeInsets.all(isMobile ? 24 : 44),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF261D1A), const Color(0xFF1D222B)]
                    : [Colors.white, const Color(0xFFFFF7F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.primaryCoral.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCoral.withValues(alpha: isDark ? 0.2 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.movie_creation_rounded, size: 16, color: AppTheme.primaryCoral),
                      const SizedBox(width: 8),
                      Text(
                        'SEE IT ALL IN MOTION',
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
                const SizedBox(height: 18),

                // Headline
                Text(
                  'Watch the Interactive Demo Video on Home',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 36,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary(context),
                    letterSpacing: -0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    'Our Home page features an authentic interactive cinema video player showcasing companion discovery, live interactive map filtering, medical passport verification, and the caregiver inquiry submission flow.',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: AppTheme.textSecondary(context),
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Visual Showcase Mockup / Preview
                Container(
                  constraints: const BoxConstraints(maxWidth: 580),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '4K ULTRA HD DEMO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryCoral,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FloatingWidget(
                        verticalDistance: 6,
                        duration: const Duration(milliseconds: 2400),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCoral,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryCoral.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Includes 5 Interactive Chapters',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1. Overview • 2. Companion Profiles • 3. Live Map • 4. Adoption Flow • 5. Caregiver Portal',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Big Action Button Directing User to Home Demo Video
                HoverCard(
                  liftDistance: 4,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToHomeDemo,
                    icon: const Icon(Icons.home_rounded, size: 22),
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Tap Home to See Demo Video'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCoral,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 24 : 36,
                        vertical: isMobile ? 16 : 20,
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                      elevation: 6,
                      shadowColor: AppTheme.primaryCoral.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tapping takes you directly to the Home screen and smoothly positions the video.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= 7. FREQUENTLY ASKED QUESTIONS =================
  Widget _buildFaqSection(BuildContext context, bool isMobile, bool isDark) {
    final textPrim = AppTheme.textPrimary(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);

    final faqs = [
      {
        'q': 'How does Whisker World verify pet stores and breeders?',
        'a':
            'Every listing entity must provide certified commercial registration, local regulatory licenses, and proof of ethical breeding practices. We conduct verification reviews before granting pet publishing permissions.',
      },
      {
        'q': 'Are all young pets vaccinated and vet-checked?',
        'a':
            'Yes. Every companion listed on Whisker World must have verified medical records detailing vaccination milestones (e.g., DHPP for dogs, FVRCP for cats), deworming dates, microchip IDs, and veterinary clinic records.',
      },
      {
        'q': 'How does the Live Discovery Map work?',
        'a':
            'The map queries our geocoded pet store registry. You can browse nearby stores, view which young pets are currently hosted at each location, calculate driving distance, and get immediate directions.',
      },
      {
        'q': 'What happens after I submit an adoption inquiry?',
        'a':
            'Your questionnaire is sent straight to the verified caregiver. You can track status on your Adopter Dashboard (Submitted, Reviewing, Approved) and connect directly to arrange an in-person visit.',
      },
      {
        'q': 'Is Whisker World free for pet adopters?',
        'a':
            'Yes! Browsing, filtering, map searching, saving favorites, reviewing medical passports, and submitting adoption inquiries are 100% free for families looking for a companion.',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 80),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: isMobile ? 24 : 34,
                fontWeight: FontWeight.w900,
                color: textPrim,
                letterSpacing: -0.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Everything you need to know about navigating the Whisker World platform.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: faqs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return Material(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                      iconColor: AppTheme.primaryCoral,
                      collapsedIconColor: textPrim,
                      title: Text(
                        faq['q']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrim,
                        ),
                      ),
                      children: [
                        Text(
                          faq['a']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary(context),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= 8. BOTTOM CALL TO ACTION =================
  Widget _buildBottomCta(BuildContext context, bool isMobile, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 72),
      child: ResponsiveContentWrapper(
        child: Column(
          children: [
            Text(
              'Ready to Find Your Companion?',
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                'Explore verified young puppies, kittens, birds, and bunnies or head over to the Home page to watch our full cinematic demo video.',
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
                    onPressed: _navigateToHomeDemo,
                    icon: const Icon(Icons.home_rounded, size: 20),
                    label: const Text('Tap Home to See Demo Video'),
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
                    label: const Text('Find Young Pets'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    );
  }
}
