import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../providers/adoption_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/adoption_request_card.dart';
import '../../widgets/dashboard_sidebar.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/footer.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/responsive_layout.dart';

/// Owner Dashboard Screen for Pet Owners and Store Managers with Desktop Sidebar and Responsive Cards
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<PetProvider>().fetchMyPets(user.id);
        context.read<StoreProvider>().fetchMyStores(user.id);
        context.read<AdoptionProvider>().fetchOwnerRequests(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final petProvider = context.watch<PetProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final adoptionProvider = context.watch<AdoptionProvider>();
    final user = authProvider.currentUser;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final pendingCount = adoptionProvider.ownerRequests.where((r) => r.request.status == AdoptionRequestStatus.pending).length;
    final availablePetsCount = petProvider.myPets.where((p) => p.isAvailable).length;

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/owner/dashboard') : null,
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
                                'Owner Dashboard',
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
                                  color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '🐾 Pet Caregiver',
                                  style: TextStyle(
                                    color: AppTheme.primaryDarkCoral,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Welcome back, ${user?.name ?? "Owner"}! Manage listings, stores, and review adoption inquiries.',
                            style: TextStyle(color: textSec, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/owner/pets/add'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Young Pet'),
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
                            role: UserRole.petOwner,
                            activeRoute: '/owner/dashboard',
                            pendingCount: pendingCount,
                          ),
                          const SizedBox(width: 32),

                          // Right Dashboard Content
                          Expanded(
                            child: _buildDashboardContent(
                              context,
                              petProvider,
                              storeProvider,
                              adoptionProvider,
                              pendingCount,
                              availablePetsCount,
                            ),
                          ),
                        ],
                      )
                    : _buildDashboardContent(
                        context,
                        petProvider,
                        storeProvider,
                        adoptionProvider,
                        pendingCount,
                        availablePetsCount,
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
    PetProvider petProvider,
    StoreProvider storeProvider,
    AdoptionProvider adoptionProvider,
    int pendingCount,
    int availablePetsCount,
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
                  title: 'My Pets Listed',
                  value: '${petProvider.myPets.length}',
                  icon: Icons.pets_rounded,
                  iconColor: AppTheme.primaryCoral,
                  onTap: () => context.go('/owner/pets'),
                ),
                DashboardStatCard(
                  title: 'Available for Adoption',
                  value: '$availablePetsCount',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppTheme.naturalSageGreen,
                  onTap: () => context.go('/owner/pets'),
                ),
                DashboardStatCard(
                  title: 'My Pet Stores',
                  value: '${storeProvider.myStores.length}',
                  icon: Icons.storefront_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  onTap: () => context.go('/owner/stores'),
                ),
                DashboardStatCard(
                  title: 'Adoption Inquiries',
                  value: '$pendingCount',
                  icon: Icons.mark_email_unread_outlined,
                  iconColor: const Color(0xFFF39C12),
                  onTap: () => context.go('/owner/requests'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 40),

        // Recent Inquiries
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Inquiries',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrim,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/owner/requests'),
              child: const Text('View All Inquiries →'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (adoptionProvider.ownerRequests.isEmpty)
          EmptyState.noRequests(
            isOwner: true,
            onExplore: () => context.go('/owner/pets/add'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: adoptionProvider.ownerRequests.take(2).length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = adoptionProvider.ownerRequests[index];
              return AdoptionRequestCard(
                details: req,
                isOwnerView: true,
                onViewPet: () => context.go('/pets/${req.request.petId}'),
              );
            },
          ),
        const SizedBox(height: 40),

        // My Young Pets Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Companion Listings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrim,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/owner/pets'),
              child: const Text('Manage All Pets →'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (petProvider.myPets.isEmpty)
          EmptyState(
            icon: Icons.pets_rounded,
            title: 'No Pets Listed Yet',
            description: 'You haven\'t listed any puppies, kittens, or young companions yet. Add your first companion to begin connecting with adopters!',
            actionLabel: 'Add Young Pet',
            actionIcon: Icons.add_rounded,
            onAction: () => context.go('/owner/pets/add'),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              int cols = constraints.maxWidth < 640 ? 1 : (constraints.maxWidth < 960 ? 2 : 3);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: petProvider.myPets.take(3).length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  return PetCard(
                    pet: petProvider.myPets[index],
                    showOwnerActions: true,
                    onEdit: () => context.go('/owner/pets/${petProvider.myPets[index].id}/edit'),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
