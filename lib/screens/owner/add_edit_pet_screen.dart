import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/enums.dart';
import '../../models/pet_image_model.dart';
import '../../models/pet_model.dart';
import '../../models/pet_store_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/image_storage_service.dart';
import '../../utils/animal_utils.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Professional Add / Edit Pet Screen for Pet Owners & Caregivers
class AddEditPetScreen extends StatefulWidget {
  final String? petId;

  const AddEditPetScreen({super.key, this.petId});

  bool get isEditing => petId != null;

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageValueController;
  late TextEditingController _youngNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _personalityController;
  late TextEditingController _colorController;
  late TextEditingController _weightController;
  late TextEditingController _healthInfoController;
  late TextEditingController _vaccinationController;
  late TextEditingController _dewormingController;
  late TextEditingController _veterinaryController;
  late TextEditingController _adoptionFeeController;
  late TextEditingController _locationController;

  // Form Selections
  AnimalType _selectedAnimalType = AnimalType.dog;
  AgeUnit _selectedAgeUnit = AgeUnit.weeks;
  LifeStage _selectedLifeStage = LifeStage.baby;
  Gender _selectedGender = Gender.male;
  String? _selectedSize = 'Small';
  bool _isNeutered = false;
  PetAvailabilityStatus _availabilityStatus = PetAvailabilityStatus.available;
  String? _selectedStoreId;
  bool _listInStore = false;
  List<String> _imageUrls = [];

  bool _isLoading = false;
  bool _isInitialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _breedController = TextEditingController();
    _ageValueController = TextEditingController(text: '8');
    _youngNameController = TextEditingController(text: 'Puppy');
    _descriptionController = TextEditingController();
    _personalityController = TextEditingController(text: 'Playful, gentle, curious');
    _colorController = TextEditingController();
    _weightController = TextEditingController();
    _healthInfoController = TextEditingController();
    _vaccinationController = TextEditingController(text: 'Core vaccines up-to-date');
    _dewormingController = TextEditingController(text: 'Deworming protocol completed');
    _veterinaryController = TextEditingController(text: 'Certified Healthy by DVM');
    _adoptionFeeController = TextEditingController(text: '150');
    _locationController = TextEditingController();

    _autoCalculateLifeStageAndYoungName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      context.read<StoreProvider>().fetchMyStores(user.id);
      context.read<StoreProvider>().fetchStores();
    }
    if (widget.isEditing && !_isInitialDataLoaded) {
      _loadExistingPet();
    }
  }

  Future<void> _loadExistingPet() async {
    setState(() => _isLoading = true);
    final pet = await context.read<PetProvider>().fetchPetById(widget.petId!);
    if (pet != null && mounted) {
      _nameController.text = pet.name;
      _breedController.text = pet.breed;
      _ageValueController.text = pet.ageValue.toString();
      _youngNameController.text = pet.youngAnimalName;
      _descriptionController.text = pet.description;
      _personalityController.text = pet.personality ?? '';
      _colorController.text = pet.color ?? '';
      _weightController.text = pet.weight != null ? pet.weight.toString() : '';
      _healthInfoController.text = pet.healthInformation ?? '';
      _vaccinationController.text = pet.vaccinationStatus ?? '';
      _dewormingController.text = pet.dewormingStatus ?? '';
      _veterinaryController.text = pet.veterinaryCheck ?? '';
      _adoptionFeeController.text = pet.adoptionFee.toStringAsFixed(0);
      _locationController.text = pet.location;

      _selectedAnimalType = pet.animalType;
      _selectedAgeUnit = pet.ageUnit;
      _selectedLifeStage = pet.lifeStage;
      _selectedGender = pet.gender;
      _selectedSize = pet.size ?? 'Small';
      _isNeutered = pet.isNeutered;
      _availabilityStatus = pet.availabilityStatus;
      _selectedStoreId = pet.storeId;
      _listInStore = pet.storeId != null;
      _imageUrls = pet.images.map((img) => img.imageUrl).toList();
    }
    setState(() {
      _isLoading = false;
      _isInitialDataLoaded = true;
    });
  }

  void _autoCalculateLifeStageAndYoungName() {
    final ageVal = int.tryParse(_ageValueController.text) ?? 1;
    final derivedStage = AnimalUtils.determineLifeStage(ageVal, _selectedAgeUnit, type: _selectedAnimalType);
    final defaultYoungTerm = AnimalUtils.getYoungTerm(_selectedAnimalType.name);

    setState(() {
      _selectedLifeStage = derivedStage;
      if (!widget.isEditing || _youngNameController.text.isEmpty) {
        _youngNameController.text = defaultYoungTerm;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageValueController.dispose();
    _youngNameController.dispose();
    _descriptionController.dispose();
    _personalityController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _healthInfoController.dispose();
    _vaccinationController.dispose();
    _dewormingController.dispose();
    _veterinaryController.dispose();
    _adoptionFeeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Bar
            Container(
              width: double.infinity,
              color: AppTheme.pureWhite,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 36.0,
              ),
              child: ResponsiveContentWrapper(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/owner/pets'),
                      tooltip: 'Back to My Pets',
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEditing ? 'Edit Pet Profile' : 'Add New Young Companion',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          widget.isEditing
                              ? 'Update companion details, health information, and adoption status'
                              : 'Register a puppy, kitten, baby bunny, or companion looking for a home',
                          style: const TextStyle(color: AppTheme.charcoalLight, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderSubtle),

            // Form Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryCoral)),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 24.0 : 40.0,
                ),
                child: ResponsiveContentWrapper(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Basic Information Section
                          _buildSectionCard(
                            title: '1. Basic Information',
                            subtitle: 'Species, breed, age, and young animal terminology',
                            icon: Icons.pets_rounded,
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Pet Name *',
                                hint: 'e.g. Milo, Luna, Daisy',
                                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown<AnimalType>(
                                      label: 'Animal Type *',
                                      value: _selectedAnimalType,
                                      items: AnimalType.values.map((t) {
                                        return DropdownMenuItem(
                                          value: t,
                                          child: Text(t.name.toUpperCase()),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedAnimalType = val);
                                          _autoCalculateLifeStageAndYoungName();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _breedController,
                                      label: 'Breed *',
                                      hint: 'e.g. Golden Retriever, Ragdoll',
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Breed is required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      controller: _ageValueController,
                                      label: 'Age Number *',
                                      hint: 'e.g. 8',
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _autoCalculateLifeStageAndYoungName(),
                                      validator: (v) => int.tryParse(v ?? '') == null ? 'Valid number' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: _buildDropdown<AgeUnit>(
                                      label: 'Age Unit *',
                                      value: _selectedAgeUnit,
                                      items: AgeUnit.values.map((u) {
                                        return DropdownMenuItem(value: u, child: Text(u.name));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedAgeUnit = val);
                                          _autoCalculateLifeStageAndYoungName();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: _buildDropdown<LifeStage>(
                                      label: 'Life Stage',
                                      value: _selectedLifeStage,
                                      items: LifeStage.values.map((s) {
                                        return DropdownMenuItem(value: s, child: Text(s.name));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedLifeStage = val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _youngNameController,
                                      label: 'Young Animal Term *',
                                      hint: 'e.g. Puppy, Kitten, Kit, Chick',
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdown<Gender>(
                                      label: 'Gender *',
                                      value: _selectedGender,
                                      items: Gender.values.map((g) {
                                        return DropdownMenuItem(value: g, child: Text(g.name.toUpperCase()));
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedGender = val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 2. Details & Appearance
                          _buildSectionCard(
                            title: '2. Physical Details & Personality',
                            subtitle: 'Appearance, weight, size, and temperament',
                            icon: Icons.auto_awesome_rounded,
                            children: [
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Story & Description *',
                                hint: 'Share the companion\'s story, favorite activities, and personality...',
                                maxLines: 3,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Description required' : null,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _personalityController,
                                label: 'Personality Traits (comma-separated)',
                                hint: 'e.g. Playful, Cuddly, Curious, Friendly, Gentle',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _colorController,
                                      label: 'Color / Coat',
                                      hint: 'e.g. Golden, Seal Point, Harlequin',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdown<String>(
                                      label: 'Size Category',
                                      value: _selectedSize,
                                      items: ['Small', 'Medium', 'Large', 'Extra Large'].map((s) {
                                        return DropdownMenuItem(value: s, child: Text(s));
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedSize = val),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _weightController,
                                      label: 'Weight (kg)',
                                      hint: 'e.g. 3.5',
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 3. Health & Medical Information
                          _buildSectionCard(
                            title: '3. Health & Medical Records',
                            subtitle: 'Vaccination, deworming, and veterinary certification',
                            icon: Icons.health_and_safety_rounded,
                            children: [
                              _buildTextField(
                                controller: _veterinaryController,
                                label: 'Veterinary Check',
                                hint: 'e.g. Certified Healthy by Dr. Smith (DVM)',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _vaccinationController,
                                      label: 'Vaccination Status',
                                      hint: 'e.g. Up-to-date (2nd round complete)',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _dewormingController,
                                      label: 'Deworming Protocol',
                                      hint: 'e.g. Completed bi-weekly protocol',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _healthInfoController,
                                label: 'Special Health Notes / Diet',
                                hint: 'e.g. Eating high-protein puppy food, clear eyes and ears',
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                activeThumbColor: AppTheme.primaryCoral,
                                title: const Text('Neutered / Spayed', style: TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: const Text('Animal has undergone sterilization surgery', style: TextStyle(fontSize: 12)),
                                value: _isNeutered,
                                onChanged: (val) => setState(() => _isNeutered = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 4. Adoption & Store Affiliation
                          _buildSectionCard(
                            title: '4. Adoption Details & Store Affiliation',
                            subtitle: 'Fee, location, status, and partner store linkage',
                            icon: Icons.storefront_rounded,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _adoptionFeeController,
                                      label: 'Adoption Fee (\$) *',
                                      hint: 'e.g. 150',
                                      keyboardType: TextInputType.number,
                                      validator: (v) => double.tryParse(v ?? '') == null ? 'Valid fee' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _locationController,
                                      label: 'Location (City, State) *',
                                      hint: 'e.g. Austin, TX',
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Location required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown<PetAvailabilityStatus>(
                                label: 'Availability Status *',
                                value: _availabilityStatus,
                                items: PetAvailabilityStatus.values.map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _availabilityStatus = val);
                                },
                              ),
                              const SizedBox(height: 16),
                              // 8. Store Association
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                activeThumbColor: AppTheme.primaryCoral,
                                title: const Text('List this pet in a Pet Store', style: TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: const Text('Associate this companion with your managed store or facility storefront', style: TextStyle(fontSize: 12)),
                                value: _listInStore,
                                onChanged: (val) {
                                  setState(() {
                                    _listInStore = val;
                                    if (!val) _selectedStoreId = null;
                                  });
                                },
                              ),
                              if (_listInStore) ...[
                                const SizedBox(height: 10),
                                Builder(
                                  builder: (context) {
                                    final myStores = storeProvider.myStores;
                                    final allStores = storeProvider.stores;
                                    // Prioritize owner stores
                                    final availableOptions = myStores.isNotEmpty ? myStores : allStores;

                                    return _buildDropdown<String?>(
                                      label: 'Select Store *',
                                      value: _selectedStoreId,
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('-- Select a Store --'),
                                        ),
                                        ...availableOptions.map((PetStoreModel store) {
                                          final isOwned = store.ownerId == currentUserId;
                                          return DropdownMenuItem(
                                            value: store.id,
                                            child: Text(
                                              isOwned ? '★ ${store.name} (My Store)' : store.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }),
                                      ],
                                      onChanged: (val) => setState(() => _selectedStoreId = val),
                                    );
                                  },
                                ),
                                if (storeProvider.myStores.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('You don\'t have any stores yet. ', style: TextStyle(fontSize: 12, color: AppTheme.charcoalLight)),
                                      TextButton(
                                        onPressed: () => context.go('/owner/stores/create'),
                                        child: const Text('Create a Store', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 5. Photos & Image Presets Section
                          _buildSectionCard(
                            title: '5. Companion Photos',
                            subtitle: 'Select from verified high-quality presets or supply an image URL',
                            icon: Icons.photo_library_rounded,
                            children: [
                              // Presets Selector
                              const Text('Quick Young Pet Presets:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 90,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: ImageStorageService().getPresetsForType(_selectedAnimalType).length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                                  itemBuilder: (context, idx) {
                                    final preset = ImageStorageService().getPresetsForType(_selectedAnimalType)[idx];
                                    final isAdded = _imageUrls.contains(preset.url);

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isAdded) {
                                            _imageUrls.remove(preset.url);
                                          } else {
                                            _imageUrls.add(preset.url);
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 90,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isAdded ? AppTheme.primaryCoral : AppTheme.borderSubtle,
                                            width: isAdded ? 3.0 : 1.0,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(preset.url, fit: BoxFit.cover),
                                            if (isAdded)
                                              Container(
                                                color: AppTheme.primaryCoral.withValues(alpha: 0.35),
                                                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Custom URL Input
                              _buildCustomUrlInput(context),
                              const SizedBox(height: 16),

                              // Selected Images Gallery
                              if (_imageUrls.isNotEmpty) ...[
                                const Text('Selected Photos for Listing:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _imageUrls.map((url) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: AppTheme.borderSubtle),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.network(url, fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () => setState(() => _imageUrls.remove(url)),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 36),

                          // Submit Action Button
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go('/owner/pets'),
                                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: _savePet,
                                  icon: const Icon(Icons.check_circle_outline_rounded),
                                  label: Text(
                                    widget.isEditing ? 'Save Changes' : 'Publish Pet Listing',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const WhiskerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                  color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryDarkCoral, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight)),
                ],
              ),
            ],
          ),
          const Divider(height: 28, color: AppTheme.borderSubtle),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.warmCream,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryCoral, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.warmCream,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCustomUrlInput(BuildContext context) {
    final customUrlCtrl = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: customUrlCtrl,
            decoration: InputDecoration(
              hintText: 'Or paste external image URL (https://...)',
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: AppTheme.warmCream,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderSubtle)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            final url = customUrlCtrl.text.trim();
            if (ImageStorageService().isValidImageUrl(url)) {
              setState(() => _imageUrls.add(url));
              customUrlCtrl.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid HTTP/HTTPS or Data image URL.')),
              );
            }
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
          child: const Text('Add URL'),
        ),
      ],
    );
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final petProvider = context.read<PetProvider>();
    final currentUserId = authProvider.currentUser?.id;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in as a Pet Owner.')),
      );
      return;
    }

    // Default image fallback if none selected
    if (_imageUrls.isEmpty) {
      _imageUrls.add(ImageStorageService().getFallbackImage(_selectedAnimalType));
    }

    final now = DateTime.now();
    final petId = widget.petId ?? 'pet_${now.millisecondsSinceEpoch}';

    // Security check: Owner A cannot edit Owner B's pet
    if (widget.isEditing) {
      final existingPet = await petProvider.fetchPetById(petId);
      if (!mounted) return;
      if (existingPet != null && existingPet.ownerId != null && existingPet.ownerId != currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Security Notice: You cannot edit another owner\'s pet.')),
        );
        return;
      }
    }

    // Security check: Owner A cannot attach another owner's pet to their store
    if (_selectedStoreId != null) {
      final store = context.read<StoreProvider>().getStoreById(_selectedStoreId!);
      if (store != null && store.ownerId != null && store.ownerId != currentUserId) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Security Notice: You can only list pets in your own stores.')),
        );
        return;
      }
    }

    final petImages = _imageUrls.asMap().entries.map((entry) {
      return PetImageModel(
        id: 'img_${petId}_${entry.key}',
        petId: petId,
        imageUrl: entry.value,
        isPrimary: entry.key == 0,
        createdAt: now,
      );
    }).toList();

    final pet = PetModel(
      id: petId,
      ownerId: currentUserId,
      storeId: _selectedStoreId,
      name: _nameController.text.trim(),
      animalType: _selectedAnimalType,
      breed: _breedController.text.trim(),
      ageValue: int.tryParse(_ageValueController.text) ?? 1,
      ageUnit: _selectedAgeUnit,
      lifeStage: _selectedLifeStage,
      youngAnimalName: _youngNameController.text.trim().isNotEmpty
          ? _youngNameController.text.trim()
          : AnimalUtils.getYoungTerm(_selectedAnimalType.name),
      gender: _selectedGender,
      description: _descriptionController.text.trim(),
      personality: _personalityController.text.trim(),
      color: _colorController.text.trim(),
      size: _selectedSize,
      weight: double.tryParse(_weightController.text),
      healthInformation: _healthInfoController.text.trim(),
      vaccinationStatus: _vaccinationController.text.trim(),
      dewormingStatus: _dewormingController.text.trim(),
      veterinaryCheck: _veterinaryController.text.trim(),
      isNeutered: _isNeutered,
      adoptionFee: double.tryParse(_adoptionFeeController.text) ?? 0.0,
      location: _locationController.text.trim(),
      availabilityStatus: _availabilityStatus,
      createdAt: now,
      updatedAt: now,
      images: petImages,
    );

    final success = widget.isEditing
        ? await petProvider.updatePet(pet)
        : await petProvider.addPet(pet);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Pet updated successfully!' : 'New pet published for adoption!'),
          backgroundColor: AppTheme.naturalSageGreen,
        ),
      );
      context.go('/owner/pets');
    }
  }
}
