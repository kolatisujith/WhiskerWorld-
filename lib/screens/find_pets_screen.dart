import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../providers/pet_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_panel.dart';
import '../widgets/footer.dart';
import '../widgets/loading_widget.dart';
import '../widgets/mobile_navbar.dart';
import '../widgets/navbar.dart';
import '../widgets/pet_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/whisker_search_bar.dart';

/// Public Pet Discovery & Search Screen with Responsive Grids & Mobile Filter Drawer
class FindPetsScreen extends StatefulWidget {
  const FindPetsScreen({super.key});

  @override
  State<FindPetsScreen> createState() => _FindPetsScreenState();
}

class _FindPetsScreenState extends State<FindPetsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petProvider = context.read<PetProvider>();
      _searchController.text = petProvider.searchQuery;
      petProvider.fetchPets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openMobileFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: FilterPanel(
                  isMobile: true,
                  onClose: () => Navigator.of(ctx).pop(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = AppTheme.isDark(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/pets') : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Header
            Container(
              width: double.infinity,
              color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 32.0 : 48.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🐾 Public Companion Discovery',
                        style: TextStyle(
                          color: AppTheme.primaryDarkCoral,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Find Your Perfect Companion',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: textPrim,
                        fontSize: isMobile ? 28 : 40,
                        letterSpacing: -0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Text(
                        'Browse verified puppies, kittens, baby bunnies, and young companions looking for a loving home.',
                        style: TextStyle(
                          color: textSec,
                          fontSize: isMobile ? 14 : 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Modern Search Bar
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: WhiskerSearchBar(
                        controller: _searchController,
                        hintText: 'Search by name, breed, species or location...',
                        hasActiveFilters: petProvider.hasActiveFilters,
                        onSubmitted: (val) => petProvider.setSearchQuery(val),
                        onClear: () => petProvider.setSearchQuery(''),
                        onFilterTap: isDesktop ? null : () => _openMobileFilterSheet(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Area: Sticky Filters & Responsive Pet Grid
            Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 24.0 : 40.0),
              child: ResponsiveContentWrapper(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Sticky Filter Sidebar
                          const SizedBox(
                            width: 290,
                            child: FilterPanel(),
                          ),
                          const SizedBox(width: 32),

                          // Right Pets Grid
                          Expanded(
                            child: _buildPetsContent(context, petProvider),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Mobile Filter & Sort Bar
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${petProvider.pets.length} companions found',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: textPrim,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _openMobileFilterSheet(context),
                                  icon: Stack(
                                    children: [
                                      const Icon(Icons.tune_rounded, size: 16),
                                      if (petProvider.hasActiveFilters)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primaryCoral,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  label: const Text('Filters & Sort'),
                                ),
                              ],
                            ),
                          ),
                          _buildPetsContent(context, petProvider),
                        ],
                      ),
              ),
            ),

            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsContent(BuildContext context, PetProvider petProvider) {
    if (petProvider.isLoading) {
      return const LoadingWidget(message: 'Searching companions...');
    }

    final pets = petProvider.pets;

    if (pets.isEmpty) {
      return EmptyState.noPets(
        onReset: () {
          _searchController.clear();
          petProvider.resetFilters();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid of Pets (3-4 columns desktop, 2-3 tablet, 1-2 mobile)
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 3;
            if (constraints.maxWidth < 620) {
              crossAxisCount = 1;
            } else if (constraints.maxWidth < 950) {
              crossAxisCount = 2;
            } else if (constraints.maxWidth >= 1200) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pets.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                return PetCard(pet: pets[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
