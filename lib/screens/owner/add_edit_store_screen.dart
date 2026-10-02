import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/pet_store_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../services/image_storage_service.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Screen to create a new Pet Store or edit an existing Pet Store
class AddEditStoreScreen extends StatefulWidget {
  final String? storeId;

  const AddEditStoreScreen({super.key, this.storeId});

  bool get isEditing => storeId != null && storeId!.isNotEmpty;

  @override
  State<AddEditStoreScreen> createState() => _AddEditStoreScreenState();
}

class _AddEditStoreScreenState extends State<AddEditStoreScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'United States');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _hoursController = TextEditingController(text: 'Mon - Sat: 9:00 AM - 6:00 PM');

  String? _logoUrl;
  String? _coverImageUrl;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadStoreData());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);
    final storeProvider = context.read<StoreProvider>();
    final store = await storeProvider.fetchStoreById(widget.storeId!);

    if (store != null && mounted) {
      final currentUserId = context.read<AuthProvider>().currentUser?.id;
      // Security Check: Owner A cannot edit Owner B's store
      if (store.ownerId != null && store.ownerId != currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Security Notice: You are not authorized to edit this store.')),
        );
        context.go('/owner/stores');
        return;
      }

      setState(() {
        _nameController.text = store.name;
        _descriptionController.text = store.description ?? '';
        _addressController.text = store.address;
        _cityController.text = store.city;
        _stateController.text = store.state ?? '';
        _countryController.text = store.country;
        _phoneController.text = store.phone;
        _emailController.text = store.email;
        _websiteController.text = store.website ?? '';
        _hoursController.text = store.openingHours ?? 'Mon - Sat: 9:00 AM - 6:00 PM';
        _logoUrl = store.logoUrl;
        _coverImageUrl = store.coverImageUrl;
        _isActive = store.isActive;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreProvider>();
    final currentUserId = authProvider.currentUser?.id;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in as a Pet Owner.')),
      );
      return;
    }

    final now = DateTime.now();
    final storeId = widget.storeId ?? 'store_${now.millisecondsSinceEpoch}';

    final store = PetStoreModel(
      id: storeId,
      ownerId: currentUserId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : 'United States',
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
      logoUrl: _logoUrl,
      coverImageUrl: _coverImageUrl,
      openingHours: _hoursController.text.trim(),
      isActive: _isActive,
      createdAt: now,
      updatedAt: now,
    );

    final success = widget.isEditing
        ? await storeProvider.updateStore(store, currentUserId)
        : await storeProvider.createStore(store);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Pet store updated successfully!' : 'New pet store created!'),
          backgroundColor: AppTheme.naturalSageGreen,
        ),
      );
      context.go('/owner/stores');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    if (_isLoading) {
      return const Scaffold(
        appBar: WhiskerNavBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Bar
            Container(
              color: AppTheme.warmCream,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 36.0,
                horizontal: isMobile ? 16.0 : 32.0,
              ),
              child: ResponsiveContentWrapper(
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/owner/stores'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('My Stores'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.isEditing ? 'Edit Pet Store' : 'Create New Pet Store',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),

            // Form Area
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 40.0,
                horizontal: isMobile ? 16.0 : 32.0,
              ),
              child: ResponsiveContentWrapper(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Basic Store Details
                        _buildSectionCard(
                          title: '1. Basic Information',
                          subtitle: 'Store name, bio, and active discovery status',
                          icon: Icons.storefront_rounded,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Store / Sanctuary Name *',
                                hintText: 'e.g. Whisker Haven Nursery',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a store name' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'About Your Store / Facility *',
                                hintText: 'Describe your history, caregiver values, and mission...',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null,
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppTheme.naturalSageGreen,
                              title: const Text('Store Active for Public Discovery', style: TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: const Text('When disabled, store and its listings will be hidden from the public directory', style: TextStyle(fontSize: 12)),
                              value: _isActive,
                              onChanged: (val) => setState(() => _isActive = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 2. Visual Identity (Logo & Cover Image)
                        _buildSectionCard(
                          title: '2. Store Logo & Cover Photo',
                          subtitle: 'Choose from royalty-free presets or provide a custom image URL',
                          icon: Icons.image_outlined,
                          children: [
                            const Text('Store Cover Image:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: ImageStorageService.storeCoverPresets.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 12),
                                itemBuilder: (context, idx) {
                                  final url = ImageStorageService.storeCoverPresets[idx];
                                  final isSelected = _coverImageUrl == url;
                                  return InkWell(
                                    onTap: () => setState(() => _coverImageUrl = url),
                                    child: Container(
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryCoral : AppTheme.borderSubtle,
                                          width: isSelected ? 2.5 : 1.0,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(url, fit: BoxFit.cover),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              initialValue: _coverImageUrl,
                              onChanged: (val) => _coverImageUrl = val.trim(),
                              decoration: const InputDecoration(
                                labelText: 'Or Custom Cover Image URL',
                                hintText: 'https://images.unsplash.com/...',
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Text('Store Logo:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 64,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: ImageStorageService.storeLogoPresets.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 12),
                                itemBuilder: (context, idx) {
                                  final url = ImageStorageService.storeLogoPresets[idx];
                                  final isSelected = _logoUrl == url;
                                  return InkWell(
                                    onTap: () => setState(() => _logoUrl = url),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryCoral : AppTheme.borderSubtle,
                                          width: isSelected ? 2.5 : 1.0,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(url, fit: BoxFit.cover),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              initialValue: _logoUrl,
                              onChanged: (val) => _logoUrl = val.trim(),
                              decoration: const InputDecoration(
                                labelText: 'Or Custom Logo URL',
                                hintText: 'https://...',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 3. Location & Address
                        _buildSectionCard(
                          title: '3. Physical Location',
                          subtitle: 'Where adopters can visit your companions',
                          icon: Icons.location_on_outlined,
                          children: [
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Street Address *',
                                hintText: 'e.g. 100 Main Street',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Address required' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'City *',
                                      hintText: 'e.g. Austin',
                                    ),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'City required' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stateController,
                                    decoration: const InputDecoration(
                                      labelText: 'State / Province',
                                      hintText: 'e.g. TX',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _countryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Country *',
                                      hintText: 'United States',
                                    ),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Country required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 4. Contact & Hours
                        _buildSectionCard(
                          title: '4. Contact & Operating Hours',
                          subtitle: 'Ways for adopters to reach you and plan visits',
                          icon: Icons.access_time_rounded,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Contact Phone *',
                                      hintText: 'e.g. 512-555-0100',
                                    ),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Phone required' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Contact Email *',
                                      hintText: 'contact@haven.org',
                                    ),
                                    validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _websiteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Website (Optional)',
                                      hintText: 'https://...',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _hoursController,
                                    decoration: const InputDecoration(
                                      labelText: 'Opening Hours *',
                                      hintText: 'e.g. Mon - Sat: 9:00 AM - 6:00 PM',
                                    ),
                                    validator: (v) => v == null || v.trim().isEmpty ? 'Hours required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saveStore,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              widget.isEditing ? 'Save Store Changes' : 'Create & Publish Store',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
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
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryDarkCoral, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
