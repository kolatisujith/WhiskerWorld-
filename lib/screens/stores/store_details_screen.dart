import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../providers/store_provider.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/responsive_layout.dart';

/// Store Details Profile and Store-Specific Pet Listings Screen
class StoreDetailsScreen extends StatefulWidget {
  final String storeId;

  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  final TextEditingController _inStoreSearchCtrl = TextEditingController();

  AnimalType? _selectedType;
  Gender? _selectedGender;
  String? _breedQuery;
  int? _maxAgeWeeks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeProvider = context.read<StoreProvider>();
      storeProvider.fetchStoreById(widget.storeId);
      storeProvider.resetStoreFilters();
      storeProvider.fetchPetsForStore(widget.storeId);
    });
  }

  @override
  void dispose() {
    _inStoreSearchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<StoreProvider>().setStoreFilters(
          searchQuery: _inStoreSearchCtrl.text.trim().isNotEmpty ? _inStoreSearchCtrl.text.trim() : null,
          animalType: _selectedType,
          breed: _breedQuery,
          gender: _selectedGender,
          maxAgeWeeks: _maxAgeWeeks,
        );
  }

  void _resetFilters() {
    setState(() {
      _inStoreSearchCtrl.clear();
      _selectedType = null;
      _selectedGender = null;
      _breedQuery = null;
      _maxAgeWeeks = null;
    });
    context.read<StoreProvider>().resetStoreFilters();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final store = storeProvider.selectedStore;
    final isMobile = ResponsiveLayout.isMobile(context);
    final pets = storeProvider.storePets;

    if (storeProvider.isLoading && store == null) {
      return const Scaffold(
        appBar: WhiskerNavBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (store == null) {
      return Scaffold(
        appBar: const WhiskerNavBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏬', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('Store Not Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('The requested pet store could not be located or may have been deactivated.'),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () => context.go('/stores'), child: const Text('Back to Stores')),
              ],
            ),
          ),
        ),
      );
    }

    final availablePetCount = storeProvider.getPetCountForStore(store.id);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Cover Image Hero Banner
            SizedBox(
              height: isMobile ? 220 : 320,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    store.displayCoverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: AppTheme.warmCream),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.charcoal),
                        onPressed: () => context.go('/stores'),
                        tooltip: 'Back to Stores',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Store Header Profile Bar
            Container(
              color: AppTheme.pureWhite,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20.0 : 28.0,
                horizontal: isMobile ? 16.0 : 32.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Avatar
                        Container(
                          width: isMobile ? 64 : 80,
                          height: isMobile ? 64 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.borderSubtle, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            store.displayLogoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(child: Text('🏬')),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Store Info Titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      store.name,
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: isMobile ? 20 : 26,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Tooltip(
                                    message: 'Verified Animal Caregiver Sanctuary',
                                    child: Icon(Icons.verified_rounded, size: 20, color: Color(0xFF3F51B5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primaryCoral),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${store.address}, ${store.fullLocation}',
                                      style: const TextStyle(fontSize: 13, color: AppTheme.charcoalLight),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  if (store.openingHours != null && store.openingHours!.isNotEmpty)
                                    _buildMetaChip(Icons.access_time_rounded, store.openingHours!, AppTheme.naturalSageGreen),
                                  _buildMetaChip(Icons.pets_rounded, '$availablePetCount Pets Available', AppTheme.primaryDarkCoral),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.borderSubtle),
                    const SizedBox(height: 14),

                    // Contact Badges & Description
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        _buildContactBadge(Icons.phone_rounded, store.phone),
                        _buildContactBadge(Icons.email_outlined, store.email),
                        if (store.website != null && store.website!.isNotEmpty)
                          _buildContactBadge(Icons.language_rounded, store.website!),
                      ],
                    ),
                    if (store.description != null && store.description!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        store.description!,
                        style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.charcoal),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 3. Store-Specific Pet Listings Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 32.0 : 48.0,
                horizontal: isMobile ? 16.0 : 24.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Pets',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.charcoal,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Companions currently sheltered at ${store.name}',
                              style: const TextStyle(color: AppTheme.charcoalLight, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warmCream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            '${pets.length} Found',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.charcoal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // In-Store Search and Filter Bar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // In-store search input
                          TextField(
                            controller: _inStoreSearchCtrl,
                            onChanged: (_) => _applyFilter(),
                            decoration: InputDecoration(
                              hintText: 'Search pets in this store...',
                              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.charcoalLight),
                              suffixIcon: _inStoreSearchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 16),
                                      onPressed: () {
                                        _inStoreSearchCtrl.clear();
                                        _applyFilter();
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppTheme.warmCream,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick filter chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text('Species:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.charcoalLight)),
                              _buildChoiceChip<AnimalType?>(
                                label: 'All',
                                isSelected: _selectedType == null,
                                onSelected: () {
                                  setState(() => _selectedType = null);
                                  _applyFilter();
                                },
                              ),
                              ...[AnimalType.dog, AnimalType.cat, AnimalType.rabbit, AnimalType.bird, AnimalType.fish, AnimalType.reptile].map((type) {
                                return _buildChoiceChip<AnimalType>(
                                  label: type.name.toUpperCase(),
                                  isSelected: _selectedType == type,
                                  onSelected: () {
                                    setState(() => _selectedType = _selectedType == type ? null : type);
                                    _applyFilter();
                                  },
                                );
                              }),
                              const SizedBox(width: 12),
                              const Text('Gender:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.charcoalLight)),
                              _buildChoiceChip<Gender>(
                                label: 'Male',
                                isSelected: _selectedGender == Gender.male,
                                onSelected: () {
                                  setState(() => _selectedGender = _selectedGender == Gender.male ? null : Gender.male);
                                  _applyFilter();
                                },
                              ),
                              _buildChoiceChip<Gender>(
                                label: 'Female',
                                isSelected: _selectedGender == Gender.female,
                                onSelected: () {
                                  setState(() => _selectedGender = _selectedGender == Gender.female ? null : Gender.female);
                                  _applyFilter();
                                },
                              ),
                              if (_selectedType != null || _selectedGender != null || _inStoreSearchCtrl.text.isNotEmpty)
                                TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.refresh_rounded, size: 14),
                                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Pet Grid (ONLY containing pets belonging to this store)
                    if (storeProvider.isStorePetsLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (pets.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(48),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            const Text('🐾', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              'No Pets Available at ${store.name}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All pets from this caregiver may currently be adopted, or no pets matched your search filters.',
                              style: TextStyle(color: AppTheme.charcoalLight),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _resetFilters,
                              child: const Text('Reset In-Store Filters'),
                            ),
                          ],
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 3;
                          if (constraints.maxWidth < 650) {
                            crossAxisCount = 1;
                          } else if (constraints.maxWidth < 950) {
                            crossAxisCount = 2;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: crossAxisCount == 1 ? 0.92 : 0.78,
                            ),
                            itemCount: pets.length,
                            itemBuilder: (context, index) {
                              final pet = pets[index];
                              return PetCard(pet: pet);
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

  Widget _buildMetaChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.warmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.charcoalLight),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.charcoal)),
        ],
      ),
    );
  }

  Widget _buildChoiceChip<T>({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryDarkCoral : AppTheme.warmCream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryDarkCoral : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.charcoal,
          ),
        ),
      ),
    );
  }
}
