import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../models/adoption_request_details.dart';
import '../models/email_notification_model.dart';

/// Interactive Email Notification Viewer simulating an official inbox email
class EmailPreviewDialog extends StatelessWidget {
  final AdoptionRequestDetails details;
  final EmailNotificationModel? emailModel;

  const EmailPreviewDialog({
    super.key,
    required this.details,
    this.emailModel,
  });

  static Future<void> show(
    BuildContext context, {
    required AdoptionRequestDetails details,
    EmailNotificationModel? emailModel,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EmailPreviewDialog(
        details: details,
        emailModel: emailModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = details.request;
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    final sentDate = req.emailSentAt ?? emailModel?.createdAt ?? req.updatedAt;
    final dateFormatted = DateFormat('EEE, MMM d, yyyy • h:mm a').format(sentDate);
    final recipientEmail = emailModel?.recipientEmail ?? details.adopterEmail;
    final subject = emailModel?.subject ??
        '🎉 Adoption Approved! Handover & Payment Details for ${details.petName}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: cardBg,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Column(
          children: [
            // Top App Bar / Window Chrome
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mark_email_read_rounded, color: AppTheme.primaryCoral, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Official Adoption Email Notification',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Sent to $recipientEmail',
                          style: TextStyle(fontSize: 12, color: textSec),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Email Header Meta (To, From, Subject, Timestamp)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: textPrim,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryCoral,
                        child: const Text('WW', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Whisker World Adoptions',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.naturalSageGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Verified Owner', style: TextStyle(fontSize: 10, color: AppTheme.naturalSageGreen, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'To: ${details.adopterName} <$recipientEmail>',
                              style: TextStyle(fontSize: 12, color: textSec),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        dateFormatted,
                        style: TextStyle(fontSize: 11, color: textSec),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Email Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting & Congratulation Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.naturalSageGreen.withValues(alpha: 0.15),
                            AppTheme.primaryCoral.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.naturalSageGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Application Approved for ${details.petName}!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppTheme.charcoal,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'The pet owner has approved your inquiry. Please review how to receive ${details.petName} and complete the adoption payment.',
                                  style: TextStyle(fontSize: 13, color: textSec),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Owner personal note (if provided)
                    if (details.approvalMessage != null && details.approvalMessage!.trim().isNotEmpty) ...[
                      Text('Note from Owner / Shelter:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textSec)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurface : AppTheme.warmCream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          '"${details.approvalMessage}"',
                          style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: textPrim),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Section A: Delivery & Handover Instructions
                    _buildEmailCard(
                      context,
                      title: '1. Pet Delivery & Handover Instructions',
                      icon: Icons.local_shipping_outlined,
                      accentColor: AppTheme.primaryCoral,
                      children: [
                        _buildEmailField('Handover Method:', details.deliveryMethod ?? 'Direct Handover / Pickup', textPrim, textSec),
                        const SizedBox(height: 8),
                        _buildEmailField('Meetup / Delivery Address:', details.deliveryAddress ?? (details.storeName ?? 'To be coordinated with owner'), textPrim, textSec),
                        if (details.deliveryDate != null && details.deliveryDate!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildEmailField('Scheduled Date & Time:', details.deliveryDate!, textPrim, textSec),
                        ],
                        const SizedBox(height: 8),
                        _buildEmailField(
                          'Owner Instructions on Handover:',
                          details.deliveryInstructions ?? 'Please bring an approved pet carrier and valid photo identification.',
                          textPrim,
                          textSec,
                          highlight: true,
                        ),
                      ],
                      copyText: 'Delivery: ${details.deliveryMethod}\nAddress: ${details.deliveryAddress}\nDate: ${details.deliveryDate}\nInstructions: ${details.deliveryInstructions}',
                      copyLabel: 'Copy Delivery Info',
                    ),
                    const SizedBox(height: 20),

                    // Section B: Payment Method & Details
                    _buildEmailCard(
                      context,
                      title: '2. Payment Method & Purchase Details',
                      icon: Icons.payments_outlined,
                      accentColor: AppTheme.naturalSageGreen,
                      children: [
                        _buildEmailField(
                          'Adoption Fee Amount:',
                          '\$${details.paymentAmount.toStringAsFixed(2)}',
                          textPrim,
                          textSec,
                          isAmount: true,
                        ),
                        const SizedBox(height: 8),
                        _buildEmailField('Payment Method:', details.paymentMethod ?? 'Cash on Handover / Bank Transfer', textPrim, textSec),
                        const SizedBox(height: 8),
                        _buildEmailField(
                          'Payment Instructions & Account Details:',
                          details.paymentInstructions ?? 'Please pay upon meeting the pet and inspecting medical documentation.',
                          textPrim,
                          textSec,
                          highlight: true,
                        ),
                      ],
                      copyText: 'Adoption Fee: \$${details.paymentAmount.toStringAsFixed(2)}\nPayment Method: ${details.paymentMethod}\nInstructions: ${details.paymentInstructions}',
                      copyLabel: 'Copy Payment Details',
                    ),
                    const SizedBox(height: 20),

                    // Section C: Checklist
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.checklist_rounded, size: 18, color: AppTheme.primaryCoral),
                              const SizedBox(width: 8),
                              Text('Checklist for Adoption Day', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textPrim)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildChecklistItem('Bring a pet carrier or leash suited for ${details.petName}', textSec),
                          _buildChecklistItem('Government ID matching applicant name (${details.adopterName})', textSec),
                          _buildChecklistItem('Prepare payment method (${details.paymentMethod ?? "As instructed above"})', textSec),
                          _buildChecklistItem('Owner will hand over vaccination history and adoption ownership papers', textSec),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivered via Whisker World Secure Dispatcher',
                    style: TextStyle(fontSize: 11, color: textSec),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryCoral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
    required String copyText,
    required String copyLabel,
  }) {
    final isDark = AppTheme.isDark(context);
    final border = AppTheme.border(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: copyText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$copyLabel copied to clipboard!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: Text(copyLabel, style: const TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEmailField(
    String label,
    String value,
    Color textPrim,
    Color textSec, {
    bool isAmount = false,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSec),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: highlight ? const EdgeInsets.all(10) : EdgeInsets.zero,
          decoration: highlight
              ? BoxDecoration(
                  color: AppTheme.warmCream.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 18 : 13,
              fontWeight: isAmount ? FontWeight.w900 : FontWeight.w600,
              color: isAmount ? AppTheme.naturalSageGreen : textPrim,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.naturalSageGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: textSec)),
          ),
        ],
      ),
    );
  }
}
