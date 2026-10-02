import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../providers/adoption_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/adoption_request_card.dart';
import '../../widgets/dashboard_sidebar.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/footer.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/responsive_layout.dart';

/// Adopter Dashboard Screen for Pet Adopters with Desktop Sidebar and Responsive Cards
class AdopterDashboardScreen extends StatefulWidget {
  const AdopterDashboardScreen({super.key});

  @override
  State<AdopterDashboardScreen> createState() => _AdopterDashboardScreenState();
}

class _AdopterDashboardScreenState extends State<AdopterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<FavoriteProvider>().fetchFavorites(user.id);
        context.read<AdoptionProvider>().fetchAdopterRequests(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favProvider = context.watch<FavoriteProvider>();
    final adoptionProvider = context.watch<AdoptionProvider>();
    final user = authProvider.currentUser;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final pendingCount = adoptionProvider.adopterRequests.where((r) => r.request.status == AdoptionRequestStatus.pending).length;
    final approvedCount = adoptionProvider.adopterRequests.where((r) => r.request.status == AdoptionRequestStatus.approved).length;
    final completedCount = adoptionProvider.adopterRequests.where((r) => r.request.status == AdoptionRequestStatus.completed).length;

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/adopter/dashboard') : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              color: cardBg,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 36.0,
              ),
              child: ResponsiveContentWrapper(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Adopter Dashboard',
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: textPrim,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.naturalSageGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '❤️ Pet Adopter',
                                  style: TextStyle(
                                    color: AppTheme.naturalSageGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Welcome back, ${user?.name ?? "Adopter"}! Find and welcome your next loving family companion.',
                            style: TextStyle(color: textSec, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/pets'),
                        icon: const Icon(Icons.pets_rounded, size: 18),
                        label: const Text('Find Companions'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.border(context)),

            // Main Content Area with Desktop Sidebar
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 40.0,
              ),
              child: ResponsiveContentWrapper(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Sidebar
                          DashboardSidebar(
                            role: UserRole.petAdopter,
                            activeRoute: '/adopter/dashboard',
                            pendingCount: pendingCount,
                            extraCount: favProvider.favoritePetIds.length,
                          ),
                          const SizedBox(width: 32),

                          // Right Dashboard Content
                          Expanded(
                            child: _buildDashboardContent(
                              context,
                              favProvider,
                              adoptionProvider,
                              pendingCount,
                              approvedCount,
                              completedCount,
                            ),
                          ),
                        ],
                      )
                    : _buildDashboardContent(
                        context,
                        favProvider,
                        adoptionProvider,
                        pendingCount,
                        approvedCount,
                        completedCount,
                      ),
              ),
            ),

            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    FavoriteProvider favProvider,
    AdoptionProvider adoptionProvider,
    int pendingCount,
    int approvedCount,
    int completedCount,
  ) {
    final textPrim = AppTheme.textPrimary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth < 640 ? 1 : (constraints.maxWidth < 960 ? 2 : 4);
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: cols == 1 ? 2.8 : 1.7,
              children: [
                DashboardStatCard(
                  title: 'Saved Favorites',
                  value: '${favProvider.favoritePetIds.length}',
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFE91E63),
                  onTap: () => context.go('/favorites'),
                ),
                DashboardStatCard(
                  title: 'Pending Inquiries',
                  value: '$pendingCount',
                  icon: Icons.hourglass_top_rounded,
                  iconColor: const Color(0xFFF39C12),
                  onTap: () => context.go('/adopter/requests'),
                ),
                DashboardStatCard(
                  title: 'Approved In-Progress',
                  value: '$approvedCount',
                  icon: Icons.thumb_up_alt_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  onTap: () => context.go('/adopter/requests'),
                ),
                DashboardStatCard(
                  title: 'Completed Adoptions',
                  value: '$completedCount',
                  icon: Icons.verified_rounded,
                  iconColor: AppTheme.naturalSageGreen,
                  onTap: () => context.go('/adopter/history'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),

        // Interactive Pet & Store Map Discovery Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D9488).withValues(alpha: 0.12),
                AppTheme.primaryCoral.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF0D9488).withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.map_rounded, size: 28, color: Color(0xFF0D9488)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pet Stores & Pet Owners Map',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textPrim,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore pet stores, verified pet owners, and track your chosen companion\'s exact location on our live map.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final firstRequestedPetId = adoptionProvider.adopterRequests.firstOrNull?.pet?.id;
                  if (firstRequestedPetId != null) {
                    context.go('/map?petId=$firstRequestedPetId');
                  } else {
                    context.go('/map');
                  }
                },
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text('Open Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Recent Applications Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Applications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrim,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/adopter/requests'),
              child: const Text('View All Applications →'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (adoptionProvider.adopterRequests.isEmpty)
          EmptyState.noRequests(
            onExplore: () => context.go('/pets'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: adoptionProvider.adopterRequests.take(2).length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = adoptionProvider.adopterRequests[index];
              return AdoptionRequestCard(
                details: req,
                isOwnerView: false,
                onViewPet: () => context.go('/pets/${req.request.petId}'),
              );
            },
          ),
        const SizedBox(height: 40),

        // Quick Favorites Preview Section
        if (favProvider.favoritePets.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Saved Companions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textPrim,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/favorites'),
                child: const Text('View All Favorites →'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth < 640 ? 1 : (constraints.maxWidth < 960 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favProvider.favoritePets.take(3).length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  return PetCard(pet: favProvider.favoritePets[index]);
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
