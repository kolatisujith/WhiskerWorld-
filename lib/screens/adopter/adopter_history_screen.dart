import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/adoption_request_details.dart';
import '../../models/enums.dart';
import '../../providers/adoption_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_storage_service.dart';
import '../../widgets/application_details_modal.dart';
import '../../widgets/email_preview_dialog.dart';
import '../../widgets/footer.dart';
import '../../widgets/navbar.dart';
import '../../widgets/responsive_layout.dart';

/// Screen displaying completed, approved, and past adoption journeys for Adopters
class AdopterHistoryScreen extends StatefulWidget {
  const AdopterHistoryScreen({super.key});

  @override
  State<AdopterHistoryScreen> createState() => _AdopterHistoryScreenState();
}

class _AdopterHistoryScreenState extends State<AdopterHistoryScreen> {
  String _historyFilter = 'all'; // all, completed, approved, rejected

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

  @override
  Widget build(BuildContext context) {
    final adoptionProvider = context.watch<AdoptionProvider>();
    final isMobile = ResponsiveLayout.isMobile(context);

    // History includes completed, approved, rejected, and cancelled requests
    final allHistory = adoptionProvider.adopterRequests.where((r) {
      return r.request.status == AdoptionRequestStatus.completed ||
          r.request.status == AdoptionRequestStatus.approved ||
          r.request.status == AdoptionRequestStatus.rejected ||
          r.request.status == AdoptionRequestStatus.cancelled;
    }).toList();

    final filteredHistory = allHistory.where((r) {
      final status = r.request.status;
      switch (_historyFilter) {
        case 'completed':
          return status == AdoptionRequestStatus.completed;
        case 'approved':
          return status == AdoptionRequestStatus.approved;
        case 'rejected':
          return status == AdoptionRequestStatus.rejected || status == AdoptionRequestStatus.cancelled;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: const WhiskerNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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
                                'Adopter Adoption History',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.naturalSageGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '📜 ${allHistory.length} Past Records',
                                  style: const TextStyle(
                                    color: AppTheme.naturalSageGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your completed adoption journeys, approved applications, and archived requests.',
                            style: TextStyle(color: AppTheme.charcoalLight, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile)
                      OutlinedButton.icon(
                        onPressed: () => context.go('/adopter/requests'),
                        icon: const Icon(Icons.assignment_outlined, size: 18),
                        label: const Text('Active Requests'),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderSubtle),

            // Main Body
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24.0 : 40.0,
              ),
              child: ResponsiveContentWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('All History (${allHistory.length})', 'all'),
                        _buildFilterChip(
                          '🎉 Completed Adoptions (${allHistory.where((r) => r.isCompleted).length})',
                          'completed',
                        ),
                        _buildFilterChip(
                          '✅ Approved (${allHistory.where((r) => r.isApproved).length})',
                          'approved',
                        ),
                        _buildFilterChip(
                          'Archived / Declined (${allHistory.where((r) => r.isRejected || r.isCancelled).length})',
                          'rejected',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (adoptionProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80.0),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryCoral)),
                      )
                    else if (filteredHistory.isEmpty)
                      _buildEmptyState(context)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(context, filteredHistory[index]);
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
    final isSelected = _historyFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => setState(() => _historyFilter = value),
      selectedColor: AppTheme.naturalSageGreen.withValues(alpha: 0.15),
      checkmarkColor: AppTheme.naturalSageGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.naturalSageGreen : AppTheme.charcoal,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      backgroundColor: AppTheme.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.naturalSageGreen : AppTheme.borderSubtle,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.naturalSageGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, size: 48, color: AppTheme.naturalSageGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Adoption History Records',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your completed adoption milestones and processed applications will be recorded here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.charcoalLight, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/pets'),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Explore Companions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AdoptionRequestDetails details) {
    final req = details.request;
    final pet = details.pet;
    final isMobile = ResponsiveLayout.isMobile(context);
    final fallbackImage = ImageStorageService().getFallbackImage(pet?.animalType ?? AnimalType.dog);
    final imageUrl = pet?.primaryImageUrl ?? fallbackImage;

    final dateStr = '${req.updatedAt.year}-${req.updatedAt.month.toString().padLeft(2, '0')}-${req.updatedAt.day.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: isMobile ? 70 : 90,
              height: isMobile ? 70 : 90,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: isMobile ? 70 : 90,
                height: isMobile ? 70 : 90,
                color: AppTheme.warmCream,
                child: const Center(child: Text('🐾', style: TextStyle(fontSize: 24))),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        details.petName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusPill(req.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${details.petYoungName} • ${details.petBreed}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.charcoalLight),
                ),
                if (details.storeName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Facility: ${details.storeName}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3F51B5)),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Last updated: $dateStr',
                  style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (pet != null)
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        onPressed: () => context.go('/pets/${pet.id}'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: const Text('Pet Profile', style: TextStyle(fontSize: 12)),
                      ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      onPressed: () => ApplicationDetailsModal.show(context, details: details),
                      icon: const Icon(Icons.description_outlined, size: 14),
                      label: const Text('Application Form', style: TextStyle(fontSize: 12)),
                    ),
                    if (details.isApproved || details.isCompleted)
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        onPressed: () => EmailPreviewDialog.show(context, details: details),
                        icon: const Icon(Icons.mark_email_read_rounded, size: 14, color: AppTheme.naturalSageGreen),
                        label: const Text('View Email', style: TextStyle(fontSize: 12, color: AppTheme.naturalSageGreen, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(AdoptionRequestStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AdoptionRequestStatus.completed:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = 'Adopted 🎉';
        break;
      case AdoptionRequestStatus.approved:
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        label = 'Approved';
        break;
      case AdoptionRequestStatus.rejected:
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        label = 'Declined';
        break;
      case AdoptionRequestStatus.cancelled:
        bg = const Color(0xFFECEFF1);
        fg = const Color(0xFF546E7A);
        label = 'Withdrawn';
        break;
      default:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        label = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
