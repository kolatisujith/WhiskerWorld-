import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../models/adoption_request_details.dart';
import 'status_badge.dart';

/// Modal dialog showing the complete application form filled by the adopter
class ApplicationDetailsModal extends StatelessWidget {
  final AdoptionRequestDetails details;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApplicationDetailsModal({
    super.key,
    required this.details,
    this.onApprove,
    this.onReject,
  });

  static Future<void> show(
    BuildContext context, {
    required AdoptionRequestDetails details,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ApplicationDetailsModal(
        details: details,
        onApprove: onApprove,
        onReject: onReject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = details.request;
    final pet = details.pet;
    final adopter = details.adopter;
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final dateFormatted = DateFormat('MMMM d, yyyy • h:mm a').format(req.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: cardBg,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_outlined, color: AppTheme.primaryCoral, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adoption Application Form',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrim),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Submitted on $dateFormatted',
                          style: TextStyle(fontSize: 12, color: textSec),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.forRequest(req.status),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Companion Summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: pet?.primaryImageUrl != null
                                  ? Image.network(
                                      pet!.primaryImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Center(child: Text('🐾', style: TextStyle(fontSize: 24))),
                                    )
                                  : const Center(child: Text('🐾', style: TextStyle(fontSize: 24))),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pet Applied For: ${pet?.name ?? "Young Companion"}',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textPrim),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${pet?.breed ?? "Unknown breed"} • ${pet?.displayYoungName ?? "Pet"} • Adoption Fee: \$${pet?.adoptionFee.toStringAsFixed(0) ?? "0"}',
                                  style: TextStyle(fontSize: 13, color: textSec),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1: Applicant Information
                    _buildSectionHeader('1. Applicant Contact Information', Icons.person_outline_rounded),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Full Name', adopter?.name ?? 'Not provided', Icons.badge_outlined, textPrim, textSec),
                          const Divider(height: 16),
                          _buildDetailRow('Email Address', details.adopterEmail, Icons.email_outlined, textPrim, textSec),
                          const Divider(height: 16),
                          _buildDetailRow('Phone Number', adopter?.phone ?? 'Not provided', Icons.phone_outlined, textPrim, textSec),
                          const Divider(height: 16),
                          _buildDetailRow('Location / City', adopter?.location ?? 'Not provided', Icons.location_on_outlined, textPrim, textSec),
                          const Divider(height: 16),
                          _buildDetailRow('Preferred Contact', req.contactPreference ?? 'Email', Icons.chat_bubble_outline_rounded, textPrim, textSec),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Questionnaire Responses
                    _buildSectionHeader('2. Home Environment & Experience', Icons.home_outlined),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuestionBlock(
                            'Why do you want to adopt this pet?',
                            req.reasonForAdoption ?? (req.message.isNotEmpty ? req.message : 'No reason provided'),
                            textPrim,
                            textSec,
                          ),
                          const Divider(height: 20),
                          _buildQuestionBlock(
                            'Previous pet experience:',
                            req.petExperience ?? 'First-time pet parent',
                            textPrim,
                            textSec,
                          ),
                          const Divider(height: 20),
                          _buildQuestionBlock(
                            'Living environment:',
                            req.livingEnvironment ?? 'Apartment / House',
                            textPrim,
                            textSec,
                          ),
                          const Divider(height: 20),
                          _buildQuestionBlock(
                            'Other household pets:',
                            req.otherPets ?? 'None',
                            textPrim,
                            textSec,
                          ),
                          if (req.message.isNotEmpty && req.reasonForAdoption != null) ...[
                            const Divider(height: 20),
                            _buildQuestionBlock(
                              'Additional message / questions:',
                              req.message,
                              textPrim,
                              textSec,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modal Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close Form'),
                  ),
                  if (details.isPending && (onApprove != null || onReject != null)) ...[
                    Row(
                      children: [
                        if (onReject != null)
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onReject!();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD32F2F),
                              side: const BorderSide(color: Color(0xFFEF9A9A)),
                            ),
                            child: const Text('Decline'),
                          ),
                        const SizedBox(width: 10),
                        if (onApprove != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onApprove!();
                            },
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                            label: const Text('Accept & Send Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.naturalSageGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryCoral),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color textPrim, Color textSec) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textSec),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: Text(label, style: TextStyle(fontSize: 13, color: textSec, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrim),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBlock(String question, String answer, Color textPrim, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textSec),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrim, height: 1.3),
        ),
      ],
    );
  }
}
