import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/adoption_request_model.dart';
import '../models/enums.dart';
import '../models/pet_model.dart';
import '../models/pet_store_model.dart';
import '../providers/adoption_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/store_provider.dart';
import '../services/image_storage_service.dart';
import '../widgets/footer.dart';
import '../widgets/navbar.dart';
import '../widgets/responsive_layout.dart';

/// Comprehensive Public Pet Details Profile Screen
class PetDetailsScreen extends StatefulWidget {
  final String id;

  const PetDetailsScreen({super.key, required this.id});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  int _selectedImageIndex = 0;
  bool _isLoading = true;
  PetModel? _pet;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    setState(() => _isLoading = true);
    final pet = await context.read<PetProvider>().fetchPetById(widget.id);
    if (mounted) {
      setState(() {
        _pet = pet;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();
    final favProvider = context.watch<FavoriteProvider>();

    final currentUserId = authProvider.currentUser?.id;
    final isFav = _pet != null && currentUserId != null && favProvider.isFavorite(_pet!.id);

    PetStoreModel? associatedStore;
    if (_pet?.storeId != null) {
      associatedStore = storeProvider.getStoreById(_pet!.storeId!);
    }

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Breadcrumbs Bar
            Container(
              width: double.infinity,
              color: AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: ResponsiveContentWrapper(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.go('/'),
                      child: const Text('Home', style: TextStyle(color: AppTheme.charcoalLight, fontSize: 13)),
                    ),
                    const Text('  /  ', style: TextStyle(color: AppTheme.borderSubtle)),
                    InkWell(
                      onTap: () => context.go('/pets'),
                      child: const Text('Find Pets', style: TextStyle(color: AppTheme.charcoalLight, fontSize: 13)),
                    ),
                    const Text('  /  ', style: TextStyle(color: AppTheme.borderSubtle)),
                    Text(
                      _pet?.name ?? 'Companion Details',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.charcoal),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderSubtle),

            // Main Content Area
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 120.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryCoral),
                ),
              )
            else if (_pet == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80.0),
                child: ResponsiveContentWrapper(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🐾', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text(
                          'Companion Profile Not Found',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The pet profile you are looking for may have found a home or been moved.',
                          style: TextStyle(color: AppTheme.charcoalLight),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/pets'),
                          child: const Text('Back to Find Pets'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 24.0 : 40.0,
                ),
                child: ResponsiveContentWrapper(
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Image Gallery (45%)
                            Expanded(
                              flex: 5,
                              child: _buildGallery(context, _pet!),
                            ),
                            const SizedBox(width: 48),

                            // Right: Information & Actions (55%)
                            Expanded(
                              flex: 6,
                              child: _buildDetailsPanel(
                                context,
                                _pet!,
                                associatedStore,
                                isFav,
                                currentUserId,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGallery(context, _pet!),
                            const SizedBox(height: 32),
                            _buildDetailsPanel(
                              context,
                              _pet!,
                              associatedStore,
                              isFav,
                              currentUserId,
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

  Widget _buildGallery(BuildContext context, PetModel pet) {
    final images = pet.images.isNotEmpty
        ? pet.images.map((img) => img.imageUrl).toList()
        : [ImageStorageService().getFallbackImage(pet.animalType)];

    final currentUrl = _selectedImageIndex < images.length
        ? images[_selectedImageIndex]
        : images.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Hero Image
        Container(
          height: 420,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.warmCream,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                currentUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppTheme.warmCream,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🐾', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          pet.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.charcoal.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        pet.displayYoungName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Consumer<FavoriteProvider>(
                  builder: (context, favProvider, _) {
                    final isFav = favProvider.isFavorite(pet.id);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final currentUserId = context.read<AuthProvider>().currentUser?.id;
                          if (currentUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please log in to save favorites!')),
                            );
                            return;
                          }
                          await favProvider.toggleFavorite(currentUserId, pet.id);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 22,
                            color: isFav ? const Color(0xFFE91E63) : AppTheme.charcoal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Thumbnails Strip
        if (images.length > 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedImageIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryCoral : AppTheme.borderSubtle,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(child: Text('🐾')),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    PetModel pet,
    PetStoreModel? store,
    bool isFav,
    String? currentUserId,
  ) {
    final favProvider = context.read<FavoriteProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Favorite Button Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.charcoal,
                            ),
                      ),
                      const SizedBox(width: 12),
                      _buildAvailabilityPill(pet.availabilityStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} • ${pet.displayYoungName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.charcoalLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () async {
                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to save favorites!')),
                  );
                  return;
                }
                await favProvider.toggleFavorite(currentUserId, pet.id);
              },
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFE91E63) : AppTheme.charcoal,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.warmCream,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Stats Strip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warmCream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Age', pet.formattedAge, Icons.cake_outlined),
              _buildStatItem(
                'Gender',
                pet.gender.name.toUpperCase(),
                pet.gender == Gender.female ? Icons.female_rounded : Icons.male_rounded,
              ),
              _buildStatItem('Life Stage', pet.lifeStage.name, Icons.pets_rounded),
              if (pet.weight != null)
                _buildStatItem('Weight', '${pet.weight} kg', Icons.scale_outlined),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Adoption Fee & Apply Box
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adoption Fee',
                        style: TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                      ),
                      Text(
                        pet.adoptionFee > 0
                            ? '₹${pet.adoptionFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
                            : 'Waived / Free',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDarkCoral,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.charcoalLight),
                      const SizedBox(width: 6),
                      Text(
                        pet.location.isNotEmpty ? pet.location : 'Sanctuary Location',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Apply to Adopt Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: pet.isAvailable ? () => _showAdoptDialog(context, pet) : null,
                  icon: const Icon(Icons.favorite_rounded, size: 20),
                  label: Text(
                    pet.isAvailable ? 'Apply to Adopt ${pet.name}' : 'Currently Unavailable',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.primaryCoral,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // View on Map Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/map?petId=${pet.id}'),
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('View Pet & Store on Map'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.primaryCoral),
                    foregroundColor: AppTheme.primaryCoral,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // About / Description
        const Text(
          'About This Companion',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          pet.description.isNotEmpty
              ? pet.description
              : 'A loving young companion waiting for a kind and caring forever family.',
          style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.charcoalLight),
        ),
        if (pet.personality != null && pet.personality!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pet.personality!
                .split(',')
                .map(
                  (trait) => Chip(
                    label: Text(trait.trim()),
                    backgroundColor: AppTheme.warmCream,
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 32),

        // Health & Medical Record Card
        _buildHealthSection(pet),
        const SizedBox(height: 32),

        // Store / Caregiver Profile Card
        if (store != null) ...[
          const Text(
            'Verified Pet Store & Sanctuary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Color(0xFF3F51B5), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF3F51B5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.description ?? '',
                        style: const TextStyle(fontSize: 13, color: AppTheme.charcoalLight),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📍 ${store.address}, ${store.city}, ${store.state ?? ""}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📞 ${store.phone}  •  ✉️ ${store.email}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryCoral),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.charcoalLight)),
      ],
    );
  }

  Widget _buildHealthSection(PetModel pet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.naturalSageGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.health_and_safety_outlined, color: AppTheme.naturalSageGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Health & Medical Records',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.borderSubtle),
          _buildHealthRow('Veterinary Check', pet.veterinaryCheck ?? 'Certified Healthy'),
          _buildHealthRow('Vaccinations', pet.vaccinationStatus ?? 'Core vaccines for age'),
          _buildHealthRow('Deworming Status', pet.dewormingStatus ?? 'Dewormed protocol completed'),
          _buildHealthRow('Spayed / Neutered', pet.isNeutered ? 'Yes (Sterilized)' : 'No (Too young / pending)'),
          if (pet.healthInformation != null && pet.healthInformation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${pet.healthInformation!}',
              style: const TextStyle(fontSize: 13, color: AppTheme.charcoalLight, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.charcoalLight, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityPill(PetAvailabilityStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == PetAvailabilityStatus.available
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: status == PetAvailabilityStatus.available
              ? const Color(0xFF2E7D32)
              : const Color(0xFFF57F17),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _showAdoptDialog(BuildContext context, PetModel pet) async {
    final authProvider = context.read<AuthProvider>();
    final adoptionProvider = context.read<AdoptionProvider>();

    // 1. Unauthenticated -> Prompt to login
    if (!authProvider.isAuthenticated) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Account Required'),
          content: Text('Please log in or register as a Pet Adopter to submit an adoption application for ${pet.name}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.go('/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
      return;
    }

    final user = authProvider.currentUser!;

    // 2. Role Check: Pet Owners cannot apply
    if (user.role != UserRole.petAdopter) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Adopter Account Required'),
          content: const Text(
            'Pet Owners cannot submit adoption applications.\n\n'
            'Adoption applications are reserved exclusively for registered Pet Adopters. If you wish to adopt, please sign in with a Pet Adopter account.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }

    // 3. Pet availability check
    if (!pet.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pet.name} is currently ${pet.availabilityStatus.name} and not accepting applications.'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
      return;
    }

    // 4. Duplicate application check
    final hasActive = await adoptionProvider.hasActiveRequest(user.id, pet.id);
    if (!context.mounted) return;

    if (hasActive) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Application Already Active'),
          content: Text(
            'You already have an adoption application submitted for ${pet.name} that is pending review or approved.\n\n'
            'Please check "My Adoption Requests" to track updates or communicate with the caregiver.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.go('/adopter/requests');
              },
              child: const Text('View My Requests'),
            ),
          ],
        ),
      );
      return;
    }

    // 5. Open Full Adoption Application Modal
    _openApplicationModal(context, pet, user.id);
  }

  void _openApplicationModal(BuildContext context, PetModel pet, String userId) {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();
    final messageController = TextEditingController();

    String selectedExperience = 'Experienced with cats or dogs';
    String selectedEnvironment = 'Single Family House with fenced yard';
    String selectedOtherPets = 'None';
    String selectedContactPref = 'Email';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Adopt ${pet.name} (${pet.displayYoungName})',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.warmCream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Breed: ${pet.breed} • Location: ${pet.location} • Fee: \$${pet.adoptionFee.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '📬 When you submit, the owner will receive your filled application. If approved, you will get an email with pet delivery/pickup instructions and payment details.',
                              style: TextStyle(fontSize: 11, color: AppTheme.charcoal, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Why do you want this pet?
                      const Text(
                        'Why do you want this pet? *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Share why ${pet.name} is the ideal companion for your family...',
                          filled: true,
                          fillColor: AppTheme.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter why you want this pet' : null,
                      ),
                      const SizedBox(height: 14),

                      // 2. Previous pet experience
                      const Text(
                        'Previous pet experience *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedExperience,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'First-time companion parent', child: Text('First-time companion parent')),
                          DropdownMenuItem(value: 'Experienced with cats or dogs', child: Text('Experienced with cats or dogs')),
                          DropdownMenuItem(value: 'Lifelong companion owner', child: Text('Lifelong companion owner')),
                          DropdownMenuItem(value: 'Specialized rescue care experience', child: Text('Specialized rescue care experience')),
                        ],
                        onChanged: (v) => setModalState(() => selectedExperience = v!),
                      ),
                      const SizedBox(height: 14),

                      // 3. Living environment
                      const Text(
                        'Living environment *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEnvironment,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Single Family House with fenced yard', child: Text('Single Family House with fenced yard')),
                          DropdownMenuItem(value: 'House with open / unfenced yard', child: Text('House with open / unfenced yard')),
                          DropdownMenuItem(value: 'Apartment / Condominium', child: Text('Apartment / Condominium')),
                          DropdownMenuItem(value: 'Rural Farm / Acreage', child: Text('Rural Farm / Acreage')),
                        ],
                        onChanged: (v) => setModalState(() => selectedEnvironment = v!),
                      ),
                      const SizedBox(height: 14),

                      // 4. Other pets
                      const Text(
                        'Other household pets *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedOtherPets,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'None', child: Text('No other pets')),
                          DropdownMenuItem(value: '1 or more Dogs', child: Text('1 or more Dogs')),
                          DropdownMenuItem(value: '1 or more Cats', child: Text('1 or more Cats')),
                          DropdownMenuItem(value: 'Both Dogs and Cats', child: Text('Both Dogs and Cats')),
                          DropdownMenuItem(value: 'Small Animals / Birds / Other', child: Text('Small Animals / Birds / Other')),
                        ],
                        onChanged: (v) => setModalState(() => selectedOtherPets = v!),
                      ),
                      const SizedBox(height: 14),

                      // 5. Contact preference
                      const Text(
                        'Preferred contact method *',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: selectedContactPref,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Email', child: Text('Email')),
                          DropdownMenuItem(value: 'Phone Call', child: Text('Phone Call')),
                          DropdownMenuItem(value: 'Text / SMS', child: Text('Text / SMS')),
                        ],
                        onChanged: (v) => setModalState(() => selectedContactPref = v!),
                      ),
                      const SizedBox(height: 14),

                      // 6. Additional message
                      const Text(
                        'Additional message or questions (optional)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: messageController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Questions regarding temperament, dietary habits, or vet history...',
                          filled: true,
                          fillColor: AppTheme.pureWhite,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          setModalState(() => isSubmitting = true);
                          final now = DateTime.now();
                          final request = AdoptionRequestModel(
                            id: 'req_${now.millisecondsSinceEpoch}',
                            petId: pet.id,
                            adopterId: userId,
                            ownerId: pet.ownerId,
                            storeId: pet.storeId,
                            status: AdoptionRequestStatus.pending,
                            message: messageController.text.trim(),
                            reasonForAdoption: reasonController.text.trim(),
                            petExperience: selectedExperience,
                            livingEnvironment: selectedEnvironment,
                            otherPets: selectedOtherPets,
                            contactPreference: selectedContactPref,
                            createdAt: now,
                            updatedAt: now,
                          );

                          final success = await context.read<AdoptionProvider>().submitApplication(request);
                          if (!context.mounted) return;

                          Navigator.pop(dialogCtx);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎉 Application submitted for ${pet.name}! The owner will review your form. Once accepted, you will receive an email with delivery and payment details.'),
                                backgroundColor: AppTheme.naturalSageGreen,
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: 'View Requests',
                                  textColor: Colors.white,
                                  onPressed: () => context.go('/adopter/requests'),
                                ),
                              ),
                            );
                          } else {
                            final err = context.read<AdoptionProvider>().errorMessage ?? 'Failed to submit application';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: const Color(0xFFD32F2F)),
                            );
                          }
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Application'),
              ),
            ],
          );
        },
      ),
    );
  }
}
