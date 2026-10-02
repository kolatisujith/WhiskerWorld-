import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/enums.dart';
import '../providers/auth_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/animations/floating_widget.dart';
import '../widgets/animations/hover_card.dart';
import '../widgets/animations/scroll_fade_slide.dart';
import '../widgets/footer.dart';
import '../widgets/home/demo_video_showcase.dart';
import '../widgets/mobile_navbar.dart';
import '../widgets/navbar.dart';
import '../widgets/pet_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/store_card.dart';
import '../widgets/whisker_search_bar.dart';

/// Production-ready Whisker World Homepage with all 8 requested sections, responsive grids, and dark mode
class HomeScreen extends StatefulWidget {
  final String? scrollToSection;

  const HomeScreen({super.key, this.scrollToSection});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _quickSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _demoVideoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().fetchFeaturedPets();
      context.read<StoreProvider>().fetchStores();
      _checkScrollTarget();
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollToSection != oldWidget.scrollToSection && widget.scrollToSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkScrollTarget();
      });
    }
  }

  void _checkScrollTarget() {
    final target = widget.scrollToSection?.toLowerCase();
    if (target == 'demo' || target == 'video') {
      _scrollToDemo();
    }
  }

  void _scrollToDemo() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (_demoVideoKey.currentContext != null) {
        Scrollable.ensureVisible(
          _demoVideoKey.currentContext!,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
          alignment: 0.04,
        );
      }
    });
  }

  @override
  void dispose() {
    _quickSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final petProvider = context.watch<PetProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/') : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // 1. HERO SECTION
            _buildHeroSection(context, isMobile),

            // 1B. DEMO VIDEO WALKTHROUGH SECTION
            KeyedSubtree(
              key: _demoVideoKey,
              child: _buildDemoVideoSection(context, isMobile),
            ),

            // 2. FEATURED YOUNG PETS
            _buildFeaturedPetsSection(context, isMobile, petProvider),

            // 3. BROWSE CATEGORIES
            _buildCategoriesSection(context, isMobile),

            // 4. FEATURED PET STORES
            _buildFeaturedStoresSection(context, isMobile, storeProvider),

            // 5. HOW IT WORKS
            _buildHowItWorksSection(context, isMobile),

            // 6. WHY WHISKER WORLD
            _buildWhyWhiskerWorldSection(context, isMobile),

            // 7. RESPONSIBLE ADOPTION
            _buildResponsibleAdoptionSection(context, isMobile),

            // 8. CAREGIVER CTA BANNER (if not logged in as owner)
            if (!authProvider.isAuthenticated || authProvider.currentUser?.role != UserRole.petOwner)
              _buildOwnerCtaBanner(context, isMobile),

            // FOOTER
            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  // ================= 1. HERO SECTION =================
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    final isDark = AppTheme.isDark(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.background(context),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Photographic Background with Opacity and Seamless Blending
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.22 : 0.20,
              child: Image.asset(
                'assets/images/hero_companion_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Multi-Layer Gradient Overlays for High-Contrast Text Legibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background(context).withValues(alpha: isDark ? 0.85 : 0.82),
                    AppTheme.background(context).withValues(alpha: isDark ? 0.70 : 0.65),
                    AppTheme.background(context),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Ambient Floating Particles & Accents
          if (isDesktop) ...[
            Positioned(
              left: 40,
              top: 80,
              child: FloatingWidget(
                verticalDistance: 12,
                horizontalDistance: 6,
                maxRotation: 0.12,
                duration: const Duration(milliseconds: 3600),
                child: _buildFloatingBadge('🐾 100% Pediatric Vet Cleared', const Color(0xFF10B981), Icons.verified_rounded, isDark: isDark),
              ),
            ),
            Positioned(
              right: 40,
              top: 100,
              child: FloatingWidget(
                verticalDistance: 14,
                horizontalDistance: 8,
                phaseOffset: 0.45,
                duration: const Duration(milliseconds: 4000),
                child: _buildFloatingBadge('📍 Live Pet & Store Map', const Color(0xFF0D9488), Icons.map_rounded, isDark: isDark),
              ),
            ),
            Positioned(
              right: 80,
              bottom: 60,
              child: FloatingWidget(
                verticalDistance: 10,
                horizontalDistance: 4,
                phaseOffset: 0.75,
                duration: const Duration(milliseconds: 3200),
                child: _buildFloatingBadge('💛 5,000+ Happy Adoptions', const Color(0xFFFF6B6B), Icons.favorite_rounded, isDark: isDark),
              ),
            ),
            Positioned(
              left: 120,
              bottom: 70,
              child: FloatingWidget(
                verticalDistance: 16,
                maxRotation: 0.2,
                phaseOffset: 0.2,
                duration: const Duration(milliseconds: 4400),
                child: Text('🐾', style: TextStyle(fontSize: 32, color: Colors.orange.withValues(alpha: 0.4))),
              ),
            ),
            Positioned(
              right: 220,
              top: 50,
              child: FloatingWidget(
                verticalDistance: 10,
                maxRotation: -0.15,
                phaseOffset: 0.6,
                duration: const Duration(milliseconds: 3000),
                child: Text('✨', style: TextStyle(fontSize: 24, color: Colors.amber.withValues(alpha: 0.5))),
              ),
            ),
          ],

          // 4. Hero Content Wrapped in ScrollEntrance
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 48.0 : 80.0,
            ),
            child: ResponsiveContentWrapper(
              child: ScrollFadeSlide(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    // Motto Badge
                    FloatingWidget(
                      verticalDistance: 4,
                      duration: const Duration(milliseconds: 2800),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCoral.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🐾', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Text(
                              'Every Paw Deserves a Loving Home',
                              style: TextStyle(
                                color: AppTheme.primaryDarkCoral,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Heading
                    Text(
                      'Find Your New Best Friend',
                      style: TextStyle(
                        fontSize: isMobile ? 36 : 60,
                        fontWeight: FontWeight.w900,
                        color: textPrim,
                        letterSpacing: -1.4,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // Subtitle
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        'Connecting caring families with adorable puppies, kittens, baby birds, baby rabbits, and young companions from certified pet stores and ethical caregivers.',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 18,
                          height: 1.6,
                          color: textSec,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Search Bar
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: HoverCard(
                        liftDistance: 4,
                        scale: 1.01,
                        child: WhiskerSearchBar(
                          controller: _quickSearchController,
                          hintText: 'Search by companion name, breed, species or location...',
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              context.read<PetProvider>().setSearchQuery(val.trim());
                              context.go('/pets');
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Stats Bar
                    Wrap(
                      spacing: isMobile ? 12 : 24,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        HoverCard(
                          liftDistance: 3,
                          child: _buildStatPill(context, '100% Verified', 'Certified Health & Care', Icons.verified_user_rounded),
                        ),
                        HoverCard(
                          liftDistance: 3,
                          child: _buildStatPill(context, 'Ethical Caregivers', 'Transparent History', Icons.favorite_rounded),
                        ),
                        HoverCard(
                          liftDistance: 3,
                          child: _buildStatPill(context, 'Interactive Live Map', 'Stores & Pet Locations', Icons.map_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Watch Demo CTA Pill
                    HoverCard(
                      liftDistance: 2,
                      scale: 1.02,
                      child: InkWell(
                        onTap: _scrollToDemo,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCoral.withValues(alpha: isDark ? 0.18 : 0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_circle_fill_rounded, size: 20, color: AppTheme.primaryCoral),
                              const SizedBox(width: 8),
                              Text(
                                'Watch Interactive Platform Demo ↓',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppTheme.darkCoral : AppTheme.primaryDarkCoral,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge(String text, Color accent, IconData icon, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE61E293B) : const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 1B. DEMO VIDEO WALKTHROUGH =================
  Widget _buildDemoVideoSection(BuildContext context, bool isMobile) {
    final isDark = AppTheme.isDark(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 44.0 : 72.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          delay: const Duration(milliseconds: 150),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, size: 16, color: AppTheme.primaryCoral),
                    const SizedBox(width: 8),
                    Text(
                      'PRODUCT TOUR & PLATFORM DEMO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryDarkCoral,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'See How Whisker World Works',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Watch our interactive walkthrough below to discover how our verified companion listings, live interactive pet discovery map, direct caregiver messaging, and certified veterinary passports make adoption joyful and secure.',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: textSec,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // Cinema Demo Video Showcase
              const DemoVideoShowcase(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, String title, String sub, IconData icon) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.naturalSageGreen),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textPrim),
              ),
              Text(
                sub,
                style: TextStyle(fontSize: 10, color: textSec),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 2. FEATURED YOUNG PETS =================
  Widget _buildFeaturedPetsSection(BuildContext context, bool isMobile, PetProvider petProvider) {
    final pets = petProvider.featuredPets.isNotEmpty
        ? petProvider.featuredPets
        : petProvider.pets.take(6).toList();
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40.0 : 64.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCoral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🐾 NEW ARRIVALS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryCoral,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Featured Young Companions',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.w900,
                            color: textPrim,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Meet loving puppies, kittens, chicks, and kits awaiting a forever family.',
                          style: TextStyle(fontSize: 14, color: textSec),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    HoverCard(
                      liftDistance: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/pets'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('View All Pets'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              if (pets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text('Loading adorable companions...', style: TextStyle(color: textSec)),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 4;
                    if (constraints.maxWidth < 640) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 960) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth < 1200) {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pets.length.clamp(0, 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        return HoverCard(
                          liftDistance: 6,
                          child: PetCard(pet: pets[index]),
                        );
                      },
                    );
                  },
                ),

              if (isMobile) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/pets'),
                    icon: const Icon(Icons.pets_rounded, size: 16),
                    label: const Text('Explore All Companions'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= 3. BROWSE CATEGORIES =================
  Widget _buildCategoriesSection(BuildContext context, bool isMobile) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final categories = [
      {'emoji': '🐶', 'title': 'Puppies', 'type': AnimalType.dog, 'desc': 'Golden, Frenchie, Beagle'},
      {'emoji': '🐱', 'title': 'Kittens', 'type': AnimalType.cat, 'desc': 'Ragdoll, British Blue, Tabby'},
      {'emoji': '🐰', 'title': 'Baby Bunnies', 'type': AnimalType.rabbit, 'desc': 'Holland Lop, Dwarf'},
      {'emoji': '🦜', 'title': 'Chicks & Birds', 'type': AnimalType.bird, 'desc': 'Cockatiels, Budgies'},
      {'emoji': '🐹', 'title': 'Small Animals', 'type': AnimalType.other, 'desc': 'Hamsters, Guinea Pigs'},
      {'emoji': '🦎', 'title': 'Reptiles & Fish', 'type': AnimalType.reptile, 'desc': 'Geckos, Fancy Guppies'},
    ];

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40.0 : 64.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Text(
                'Browse by Companion Type',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Explore specialized young pet categories tailored for every home and lifestyle.',
                style: TextStyle(fontSize: 14, color: textSec),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: categories.map((cat) {
                  return HoverCard(
                    liftDistance: 6,
                    scale: 1.03,
                    child: InkWell(
                      onTap: () {
                        context.read<PetProvider>().setFilters(animalType: cat['type'] as AnimalType);
                        context.go('/pets');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: isMobile ? 150 : 170,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(cat['emoji'] as String, style: const TextStyle(fontSize: 38)),
                            const SizedBox(height: 12),
                            Text(
                              cat['title'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: textPrim,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat['desc'] as String,
                              style: TextStyle(fontSize: 11, color: textSec),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 4. FEATURED PET STORES =================
  Widget _buildFeaturedStoresSection(BuildContext context, bool isMobile, StoreProvider storeProvider) {
    final stores = storeProvider.stores.take(3).toList();
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40.0 : 64.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.naturalSageGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🏡 CERTIFIED CARE CENTERS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.naturalSageGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Verified Pet Stores & Sanctuaries',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.w900,
                            color: textPrim,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Every store is audited for health standards, ethical breeding, and lifetime caregiver care.',
                          style: TextStyle(fontSize: 14, color: textSec),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    HoverCard(
                      liftDistance: 3,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/stores'),
                        icon: const Icon(Icons.storefront_rounded, size: 16),
                        label: const Text('Explore All Stores'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              if (stores.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('Loading verified caregiver centers...', style: TextStyle(color: textSec)),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 3;
                    if (constraints.maxWidth < 720) {
                      crossAxisCount = 1;
                    } else if (constraints.maxWidth < 1050) {
                      crossAxisCount = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stores.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        final count = storeProvider.storePetCounts[store.id] ?? 0;
                        return HoverCard(
                          liftDistance: 6,
                          child: StoreCard(store: store, petCount: count),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 5. HOW IT WORKS =================
  Widget _buildHowItWorksSection(BuildContext context, bool isMobile) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final steps = [
      {
        'step': '01',
        'title': 'Discover Companions',
        'desc': 'Browse verified puppies, kittens, and young companions with detailed health and vaccine records.',
        'icon': Icons.search_rounded,
      },
      {
        'step': '02',
        'title': 'Apply & Connect',
        'desc': 'Submit a comprehensive adoption questionnaire directly to verified stores and caregivers.',
        'icon': Icons.description_outlined,
      },
      {
        'step': '03',
        'title': 'Welcome Home',
        'desc': 'Finalize adoption, receive complete certified vet documentation, and begin your loving journey.',
        'icon': Icons.home_rounded,
      },
    ];

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40.0 : 64.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'SIMPLE 3-STEP PROCESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDarkCoral,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How Adoption Works on Whisker World',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: steps.map((s) {
                  return HoverCard(
                    liftDistance: 6,
                    child: Container(
                      width: isMobile ? double.infinity : 320,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(s['icon'] as IconData, color: AppTheme.primaryCoral, size: 24),
                              ),
                              Text(
                                s['step'] as String,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: textSec.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            s['title'] as String,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrim),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s['desc'] as String,
                            style: TextStyle(fontSize: 13, color: textSec, height: 1.5),
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
      ),
    );
  }

  // ================= 6. WHY WHISKER WORLD =================
  Widget _buildWhyWhiskerWorldSection(BuildContext context, bool isMobile) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final pillars = [
      {
        'title': 'Certified Health Verified',
        'desc': 'All pets undergo thorough pediatric veterinary examinations, core vaccinations, and deworming protocols.',
        'icon': Icons.medical_services_outlined,
        'color': AppTheme.naturalSageGreen,
      },
      {
        'title': 'Ethical Caregivers Only',
        'desc': 'We partner exclusively with verified shelters, nurseries, and humane pet sanctuaries with transparent facilities.',
        'icon': Icons.verified_rounded,
        'color': AppTheme.primaryCoral,
      },
      {
        'title': 'Young Pet Specialization',
        'desc': 'Tailored onboarding, feeding guides, and proofing advice for fragile newborn and young companions.',
        'icon': Icons.child_care_rounded,
        'color': const Color(0xFF1E88E5),
      },
      {
        'title': 'Secure Transparent Flow',
        'desc': 'Full questionnaire review, status tracking, and SQLite atomic transactions safeguard every adoption step.',
        'icon': Icons.shield_outlined,
        'color': const Color(0xFF8E24AA),
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40.0 : 64.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Text(
                'Why Choose Whisker World',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We prioritize companion wellbeing, lifetime family matchmaking, and zero tolerance for puppy mills.',
                style: TextStyle(fontSize: 14, color: textSec),
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
                    liftDistance: 6,
                    child: Container(
                      width: isMobile ? double.infinity : 260,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: pColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(p['icon'] as IconData, color: pColor, size: 24),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            p['title'] as String,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrim),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p['desc'] as String,
                            style: TextStyle(fontSize: 12, color: textSec, height: 1.5),
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
      ),
    );
  }

  // ================= 7. RESPONSIBLE ADOPTION =================
  Widget _buildResponsibleAdoptionSection(BuildContext context, bool isMobile) {
    final isDark = AppTheme.isDark(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final guidelines = [
      {'title': 'Lifetime Commitment', 'desc': 'Puppies, kittens, and young pets live 12–20 years. Ensure your family is ready for the long journey.'},
      {'title': 'Proofing Your Home', 'desc': 'Hide electrical cables, remove toxic house plants, and create a cozy resting area before bringing your pet home.'},
      {'title': 'Pediatric Vet Care', 'desc': 'Keep vaccine boosters, deworming, and microchipping up-to-date with your local certified veterinarian.'},
      {'title': 'Patience & Socialization', 'desc': 'Young companions need positive reinforcement, gentle bonding, and steady routines to thrive.'},
    ];

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40.0 : 64.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.naturalSageGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'CARE COMMITMENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.naturalSageGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Responsible Pet Parenting Guidelines',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w900,
                  color: textPrim,
                  letterSpacing: -0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: guidelines.map((g) {
                  return HoverCard(
                    liftDistance: 4,
                    child: Container(
                      width: isMobile ? double.infinity : 260,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.naturalSageGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  g['title']!,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrim),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            g['desc']!,
                            style: TextStyle(fontSize: 12, color: textSec, height: 1.45),
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
      ),
    );
  }

  // ================= 8. OWNER CTA BANNER =================
  Widget _buildOwnerCtaBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkCoral,
        image: const DecorationImage(
          image: AssetImage('assets/images/caregiver_cta_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color(0xEB9E2A2B), // Deep rich coral overlay
            BlendMode.srcOver,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 36.0 : 54.0),
      child: ResponsiveContentWrapper(
        child: ScrollFadeSlide(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🌟 CAREGIVER & STORE PARTNERSHIP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Are You an Ethical Pet Caregiver or Store Owner?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register your certified nursery, list young companions, and review qualified adopter applications with full peace of mind.',
                      style: TextStyle(fontSize: 14, color: Colors.white, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              HoverCard(
                liftDistance: 4,
                scale: 1.04,
                child: ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.charcoal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text('Partner With Us', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
