import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../models/pet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/pet_card.dart';
import '../../widgets/responsive_layout.dart';

/// Pet Owner "My Pets" Management Screen with Owner Isolation & Actions
class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  PetAvailabilityStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<PetProvider>().fetchMyPets(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final petProvider = context.watch<PetProvider>();
    final user = authProvider.currentUser;
    final isMobile = ResponsiveLayout.isMobile(context);

    final filteredPets = _selectedStatusFilter == null
        ? petProvider.myPets
        : petProvider.myPets.where((p) => p.availabilityStatus == _selectedStatusFilter).toList();

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              color: AppTheme.pureWhite,
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
                                'My Pets',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${petProvider.myPets.length} Listings',
                                  style: const TextStyle(
                                    color: AppTheme.primaryDarkCoral,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage listings, update photos, and adjust availability status for your pets.',
                            style: const TextStyle(color: AppTheme.charcoalLight, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/owner/pets/add'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Pet'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderSubtle),

            // Filter Pills & Content Grid
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20.0 : 32.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Status Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterPill(
                            label: 'All (${petProvider.myPets.length})',
                            isSelected: _selectedStatusFilter == null,
                            onTap: () => setState(() => _selectedStatusFilter = null),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            label:
                                'Available (${petProvider.myPets.where((p) => p.availabilityStatus == PetAvailabilityStatus.available).length})',
                            isSelected: _selectedStatusFilter == PetAvailabilityStatus.available,
                            onTap: () => setState(() => _selectedStatusFilter = PetAvailabilityStatus.available),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            label:
                                'Unavailable (${petProvider.myPets.where((p) => p.availabilityStatus == PetAvailabilityStatus.unavailable).length})',
                            isSelected: _selectedStatusFilter == PetAvailabilityStatus.unavailable,
                            onTap: () => setState(() => _selectedStatusFilter = PetAvailabilityStatus.unavailable),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            label:
                                'Pending (${petProvider.myPets.where((p) => p.availabilityStatus == PetAvailabilityStatus.pending).length})',
                            isSelected: _selectedStatusFilter == PetAvailabilityStatus.pending,
                            onTap: () => setState(() => _selectedStatusFilter = PetAvailabilityStatus.pending),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pets Content
                    if (petProvider.isMyPetsLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.0),
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryCoral),
                        ),
                      )
                    else if (filteredPets.isEmpty)
                      _buildEmptyState(context)
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
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: crossAxisCount == 1 ? 0.85 : 0.65,
                            ),
                            itemCount: filteredPets.length,
                            itemBuilder: (context, index) {
                              final PetModel pet = filteredPets[index];
                              return PetCard(
                                pet: pet,
                                showOwnerActions: true,
                                onTap: () => _showPetDetailsModal(context, pet),
                                onEdit: () => context.go('/owner/pets/${pet.id}/edit'),
                                onDelete: () => _confirmDeletePet(context, pet, user?.id ?? ''),
                                onToggleStatus: () {
                                  if (user != null) {
                                    petProvider.togglePetAvailability(
                                      pet.id,
                                      pet.availabilityStatus,
                                      user.id,
                                    );
                                  }
                                },
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

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryCoral : AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCoral : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.charcoal,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐾', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No Pets Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: const Text(
              'You haven\'t added any companions under this filter yet. Publish a new puppy, kitten, or young companion to find them a loving home.',
              style: TextStyle(color: AppTheme.charcoalLight, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/owner/pets/add'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Your First Pet'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePet(BuildContext context, PetModel pet, String ownerId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${pet.name}?'),
        content: Text(
          'Are you sure you want to remove "${pet.name}" from your active pet listings? This will permanently delete the pet profile and associated images.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await context.read<PetProvider>().deletePet(pet.id, ownerId);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pet "${pet.name}" deleted successfully.'),
                    backgroundColor: const Color(0xFFD32F2F),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Delete Listing'),
          ),
        ],
      ),
    );
  }

  void _showPetDetailsModal(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogCtx),
                      ),
                    ],
                  ),
                  Text('${pet.breed} • ${pet.displayYoungName} • ${pet.formattedAge}'),
                  const SizedBox(height: 16),
                  if (pet.primaryImageUrl != null)
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(pet.primaryImageUrl!, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 16),
                  Text(pet.description, style: const TextStyle(height: 1.5)),
                  const Divider(height: 28),
                  Text('• Adoption Fee: \$${pet.adoptionFee.toStringAsFixed(0)}'),
                  Text('• Location: ${pet.location}'),
                  Text('• Status: ${pet.availabilityStatus.name.toUpperCase()}'),
                  Text('• Vaccinations: ${pet.vaccinationStatus ?? "N/A"}'),
                  Text('• Deworming: ${pet.dewormingStatus ?? "N/A"}'),
                  Text('• Neutered: ${pet.isNeutered ? "Yes" : "No"}'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            context.go('/owner/pets/${pet.id}/edit');
                          },
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Listing'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            context.go('/pets/${pet.id}');
                          },
                          child: const Text('View Public Page'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
