import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/pet_model.dart';
import '../../models/pet_store_model.dart';
import '../../models/user_model.dart';
import '../../providers/map_provider.dart';
import '../../widgets/map/map_marker_card.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Full-featured Interactive Map Screen for Pet Adopters
/// Displays Pet Stores, Pet Owners, and tracks the Adopter's Chosen Pet & its Owner/Store.
class MapScreen extends StatefulWidget {
  final String? initialPetId;
  final bool enableTileLayer;

  const MapScreen({
    super.key,
    this.initialPetId,
    this.enableTileLayer = true,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSidebarOpen = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapProvider = context.read<MapProvider>();
      if (mapProvider.stores.isEmpty || widget.initialPetId != null) {
        mapProvider.loadMapData(initialPetId: widget.initialPetId).then((_) {
          if (mounted) {
            _fitAllOrCenterChosen();
          }
        });
      } else {
        _fitAllOrCenterChosen();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPetId != oldWidget.initialPetId && widget.initialPetId != null) {
      context.read<MapProvider>().choosePetById(widget.initialPetId!).then((_) {
        if (mounted) _centerOnChosenPet();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _centerOnLocation(LatLng target, {double zoom = 13.5}) {
    _mapController.move(target, zoom);
  }

  void _centerOnChosenPet() {
    final mapProvider = context.read<MapProvider>();
    final chosenPet = mapProvider.chosenPet;
    if (chosenPet != null) {
      final loc = mapProvider.getPetLocation(chosenPet);
      _centerOnLocation(loc, zoom: 13.0);
    }
  }

  void _fitAllOrCenterChosen() {
    final mapProvider = context.read<MapProvider>();
    if (mapProvider.chosenPet != null) {
      _centerOnChosenPet();
      return;
    }

    final allCoords = <LatLng>[];
    for (final s in mapProvider.stores) {
      allCoords.add(mapProvider.getStoreLocation(s));
    }
    for (final o in mapProvider.petOwners) {
      allCoords.add(mapProvider.getOwnerLocation(o));
    }

    if (allCoords.isNotEmpty) {
      _mapController.move(allCoords.first, 10.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/map') : null,
      body: Stack(
        children: [
          // 1. Core Map Canvas
          _buildMap(mapProvider, isDark),

          // 2. Top Floating Controls & Filter Bar
          Positioned(
            top: 16,
            left: 16,
            right: isDesktop && _isSidebarOpen ? 380 : 16,
            child: _buildTopControlBar(context, mapProvider),
          ),

          // 3. Desktop Collapsible Sidebar
          if (isDesktop)
            Positioned(
              top: 16,
              bottom: 16,
              right: 16,
              width: 340,
              child: _buildDesktopSidebar(context, mapProvider),
            ),

          // 4. Selected Marker Popup (when marker tapped)
          if (mapProvider.selectedItem != null)
            Positioned(
              left: 16,
              bottom: isMobile ? 80 : 24,
              right: isMobile ? 16 : null,
              child: MapMarkerCard(
                item: mapProvider.selectedItem!,
                onClose: () => mapProvider.selectItem(null),
                onCenter: () => _centerOnLocation(mapProvider.selectedItem!.coordinates),
              ),
            ),

          // 5. Floating Zoom & Map Controls
          Positioned(
            right: isDesktop && _isSidebarOpen ? 370 : 16,
            bottom: isMobile ? 80 : 24,
            child: _buildFloatingZoomControls(mapProvider),
          ),

          // 6. Loading Indicator
          if (mapProvider.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryCoral),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(MapProvider mapProvider, bool isDark) {
    final markers = _buildMarkers(mapProvider);
    final polylines = _buildPolylines(mapProvider);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: mapProvider.chosenPet != null
            ? mapProvider.getPetLocation(mapProvider.chosenPet!)
            : const LatLng(45.5152, -122.6784), // Default Portland
        initialZoom: 11.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) {
          if (mapProvider.selectedItem != null) {
            mapProvider.selectItem(null);
          }
        },
      ),
      children: [
        if (widget.enableTileLayer)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.whiskerworld.app',
            tileBuilder: isDark
                ? (context, tileWidget, tile) {
                    return ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -0.8, 0, 0, 0, 255,
                        0, -0.8, 0, 0, 255,
                        0, 0, -0.8, 0, 255,
                        0, 0, 0, 1, 0,
                      ]),
                      child: tileWidget,
                    );
                  }
                : null,
          ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  List<Polyline> _buildPolylines(MapProvider mapProvider) {
    final lines = <Polyline>[];
    final chosenPet = mapProvider.chosenPet;
    if (chosenPet == null) return lines;

    final petLoc = mapProvider.getPetLocation(chosenPet);

    // If pet is linked to a store
    if (mapProvider.chosenPetStore != null) {
      final storeLoc = mapProvider.getStoreLocation(mapProvider.chosenPetStore!);
      lines.add(
        Polyline(
          points: [petLoc, storeLoc],
          strokeWidth: 3.5,
          color: const Color(0xFF0D9488), // Emerald / Teal
          pattern: StrokePattern.dashed(segments: const [8, 6]),
        ),
      );
    }

    // If pet is linked to an owner
    if (mapProvider.chosenPetOwner != null) {
      final ownerLoc = mapProvider.getOwnerLocation(mapProvider.chosenPetOwner!);
      lines.add(
        Polyline(
          points: [petLoc, ownerLoc],
          strokeWidth: 3.5,
          color: AppTheme.primaryCoral,
          pattern: StrokePattern.dashed(segments: const [8, 6]),
        ),
      );
    }

    return lines;
  }

  List<Marker> _buildMarkers(MapProvider mapProvider) {
    final markers = <Marker>[];

    // 1. Pet Store Markers
    for (final store in mapProvider.filteredStores) {
      final loc = mapProvider.getStoreLocation(store);
      final isSelected = mapProvider.selectedItem?.store?.id == store.id;
      final isChosenPetStore = mapProvider.chosenPetStore?.id == store.id;

      markers.add(
        Marker(
          point: loc,
          width: isSelected || isChosenPetStore ? 90 : 70,
          height: isSelected || isChosenPetStore ? 70 : 56,
          child: GestureDetector(
            onTap: () {
              mapProvider.selectItem(
                SelectedMapItem(
                  type: MapItemType.store,
                  store: store,
                  coordinates: loc,
                  title: store.name,
                  subtitle: store.fullLocation,
                  imageUrl: store.logoUrl,
                ),
              );
              _centerOnLocation(loc);
            },
            child: _buildStorePin(store, isSelected: isSelected, isLinked: isChosenPetStore),
          ),
        ),
      );
    }

    // 2. Pet Owner Markers
    for (final owner in mapProvider.filteredPetOwners) {
      final loc = mapProvider.getOwnerLocation(owner);
      final isSelected = mapProvider.selectedItem?.owner?.id == owner.id;
      final isChosenPetOwner = mapProvider.chosenPetOwner?.id == owner.id;
      final ownedPets = mapProvider.ownerPets[owner.id] ?? [];

      markers.add(
        Marker(
          point: loc,
          width: isSelected || isChosenPetOwner ? 90 : 70,
          height: isSelected || isChosenPetOwner ? 70 : 56,
          child: GestureDetector(
            onTap: () {
              mapProvider.selectItem(
                SelectedMapItem(
                  type: MapItemType.owner,
                  owner: owner,
                  coordinates: loc,
                  title: owner.name,
                  subtitle: owner.location ?? 'Pet Owner',
                  imageUrl: owner.profileImage,
                  associatedPets: ownedPets,
                ),
              );
              _centerOnLocation(loc);
            },
            child: _buildOwnerPin(owner, isSelected: isSelected, isLinked: isChosenPetOwner),
          ),
        ),
      );
    }

    // 3. Chosen Pet Marker (Highlighted prominently)
    final chosenPet = mapProvider.chosenPet;
    if (chosenPet != null && mapProvider.filterMode != MapFilterMode.stores && mapProvider.filterMode != MapFilterMode.owners) {
      final loc = mapProvider.getPetLocation(chosenPet);
      markers.add(
        Marker(
          point: loc,
          width: 96,
          height: 80,
          child: GestureDetector(
            onTap: () {
              mapProvider.selectItem(
                SelectedMapItem(
                  type: MapItemType.pet,
                  pet: chosenPet,
                  coordinates: loc,
                  title: chosenPet.name,
                  subtitle: '${chosenPet.displayYoungName} • ${chosenPet.breed}',
                  imageUrl: chosenPet.primaryImageUrl,
                  associatedPets: [chosenPet],
                ),
              );
              _centerOnLocation(loc);
            },
            child: _buildChosenPetPin(chosenPet),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildStorePin(PetStoreModel store, {bool isSelected = false, bool isLinked = false}) {
    final color = isLinked ? const Color(0xFF0F766E) : const Color(0xFF0D9488);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLinked ? const Color(0xFFF59E0B) : color,
              width: isLinked ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_rounded, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  store.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_drop_down_rounded, size: 16, color: color),
      ],
    );
  }

  Widget _buildOwnerPin(UserModel owner, {bool isSelected = false, bool isLinked = false}) {
    const color = AppTheme.primaryCoral;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isLinked ? const Color(0xFFF59E0B) : color,
              width: isLinked ? 2.5 : 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_rounded, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  owner.name.split(' ').first,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_drop_down_rounded, size: 16, color: color),
      ],
    );
  }

  Widget _buildChosenPetPin(PetModel pet) {
    const goldColor = Color(0xFFF59E0B);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: goldColor.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐾', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFFEA580C)),
      ],
    );
  }

  Widget _buildTopControlBar(BuildContext context, MapProvider mapProvider) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Row + Chosen Pet Selector
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => mapProvider.setSearchQuery(val),
                          decoration: const InputDecoration(
                            hintText: 'Search stores, owners, pets, or cities...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 13, color: textPrim),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            mapProvider.setSearchQuery('');
                          },
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Chosen Pet Dropdown Selector
              _buildPetSelectorButton(context, mapProvider),
            ],
          ),
          const SizedBox(height: 10),

          // Filter Mode Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MapFilterMode.values.map((mode) {
                final isSelected = mapProvider.filterMode == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      mode.icon,
                      size: 15,
                      color: isSelected ? Colors.white : AppTheme.primaryCoral,
                    ),
                    label: Text(mode.label),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : textPrim,
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryCoral,
                    backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => mapProvider.setFilterMode(mode),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectorButton(BuildContext context, MapProvider mapProvider) {
    final chosenPet = mapProvider.chosenPet;
    final isSelected = chosenPet != null;

    return PopupMenuButton<PetModel?>(
      tooltip: 'Choose a Companion to Track',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF59E0B) : AppTheme.primaryCoral.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFD97706) : AppTheme.primaryCoral.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.primaryCoral,
            ),
            const SizedBox(width: 6),
            Text(
              isSelected ? chosenPet.name : 'Choose Pet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.primaryCoral,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.primaryCoral,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<PetModel?>>[];

        if (isSelected) {
          items.add(
            PopupMenuItem<PetModel?>(
              value: null,
              child: const Row(
                children: [
                  Icon(Icons.clear_rounded, size: 18, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Clear Chosen Pet', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
              ),
            ),
          );
          items.add(const PopupMenuDivider());
        }

        for (final pet in mapProvider.allPets) {
          items.add(
            PopupMenuItem<PetModel?>(
              value: pet,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 24,
                      height: 24,
                      color: Colors.grey.shade200,
                      child: pet.primaryImageUrl != null
                          ? Image.network(pet.primaryImageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.pets, size: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${pet.name} (${pet.breed})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return items;
      },
      onSelected: (pet) {
        if (pet == null) {
          mapProvider.clearChosenPet();
        } else {
          mapProvider.choosePet(pet);
          _centerOnChosenPet();
        }
      },
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, MapProvider mapProvider) {
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final isDark = AppTheme.isDark(context);
    final textPrim = AppTheme.textPrimary(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Explore Directory',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrim,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSidebarOpen ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                ),
                onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Divider(height: 16),

          // Chosen Pet Status Banner if active
          if (mapProvider.chosenPet != null) ...[
            _buildChosenPetSidebarBanner(context, mapProvider),
            const SizedBox(height: 12),
          ],

          // Directory Tabs & List
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppTheme.primaryCoral,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryCoral,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Stores (${mapProvider.filteredStores.length})'),
                      Tab(text: 'Owners (${mapProvider.filteredPetOwners.length})'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Stores Tab
                        ListView.builder(
                          itemCount: mapProvider.filteredStores.length,
                          itemBuilder: (context, index) {
                            final store = mapProvider.filteredStores[index];
                            final petCount = mapProvider.storePetCounts[store.id] ?? 0;
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF0D9488),
                                  radius: 18,
                                  child: Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                                ),
                                title: Text(
                                  store.name,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrim),
                                ),
                                subtitle: Text(
                                  '${store.city} • $petCount pets',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  final loc = mapProvider.getStoreLocation(store);
                                  _centerOnLocation(loc);
                                  mapProvider.selectItem(
                                    SelectedMapItem(
                                      type: MapItemType.store,
                                      store: store,
                                      coordinates: loc,
                                      title: store.name,
                                      subtitle: store.fullLocation,
                                      imageUrl: store.logoUrl,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // Owners Tab
                        ListView.builder(
                          itemCount: mapProvider.filteredPetOwners.length,
                          itemBuilder: (context, index) {
                            final owner = mapProvider.filteredPetOwners[index];
                            final pets = mapProvider.ownerPets[owner.id] ?? [];
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppTheme.primaryCoral,
                                  radius: 18,
                                  child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
                                ),
                                title: Text(
                                  owner.name,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrim),
                                ),
                                subtitle: Text(
                                  '${owner.location ?? "Owner"} • ${pets.length} pets',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  final loc = mapProvider.getOwnerLocation(owner);
                                  _centerOnLocation(loc);
                                  mapProvider.selectItem(
                                    SelectedMapItem(
                                      type: MapItemType.owner,
                                      owner: owner,
                                      coordinates: loc,
                                      title: owner.name,
                                      subtitle: owner.location ?? 'Pet Owner',
                                      imageUrl: owner.profileImage,
                                      associatedPets: pets,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildChosenPetSidebarBanner(BuildContext context, MapProvider mapProvider) {
    final pet = mapProvider.chosenPet!;
    final owner = mapProvider.chosenPetOwner;
    final store = mapProvider.chosenPetStore;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Chosen Companion: ${pet.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (store != null)
            Text(
              '🏪 Located at store: ${store.name}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          if (owner != null)
            Text(
              '👤 Pet Owner: ${owner.name}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _centerOnChosenPet,
            child: const Text(
              '🎯 Focus on Pet on Map',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryCoral),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingZoomControls(MapProvider mapProvider) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mapProvider.chosenPet != null) ...[
          FloatingActionButton.small(
            heroTag: 'focus_chosen_pet',
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            tooltip: 'Focus on Chosen Pet',
            onPressed: _centerOnChosenPet,
            child: const Icon(Icons.pets_rounded, size: 18),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton.small(
          heroTag: 'fit_all_btn',
          backgroundColor: cardBg,
          foregroundColor: AppTheme.primaryCoral,
          tooltip: 'Fit All Pins',
          onPressed: _fitAllOrCenterChosen,
          child: const Icon(Icons.fit_screen_rounded, size: 18),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_in_btn',
          backgroundColor: cardBg,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          tooltip: 'Zoom In',
          onPressed: () {
            final z = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, z + 1);
          },
          child: const Icon(Icons.add_rounded, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_out_btn',
          backgroundColor: cardBg,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          tooltip: 'Zoom Out',
          onPressed: () {
            final z = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, z - 1);
          },
          child: const Icon(Icons.remove_rounded, size: 20),
        ),
      ],
    );
  }
}
