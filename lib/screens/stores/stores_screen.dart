import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/store_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/footer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/store_card.dart';
import '../../widgets/whisker_search_bar.dart';

/// Public Pet Stores Discovery Screen with StoreCard and WhiskerSearchBar
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final textPrim = AppTheme.textPrimary(context);

    // Filter active stores by search query (name, city, state)
    final filteredStores = storeProvider.stores.where((s) {
      if (!s.isActive) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      return s.name.toLowerCase().contains(q) ||
          s.city.toLowerCase().contains(q) ||
          (s.state?.toLowerCase().contains(q) ?? false) ||
          (s.description?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/stores') : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 36.0 : 54.0,
                horizontal: 24.0,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDarkCoral, AppTheme.primaryCoral],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Verified Partner Network',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Pet Stores & Sanctuaries',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Explore ethical breeders, licensed nurseries, and certified rescue sanctuaries.',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Search Bar
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: WhiskerSearchBar(
                        controller: _searchController,
                        hintText: 'Search by store name, city, or state...',
                        onChanged: (val) => setState(() => _searchQuery = val),
                        onClear: () => setState(() => _searchQuery = ''),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Grid
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 28.0 : 48.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredStores.length} Partner Centers Found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textPrim,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (storeProvider.isLoading)
                      const LoadingWidget(message: 'Loading verified pet stores...')
                    else if (filteredStores.isEmpty)
                      EmptyState.noStores(
                        onReset: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 3;
                          if (constraints.maxWidth < 640) {
                            crossAxisCount = 1;
                          } else if (constraints.maxWidth < 1000) {
                            crossAxisCount = 2;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredStores.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1.05,
                            ),
                            itemBuilder: (context, index) {
                              final store = filteredStores[index];
                              final petCount = storeProvider.storePetCounts[store.id] ?? 0;
                              return StoreCard(
                                store: store,
                                petCount: petCount,
                              );
                            },
                          );
                        },
                      ),
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
}
