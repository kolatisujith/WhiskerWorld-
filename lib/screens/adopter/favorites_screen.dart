import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/footer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/responsive_layout.dart';

/// Public / Adopter Screen displaying saved companion favorites
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<FavoriteProvider>().fetchFavorites(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final favProvider = context.watch<FavoriteProvider>();
    final user = authProvider.currentUser;
    final isMobile = ResponsiveLayout.isMobile(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    if (user == null) {
      return Scaffold(
        appBar: const WhiskerNavBar(),
        drawer: isMobile ? const MobileNavDrawer() : null,
        bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/favorites') : null,
        body: Center(
          child: EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Sign In to Save Favorites',
            description: 'Create an account or sign in to keep track of adorable puppies, kittens, and young companions you love.',
            actionLabel: 'Sign In Now',
            actionIcon: Icons.login_rounded,
            onAction: () => context.go('/login'),
          ),
        ),
      );
    }

    final favoritePets = favProvider.favoritePets;

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/favorites') : null,
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
                                'My Favorites',
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
                                  color: const Color(0xFFE91E63).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '❤️ ${favoritePets.length} Saved',
                                  style: const TextStyle(
                                    color: Color(0xFFE91E63),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your personal shortlist of young companions. Easily apply to adopt or review their health details.',
                            style: TextStyle(color: textSec, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/pets'),
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Find More Pets'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.border(context)),

            // Content Grid
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 40.0,
              ),
              child: ResponsiveContentWrapper(
                child: favProvider.isLoading
                    ? const LoadingWidget(message: 'Loading saved companions...')
                    : favoritePets.isEmpty
                        ? EmptyState.noFavorites(
                            onExplore: () => context.go('/pets'),
                          )
                        : LayoutBuilder(
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
                                itemCount: favoritePets.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  childAspectRatio: 0.65,
                                ),
                                itemBuilder: (context, index) {
                                  final pet = favoritePets[index];
                                  return PetCard(
                                    pet: pet,
                                    isFavorite: true,
                                    onFavoriteToggle: () async {
                                      await favProvider.removeFavorite(user.id, pet.id);
                                    },
                                  );
                                },
                              );
                            },
                          ),
              ),
            ),

            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }
}
