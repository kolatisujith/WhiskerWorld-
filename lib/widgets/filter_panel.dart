import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/enums.dart';
import '../models/pet_store_model.dart';
import '../providers/pet_provider.dart';
import '../providers/store_provider.dart';
import '../repositories/database_repository.dart';

/// Comprehensive public filter panel for Find Pets screen with dynamic Light & Dark mode support
class FilterPanel extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onClose;

  const FilterPanel({
    super.key,
    this.isMobile = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final surface = AppTheme.surface(context);
    final textPrim = AppTheme.textPrimary(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 20, color: AppTheme.primaryCoral),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: textPrim,
                    ),
                  ),
                ],
              ),
              if (petProvider.hasActiveFilters)
                TextButton(
                  onPressed: () => petProvider.resetFilters(),
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: AppTheme.primaryDarkCoral,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (isMobile && onClose != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: textPrim,
                  onPressed: onClose,
                ),
            ],
          ),
          Divider(height: 24, color: border),

          // 1. Sort Order
          _buildSectionTitle(context, 'Sort By'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PetSortOrder>(
                value: petProvider.sortOrder,
                isExpanded: true,
                dropdownColor: cardBg,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPrim),
                items: PetSortOrder.values.map((order) {
                  return DropdownMenuItem(
                    value: order,
                    child: Text(
                      order.label,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrim),
                    ),
                  );
                }).toList(),
                onChanged: (order) {
                  if (order != null) petProvider.setSortOrder(order);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Animal Species / Type
          _buildSectionTitle(context, 'Animal Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFilterChip(
                context,
                label: 'All Species',
                isSelected: petProvider.selectedAnimalType == null,
                onSelected: () => petProvider.setFilters(animalType: null),
              ),
              ...[
                (AnimalType.dog, '🐶 Dogs / Pups'),
                (AnimalType.cat, '🐱 Cats / Kittens'),
                (AnimalType.rabbit, '🐰 Rabbits / Kits'),
                (AnimalType.bird, '🦜 Birds / Chicks'),
                (AnimalType.fish, '🐠 Fish / Fry'),
                (AnimalType.reptile, '🦎 Reptiles / Hatchlings'),
                (AnimalType.other, '🐹 Small Animals'),
              ].map((entry) {
                final isSelected = petProvider.selectedAnimalType == entry.$1;
                return _buildFilterChip(
                  context,
                  label: entry.$2,
                  isSelected: isSelected,
                  onSelected: () => petProvider.setFilters(
                    animalType: isSelected ? null : entry.$1,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Life Stage
          _buildSectionTitle(context, 'Life Stage'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFilterChip(
                context,
                label: 'All Stages',
                isSelected: petProvider.selectedLifeStage == null,
                onSelected: () => petProvider.setFilters(lifeStage: null),
              ),
              ...[
                (LifeStage.newborn, '🍼 Newborn (0-4 wks)'),
                (LifeStage.baby, '✨ Baby (1-3 mos)'),
                (LifeStage.young, '🌱 Young (3-12 mos)'),
                (LifeStage.adolescent, '🐕 Adolescent (1-2 yrs)'),
                (LifeStage.adult, '🐾 Adult (2-7 yrs)'),
              ].map((entry) {
                final isSelected = petProvider.selectedLifeStage == entry.$1;
                return _buildFilterChip(
                  context,
                  label: entry.$2,
                  isSelected: isSelected,
                  onSelected: () => petProvider.setFilters(
                    lifeStage: isSelected ? null : entry.$1,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Gender
          _buildSectionTitle(context, 'Gender'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  context,
                  label: 'Any',
                  isSelected: petProvider.selectedGender == null,
                  onSelected: () => petProvider.setFilters(gender: null),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildFilterChip(
                  context,
                  label: '♂ Male',
                  isSelected: petProvider.selectedGender == Gender.male,
                  onSelected: () => petProvider.setFilters(
                    gender: petProvider.selectedGender == Gender.male ? null : Gender.male,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildFilterChip(
                  context,
                  label: '♀ Female',
                  isSelected: petProvider.selectedGender == Gender.female,
                  onSelected: () => petProvider.setFilters(
                    gender: petProvider.selectedGender == Gender.female ? null : Gender.female,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Availability Status
          _buildSectionTitle(context, 'Availability'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildFilterChip(
                context,
                label: 'Available Now',
                isSelected: petProvider.selectedAvailabilityStatus == PetAvailabilityStatus.available,
                onSelected: () => petProvider.setFilters(
                  status: petProvider.selectedAvailabilityStatus == PetAvailabilityStatus.available
                      ? null
                      : PetAvailabilityStatus.available,
                ),
              ),
              _buildFilterChip(
                context,
                label: 'Pending Adoption',
                isSelected: petProvider.selectedAvailabilityStatus == PetAvailabilityStatus.pending,
                onSelected: () => petProvider.setFilters(
                  status: petProvider.selectedAvailabilityStatus == PetAvailabilityStatus.pending
                      ? null
                      : PetAvailabilityStatus.pending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 6. Max Adoption Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildSectionTitle(context, 'Max Adoption Fee')),
              const SizedBox(width: 8),
              Text(
                petProvider.maxFee != null
                    ? '₹${petProvider.maxFee!.toStringAsFixed(0)}'
                    : 'Any Fee',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppTheme.primaryDarkCoral,
                ),
              ),
            ],
          ),
          Slider(
            value: petProvider.maxFee ?? 600,
            min: 0,
            max: 600,
            divisions: 12,
            activeColor: AppTheme.primaryCoral,
            inactiveColor: surface,
            label: petProvider.maxFee != null
                ? '₹${petProvider.maxFee!.toStringAsFixed(0)}'
                : 'Any',
            onChanged: (val) {
              if (val >= 600) {
                petProvider.setFilters(maxFee: null);
              } else {
                petProvider.setFilters(maxFee: val);
              }
            },
          ),
          const SizedBox(height: 12),

          // 7. Store Association Filter
          _buildSectionTitle(context, 'Partner Pet Store'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: petProvider.selectedStoreId,
                isExpanded: true,
                dropdownColor: cardBg,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPrim),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Stores & Caregivers', style: TextStyle(fontSize: 13, color: textPrim)),
                  ),
                  ...storeProvider.stores.map((PetStoreModel s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        s.name,
                        style: TextStyle(fontSize: 13, color: textPrim),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (id) {
                  petProvider.setFilters(storeId: id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary(context),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final border = AppTheme.border(context);
    final surface = AppTheme.surface(context);
    final textPrim = AppTheme.textPrimary(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppTheme.primaryCoral.withValues(alpha: 0.15),
      backgroundColor: surface,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryCoral : border,
        width: isSelected ? 1.5 : 1.0,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryDarkCoral : textPrim,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      showCheckmark: false,
    );
  }
}
