import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/pet_store_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Pet Owner Store Management Dashboard Screen
class OwnerStoresScreen extends StatefulWidget {
  const OwnerStoresScreen({super.key});

  @override
  State<OwnerStoresScreen> createState() => _OwnerStoresScreenState();
}

class _OwnerStoresScreenState extends State<OwnerStoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<StoreProvider>().fetchMyStores(user.id);
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, PetStoreModel store) async {
    final authProvider = context.read<AuthProvider>();
    final storeProvider = context.read<StoreProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pet Store?'),
        content: Text(
          'Are you sure you want to permanently delete "${store.name}"?\n\nAny pets associated with this store will remain in your pet collection as independent listings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Store'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        final success = await storeProvider.deleteStore(store.id, user.id);
        if (success && mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Store deleted successfully.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final myStores = storeProvider.myStores;

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => context.go('/owner/dashboard'),
                                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                                label: const Text('Dashboard'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'My Pet Stores & Sanctuaries',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Manage your physical facilities, public storefronts, and operating schedules.',
                            style: TextStyle(color: AppTheme.charcoalLight, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/owner/stores/create'),
                      icon: const Icon(Icons.add_business_rounded, size: 18),
                      label: const Text('Create New Store'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stores Content
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 28.0 : 40.0,
                horizontal: isMobile ? 16.0 : 32.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (storeProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (myStores.isEmpty)
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
                            const Text('🏬', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            const Text(
                              'You Haven\'t Created Any Stores Yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Creating a Pet Store allows you to brand your facility and group companions under one public storefront.',
                              style: TextStyle(color: AppTheme.charcoalLight),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/owner/stores/create'),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create Store Profile'),
                            ),
                          ],
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 2;
                          if (constraints.maxWidth < 800) {
                            crossAxisCount = 1;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              childAspectRatio: crossAxisCount == 1 ? 1.4 : 1.25,
                            ),
                            itemCount: myStores.length,
                            itemBuilder: (context, index) {
                              final store = myStores[index];
                              final petCount = storeProvider.getPetCountForStore(store.id);
                              return _buildOwnerStoreCard(context, store, petCount);
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

  Widget _buildOwnerStoreCard(BuildContext context, PetStoreModel store, int petCount) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Header with Status Pill
          SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  store.displayCoverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppTheme.warmCream),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: store.isActive ? AppTheme.naturalSageGreen : const Color(0xFF757575),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      store.isActive ? 'Active Storefront' : 'Inactive / Hidden',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '🐾 $petCount Available Pets',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDarkCoral,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: store.isActive,
                            activeThumbColor: AppTheme.naturalSageGreen,
                            onChanged: (active) {
                              context.read<StoreProvider>().toggleStoreStatus(store.id, active, currentUserId);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${store.address}, ${store.fullLocation}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (store.openingHours != null && store.openingHours!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⏰ ${store.openingHours}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                        ),
                      ],
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/stores/${store.id}'),
                          icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                          label: const Text('View Store', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => context.go('/owner/stores/${store.id}/edit'),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Store',
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, store),
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFD32F2F)),
                        tooltip: 'Delete Store',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
