import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/adoption_request_details.dart';
import '../../models/enums.dart';
import '../../providers/adoption_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adoption_request_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/footer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Screen displaying submitted adoption applications for the logged-in Pet Adopter
class AdopterRequestsScreen extends StatefulWidget {
  const AdopterRequestsScreen({super.key});

  @override
  State<AdopterRequestsScreen> createState() => _AdopterRequestsScreenState();
}

class _AdopterRequestsScreenState extends State<AdopterRequestsScreen> {
  String _selectedFilter = 'all'; // all, pending, approved, history

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AdoptionProvider>().fetchAdopterRequests(user.id);
      }
    });
  }

  Future<void> _confirmCancel(BuildContext context, AdoptionRequestDetails details) async {
    final authProvider = context.read<AuthProvider>();
    final adoptionProvider = context.read<AdoptionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Withdraw Adoption Application?',
      message: 'Are you sure you want to withdraw your adoption application for ${details.petName}? You will need to submit a new inquiry if you change your mind.',
      confirmLabel: 'Withdraw Application',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        final success = await adoptionProvider.cancelRequest(details.request.id, user.id);
        if (success && mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Application for ${details.petName} has been withdrawn.'),
              backgroundColor: AppTheme.charcoal,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adoptionProvider = context.watch<AdoptionProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);
    final cardBg = AppTheme.cardBackground(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final allRequests = adoptionProvider.adopterRequests;
    final filteredRequests = allRequests.where((req) {
      final status = req.request.status;
      switch (_selectedFilter) {
        case 'pending':
          return status == AdoptionRequestStatus.pending;
        case 'approved':
          return status == AdoptionRequestStatus.approved;
        case 'history':
          return status == AdoptionRequestStatus.completed ||
              status == AdoptionRequestStatus.rejected ||
              status == AdoptionRequestStatus.cancelled;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/adopter/requests') : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              color: cardBg,
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
                                'My Adoption Requests',
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: textPrim,
                                  letterSpacing: -0.5,
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
                                  '${allRequests.length} Total',
                                  style: const TextStyle(
                                    color: AppTheme.primaryCoral,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track the status of your adoption applications and connect with caregivers.',
                            style: TextStyle(color: textSec, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/pets'),
                        icon: const Icon(Icons.pets_rounded, size: 18),
                        label: const Text('Find Companions'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.border(context)),

            // Content Area with Filter Chips
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20.0 : 36.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Requests (${allRequests.length})', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Pending Review (${allRequests.where((r) => r.request.status == AdoptionRequestStatus.pending).length})',
                            'pending',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Approved (${allRequests.where((r) => r.request.status == AdoptionRequestStatus.approved).length})',
                            'approved',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip('Archive & History', 'history'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Requests List
                    if (adoptionProvider.isLoading)
                      const LoadingWidget(message: 'Loading your applications...')
                    else if (filteredRequests.isEmpty)
                      EmptyState.noRequests(
                        onExplore: () => context.go('/pets'),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredRequests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final details = filteredRequests[index];
                          return AdoptionRequestCard(
                            details: details,
                            isOwnerView: false,
                            onViewPet: () => context.go('/pets/${details.request.petId}'),
                            onCancel: details.request.status == AdoptionRequestStatus.pending
                                ? () => _confirmCancel(context, details)
                                : null,
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    final textPrim = AppTheme.textPrimary(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: AppTheme.primaryCoral.withValues(alpha: 0.15),
      backgroundColor: AppTheme.surface(context),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryCoral : AppTheme.border(context),
        width: isSelected ? 1.5 : 1.0,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryDarkCoral : textPrim,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      showCheckmark: false,
    );
  }
}
