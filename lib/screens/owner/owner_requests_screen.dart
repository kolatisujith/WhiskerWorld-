import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/adoption_request_details.dart';
import '../../models/enums.dart';
import '../../providers/adoption_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adoption_request_card.dart';
import '../../widgets/approve_adoption_dialog.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/footer.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/mobile_navbar.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Screen for Pet Owners to review, approve, reject, and complete adoption applications
class OwnerRequestsScreen extends StatefulWidget {
  const OwnerRequestsScreen({super.key});

  @override
  State<OwnerRequestsScreen> createState() => _OwnerRequestsScreenState();
}

class _OwnerRequestsScreenState extends State<OwnerRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AdoptionProvider>().fetchOwnerRequests(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove(BuildContext context, AdoptionRequestDetails details) async {
    await ApproveAdoptionDialog.show(context, details: details);
  }

  Future<void> _handleReject(BuildContext context, AdoptionRequestDetails details) async {
    final authProvider = context.read<AuthProvider>();
    final adoptionProvider = context.read<AdoptionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Decline Adoption Application?',
      message: 'Are you sure you want to decline this inquiry from ${details.adopterName}? If no other approved applications exist, "${details.petName}" will remain Available.',
      confirmLabel: 'Decline Inquiry',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        final success = await adoptionProvider.rejectRequest(details.request.id, user.id);
        if (success && mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Application from ${details.adopterName} declined.'),
              backgroundColor: AppTheme.charcoal,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleComplete(BuildContext context, AdoptionRequestDetails details) async {
    final authProvider = context.read<AuthProvider>();
    final adoptionProvider = context.read<AdoptionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Finalize Adoption?',
      message: 'This will officially finalize the adoption of "${details.petName}" by ${details.adopterName}. '
          'The pet status will be updated to Adopted, and any other pending applications for this pet will be automatically closed.',
      confirmLabel: 'Finalize & Close',
      confirmColor: AppTheme.primaryCoral,
      icon: Icons.verified_rounded,
    );

    if (confirmed == true && mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        final success = await adoptionProvider.completeRequest(details.request.id, user.id);
        if (success && mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Congratulations! ${details.petName} has been officially adopted!'),
              backgroundColor: AppTheme.naturalSageGreen,
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

    final allRequests = adoptionProvider.ownerRequests;
    final pendingRequests = allRequests.where((r) => r.request.status == AdoptionRequestStatus.pending).toList();
    final approvedRequests = allRequests.where((r) => r.request.status == AdoptionRequestStatus.approved).toList();
    final historyRequests = allRequests
        .where((r) =>
            r.request.status == AdoptionRequestStatus.completed ||
            r.request.status == AdoptionRequestStatus.rejected ||
            r.request.status == AdoptionRequestStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: const WhiskerNavBar(),
      drawer: isMobile ? const MobileNavDrawer() : null,
      bottomNavigationBar: isMobile ? const MobileBottomNavBar(currentRoute: '/owner/requests') : null,
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
                                'Adoption Inquiries',
                                style: TextStyle(
                                  fontSize: isMobile ? 22 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: textPrim,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (pendingRequests.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryCoral.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${pendingRequests.length} Pending Review',
                                    style: const TextStyle(
                                      color: AppTheme.primaryDarkCoral,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Review applicant questionnaires, approve qualified pet parents, and finalize adoptions.',
                            style: TextStyle(color: textSec, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: AppTheme.border(context)),

            // Tab Bar
            Container(
              color: AppTheme.surface(context),
              child: ResponsiveContentWrapper(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryCoral,
                  labelColor: AppTheme.primaryCoral,
                  unselectedLabelColor: textSec,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pending Inquiries'),
                          if (pendingRequests.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryCoral,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${pendingRequests.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Approved In Progress'),
                          if (approvedRequests.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.naturalSageGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${approvedRequests.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(text: 'Adoption History (${historyRequests.length})'),
                  ],
                ),
              ),
            ),

            // Tab View Content
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 20.0 : 36.0,
              ),
              child: ResponsiveContentWrapper(
                child: SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Pending
                      _buildRequestsList(pendingRequests, adoptionProvider.isLoading, isPendingTab: true),

                      // Tab 2: Approved
                      _buildRequestsList(approvedRequests, adoptionProvider.isLoading, isApprovedTab: true),

                      // Tab 3: History
                      _buildRequestsList(historyRequests, adoptionProvider.isLoading, isHistoryTab: true),
                    ],
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

  Widget _buildRequestsList(
    List<AdoptionRequestDetails> list,
    bool isLoading, {
    bool isPendingTab = false,
    bool isApprovedTab = false,
    bool isHistoryTab = false,
  }) {
    if (isLoading) {
      return const LoadingWidget(message: 'Loading requests...');
    }

    if (list.isEmpty) {
      return EmptyState.noRequests(
        isOwner: true,
        onExplore: () => context.go('/owner/pets'),
      );
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final details = list[index];
        return AdoptionRequestCard(
          details: details,
          isOwnerView: true,
          onViewPet: () => context.go('/pets/${details.request.petId}'),
          onApprove: isPendingTab ? () => _handleApprove(context, details) : null,
          onReject: isPendingTab ? () => _handleReject(context, details) : null,
          onComplete: isApprovedTab ? () => _handleComplete(context, details) : null,
        );
      },
    );
  }
}
