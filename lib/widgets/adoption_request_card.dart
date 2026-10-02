import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../models/adoption_request_details.dart';
import '../models/enums.dart';
import 'application_details_modal.dart';
import 'email_preview_dialog.dart';
import 'status_badge.dart';

/// Reusable Adoption Request Card for both Adopter and Owner views,
/// featuring full application questionnaire view, delivery instructions,
/// payment method details, and email notification viewing.
class AdoptionRequestCard extends StatefulWidget {
  final AdoptionRequestDetails details;
  final bool isOwnerView;
  final VoidCallback? onViewPet;
  final VoidCallback? onCancel;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const AdoptionRequestCard({
    super.key,
    required this.details,
    this.isOwnerView = false,
    this.onViewPet,
    this.onCancel,
    this.onApprove,
    this.onReject,
    this.onComplete,
  });

  @override
  State<AdoptionRequestCard> createState() => _AdoptionRequestCardState();
}

class _AdoptionRequestCardState extends State<AdoptionRequestCard> {
  bool _expanded = false;

  void _openFullApplication() {
    ApplicationDetailsModal.show(
      context,
      details: widget.details,
      onApprove: widget.isOwnerView ? widget.onApprove : null,
      onReject: widget.isOwnerView ? widget.onReject : null,
    );
  }

  void _openEmailNotification() {
    EmailPreviewDialog.show(
      context,
      details: widget.details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.details.request;
    final pet = widget.details.pet;
    final adopter = widget.details.adopter;
    final store = widget.details.store;
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final dateFormatted = DateFormat('MMM d, yyyy • h:mm a').format(req.createdAt);
    final isPending = req.status == AdoptionRequestStatus.pending;
    final isApproved = req.status == AdoptionRequestStatus.approved;
    final hasHandover = widget.details.hasHandoverDetails || isApproved;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved ? AppTheme.naturalSageGreen.withValues(alpha: 0.5) : border,
          width: isApproved ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isApproved
                ? AppTheme.naturalSageGreen.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                    child: pet?.primaryImageUrl != null
                        ? Image.network(
                            pet!.primaryImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Text('🐾', style: TextStyle(fontSize: 24)),
                            ),
                          )
                        : const Center(
                            child: Text('🐾', style: TextStyle(fontSize: 24)),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pet?.name ?? 'Companion',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: textPrim,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge.forRequest(req.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet?.breed ?? ""} • ${pet?.displayYoungName ?? "Young Pet"} • Fee: \$${widget.details.paymentAmount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 13, color: textSec, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: textSec),
                          const SizedBox(width: 5),
                          Text(
                            dateFormatted,
                            style: TextStyle(fontSize: 12, color: textSec),
                          ),
                          if (store != null) ...[
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: textSec)),
                            const SizedBox(width: 8),
                            Icon(Icons.storefront_outlined, size: 12, color: AppTheme.primaryCoral),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                store.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryCoral,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.isOwnerView && adopter != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.naturalSageGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Applicant: ${adopter.name} (${adopter.email})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.naturalSageGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // APPROVED BANNER & HANDOVER DETAILS
          if (isApproved || (hasHandover && !isPending)) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14291F) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.naturalSageGreen.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppTheme.naturalSageGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.isOwnerView ? 'Approved Handover & Payment Plan' : '🎉 Application Approved! Next Steps',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      // View Official Email Button
                      OutlinedButton.icon(
                        onPressed: _openEmailNotification,
                        icon: const Icon(Icons.email_outlined, size: 14),
                        label: Text(
                          widget.isOwnerView ? 'View Sent Email' : 'View Received Email',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : const Color(0xFF1B5E20),
                          side: BorderSide(color: AppTheme.naturalSageGreen.withValues(alpha: 0.6)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Delivery / Handover details
                  _buildInstructionCard(
                    context,
                    title: '🚚 Delivery & Handover Method',
                    subtitle: widget.details.deliveryMethod ?? 'Direct Handover / In-Person Pickup',
                    details: [
                      if (widget.details.deliveryAddress != null && widget.details.deliveryAddress!.isNotEmpty)
                        '📍 Location: ${widget.details.deliveryAddress}',
                      if (widget.details.deliveryDate != null && widget.details.deliveryDate!.isNotEmpty)
                        '📅 Schedule: ${widget.details.deliveryDate}',
                      if (widget.details.deliveryInstructions != null && widget.details.deliveryInstructions!.isNotEmpty)
                        '📝 Owner Handover Instructions: ${widget.details.deliveryInstructions}',
                    ],
                    copyText: 'Delivery: ${widget.details.deliveryMethod}\nLocation: ${widget.details.deliveryAddress}\nDate: ${widget.details.deliveryDate}\nInstructions: ${widget.details.deliveryInstructions}',
                    copyLabel: 'Copy Delivery Info',
                  ),
                  const SizedBox(height: 10),

                  // Payment method details
                  _buildInstructionCard(
                    context,
                    title: '💳 How to Buy / Payment Method',
                    subtitle: '${widget.details.paymentMethod ?? "Cash / Bank Transfer"} • Fee: \$${widget.details.paymentAmount.toStringAsFixed(2)}',
                    details: [
                      if (widget.details.paymentInstructions != null && widget.details.paymentInstructions!.isNotEmpty)
                        '💵 Instructions: ${widget.details.paymentInstructions}',
                    ],
                    copyText: 'Adoption Fee: \$${widget.details.paymentAmount.toStringAsFixed(2)}\nPayment Method: ${widget.details.paymentMethod}\nInstructions: ${widget.details.paymentInstructions}',
                    copyLabel: 'Copy Payment Info',
                  ),

                  if (widget.details.approvalMessage != null && widget.details.approvalMessage!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Owner note: "${widget.details.approvalMessage}"',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : AppTheme.charcoal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Expandable Quick Questionnaire Preview
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? AppTheme.darkSurface.withValues(alpha: 0.5)
                  : AppTheme.warmCream.withValues(alpha: 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _expanded ? 'Hide Quick Answers' : 'View Quick Questionnaire Answers',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryCoral,
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppTheme.primaryCoral,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionAnswer('Why do you want this pet?', req.reasonForAdoption ?? req.message, textPrim, textSec),
                  const SizedBox(height: 8),
                  _buildQuestionAnswer('Previous pet experience:', req.petExperience ?? 'First time pet parent', textPrim, textSec),
                  const SizedBox(height: 8),
                  _buildQuestionAnswer('Living environment:', req.livingEnvironment ?? 'Apartment / House', textPrim, textSec),
                  const SizedBox(height: 8),
                  _buildQuestionAnswer('Other pets in household:', req.otherPets ?? 'None', textPrim, textSec),
                  const SizedBox(height: 8),
                  _buildQuestionAnswer('Contact preference:', req.contactPreference ?? 'Email / Phone', textPrim, textSec),
                ],
              ),
            ),

          const Divider(height: 1),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.onViewPet != null)
                      TextButton.icon(
                        onPressed: widget.onViewPet,
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: const Text('Pet Profile', style: TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 4),
                    // Review Full Application Form button
                    TextButton.icon(
                      onPressed: _openFullApplication,
                      icon: const Icon(Icons.description_outlined, size: 15),
                      label: const Text('Full Application', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),

                // Action buttons based on view & status
                if (!widget.isOwnerView) ...[
                  if (isPending && widget.onCancel != null)
                    OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFD32F2F)),
                      label: const Text('Cancel Inquiry', style: TextStyle(fontSize: 12, color: Color(0xFFD32F2F))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF9A9A)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  if (isApproved)
                    ElevatedButton.icon(
                      onPressed: _openEmailNotification,
                      icon: const Icon(Icons.mark_email_read_rounded, size: 14),
                      label: const Text('View Email Details', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.naturalSageGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                    ),
                ] else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        if (widget.onReject != null)
                          OutlinedButton(
                            onPressed: widget.onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD32F2F),
                              side: const BorderSide(color: Color(0xFFEF9A9A)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            ),
                            child: const Text('Decline', style: TextStyle(fontSize: 12)),
                          ),
                        const SizedBox(width: 8),
                        if (widget.onApprove != null)
                          ElevatedButton.icon(
                            onPressed: widget.onApprove,
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.naturalSageGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            ),
                            label: const Text('Approve & Send', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                      if (isApproved && widget.onComplete != null)
                        ElevatedButton.icon(
                          onPressed: widget.onComplete,
                          icon: const Icon(Icons.verified_rounded, size: 14),
                          label: const Text('Finalize Adoption', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryCoral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
    );
  }

  Widget _buildInstructionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<String> details,
    required String copyText,
    required String copyLabel,
  }) {
    final isDark = AppTheme.isDark(context);
    final border = AppTheme.border(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: copyText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$copyLabel copied!'), duration: const Duration(seconds: 1)),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.copy_rounded, size: 12, color: AppTheme.primaryCoral),
                    const SizedBox(width: 4),
                    Text('Copy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryCoral)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primaryDarkCoral),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...details.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                      height: 1.3,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionAnswer(String q, String a, Color textPrim, Color textSec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSec),
        ),
        const SizedBox(height: 2),
        Text(
          a.isNotEmpty ? a : 'Not provided',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrim),
        ),
      ],
    );
  }
}
