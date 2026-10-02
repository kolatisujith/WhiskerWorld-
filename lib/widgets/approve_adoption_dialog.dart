import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/adoption_request_details.dart';
import '../providers/adoption_provider.dart';
import '../providers/auth_provider.dart';
import '../services/email_notification_service.dart';
import 'email_preview_dialog.dart';

/// Modal dialog for Pet Owners to accept an application and configure
/// delivery/handover method, payment method, instructions, and email notification.
class ApproveAdoptionDialog extends StatefulWidget {
  final AdoptionRequestDetails details;

  const ApproveAdoptionDialog({
    super.key,
    required this.details,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AdoptionRequestDetails details,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ApproveAdoptionDialog(details: details),
    );
  }

  @override
  State<ApproveAdoptionDialog> createState() => _ApproveAdoptionDialogState();
}

class _ApproveAdoptionDialogState extends State<ApproveAdoptionDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedDeliveryMethod;
  late TextEditingController _deliveryAddressController;
  late TextEditingController _deliveryDateController;
  late TextEditingController _deliveryInstructionsController;

  late String _selectedPaymentMethod;
  late TextEditingController _paymentAmountController;
  late TextEditingController _paymentInstructionsController;

  late TextEditingController _approvalMessageController;
  bool _sendEmailNotification = true;
  bool _isSubmitting = false;

  final List<String> _deliveryMethods = [
    'In-Person Store / Shelter Pickup',
    'Direct Home Delivery by Owner',
    'Neutral Public Meetup (e.g. Vet Clinic)',
    'Safe Pet Courier / Transport Service',
  ];

  final List<String> _paymentMethods = [
    'Cash on Handover / In-Person',
    'Direct Bank Transfer / Wire',
    'UPI / Mobile Wallet (GPay, Apple Pay, Venmo)',
    'Credit / Debit Card (at Store or Online)',
    'Adoption Fee Waived / Sponsored',
  ];

  @override
  void initState() {
    super.initState();
    final pet = widget.details.pet;
    final store = widget.details.store;
    final adopter = widget.details.adopter;

    // Delivery defaults
    _selectedDeliveryMethod = _deliveryMethods[0];
    final defaultLocation = store?.address != null
        ? '${store!.name}, ${store.address}, ${store.city}'
        : (adopter?.location != null ? 'Adopter location (${adopter!.location})' : 'Whisker Haven Sanctuary, 100 Paw Lane, Portland');
    _deliveryAddressController = TextEditingController(text: defaultLocation);
    _deliveryDateController = TextEditingController(text: 'This coming Saturday at 2:00 PM');
    _deliveryInstructionsController = TextEditingController(
      text: 'Please bring an approved pet carrier or harness suitable for ${widget.details.petName}. Owner will provide complete vaccination records, adoption certificate, and a 2-week starter diet.',
    );

    // Payment defaults
    _selectedPaymentMethod = _paymentMethods[0];
    final fee = pet?.adoptionFee ?? 0.0;
    _paymentAmountController = TextEditingController(text: fee.toStringAsFixed(0));
    _paymentInstructionsController = TextEditingController(
      text: _getDefaultPaymentInstructions(_selectedPaymentMethod, fee),
    );

    // Approval message default
    _approvalMessageController = TextEditingController(
      text: 'Congratulations! Your application has been approved. We loved your answers and feel confident you will provide a loving home for ${widget.details.petName}!',
    );
  }

  String _getDefaultPaymentInstructions(String method, double fee) {
    final petName = widget.details.petName;
    final feeStr = '\$${fee.toStringAsFixed(0)}';
    switch (method) {
      case 'Cash on Handover / In-Person':
        return 'Please bring exact cash of $feeStr upon pet handover and paperwork inspection.';
      case 'Direct Bank Transfer / Wire':
        return 'Please transfer $feeStr to Account: Whisker Haven Care, Acc #: 987654321098, Routing: 021000021, Ref: "$petName Adoption". Send screenshot once transferred.';
      case 'UPI / Mobile Wallet (GPay, Apple Pay, Venmo)':
        return 'Send $feeStr via UPI / Mobile Pay to ID: owner@whiskerworld with description "$petName Adoption".';
      case 'Credit / Debit Card (at Store or Online)':
        return 'Credit / Debit card payment of $feeStr can be completed at the front desk terminal during pickup.';
      case 'Adoption Fee Waived / Sponsored':
        return 'Adoption fee is 100% sponsored by our foundation. No monetary payment required.';
      default:
        return 'Please coordinate with owner on handover.';
    }
  }

  void _onDeliveryMethodChanged(String? newMethod) {
    if (newMethod == null) return;
    setState(() {
      _selectedDeliveryMethod = newMethod;
      final store = widget.details.store;
      final adopter = widget.details.adopter;
      if (newMethod == 'Direct Home Delivery by Owner') {
        _deliveryAddressController.text = adopter?.location ?? 'Adopter Residence Address';
        _deliveryInstructionsController.text = 'Owner will safely transport ${widget.details.petName} to your address. Please ensure an adult applicant is present at the delivery location.';
      } else if (newMethod == 'Neutral Public Meetup (e.g. Vet Clinic)') {
        _deliveryAddressController.text = 'Banfield Pet Hospital / Local Veterinary Center';
        _deliveryInstructionsController.text = 'We will meet in the clinic lobby for a final veterinary check before official handover.';
      } else if (newMethod == 'Safe Pet Courier / Transport Service') {
        _deliveryAddressController.text = 'Dispatched to ${adopter?.location ?? "Applicant address"}';
        _deliveryInstructionsController.text = 'Professional air-conditioned pet transport booked. Courier tracking number will be provided via email.';
      } else {
        _deliveryAddressController.text = store?.address != null ? '${store!.name}, ${store.address}' : 'Whisker Haven Sanctuary, 100 Paw Lane';
        _deliveryInstructionsController.text = 'Please visit our store/sanctuary during business hours. Bring a secure carrier.';
      }
    });
  }

  void _onPaymentMethodChanged(String? newMethod) {
    if (newMethod == null) return;
    setState(() {
      _selectedPaymentMethod = newMethod;
      final fee = double.tryParse(_paymentAmountController.text) ?? widget.details.pet?.adoptionFee ?? 0.0;
      _paymentInstructionsController.text = _getDefaultPaymentInstructions(newMethod, fee);
    });
  }

  void _previewEmail() {
    final authProvider = context.read<AuthProvider>();
    final owner = authProvider.currentUser;
    final pet = widget.details.pet;
    final fee = double.tryParse(_paymentAmountController.text) ?? pet?.adoptionFee ?? 0.0;

    final email = EmailNotificationService.composeApprovalEmail(
      requestId: widget.details.request.id,
      senderId: owner?.id,
      senderName: owner?.name ?? 'Pet Owner / Store Manager',
      recipientId: widget.details.request.adopterId,
      recipientName: widget.details.adopterName,
      recipientEmail: widget.details.adopterEmail,
      petName: widget.details.petName,
      petBreed: widget.details.petBreed,
      petFee: fee,
      deliveryMethod: _selectedDeliveryMethod,
      deliveryAddress: _deliveryAddressController.text.trim(),
      deliveryDate: _deliveryDateController.text.trim(),
      deliveryInstructions: _deliveryInstructionsController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      paymentAmount: fee,
      paymentInstructions: _paymentInstructionsController.text.trim(),
      personalMessage: _approvalMessageController.text.trim(),
    );

    EmailPreviewDialog.show(
      context,
      details: widget.details,
      emailModel: email,
    );
  }

  Future<void> _submitApproval() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final authProvider = context.read<AuthProvider>();
    final adoptionProvider = context.read<AdoptionProvider>();
    final owner = authProvider.currentUser;

    if (owner == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final fee = double.tryParse(_paymentAmountController.text.trim()) ?? (widget.details.pet?.adoptionFee ?? 0.0);
    final deliveryMethod = _selectedDeliveryMethod;
    final deliveryAddress = _deliveryAddressController.text.trim();
    final deliveryDate = _deliveryDateController.text.trim();
    final deliveryInstructions = _deliveryInstructionsController.text.trim();
    final paymentMethod = _selectedPaymentMethod;
    final paymentInstructions = _paymentInstructionsController.text.trim();
    final approvalMsg = _approvalMessageController.text.trim();
    final recipientEmail = widget.details.adopterEmail;

    final emailNotification = _sendEmailNotification
        ? EmailNotificationService.composeApprovalEmail(
            requestId: widget.details.request.id,
            senderId: owner.id,
            senderName: owner.name,
            recipientId: widget.details.request.adopterId,
            recipientName: widget.details.adopterName,
            recipientEmail: recipientEmail,
            petName: widget.details.petName,
            petBreed: widget.details.petBreed,
            petFee: fee,
            deliveryMethod: deliveryMethod,
            deliveryAddress: deliveryAddress,
            deliveryDate: deliveryDate,
            deliveryInstructions: deliveryInstructions,
            paymentMethod: paymentMethod,
            paymentAmount: fee,
            paymentInstructions: paymentInstructions,
            personalMessage: approvalMsg,
          )
        : null;

    final success = await adoptionProvider.approveRequest(
      widget.details.request.id,
      owner.id,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress,
      deliveryDate: deliveryDate,
      deliveryInstructions: deliveryInstructions,
      paymentMethod: paymentMethod,
      paymentAmount: fee,
      paymentInstructions: paymentInstructions,
      approvalMessage: approvalMsg,
      emailSentTo: recipientEmail,
      emailNotification: emailNotification,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Application approved! Handover instructions & payment details sent to $recipientEmail.',
          ),
          backgroundColor: AppTheme.naturalSageGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      final err = adoptionProvider.errorMessage ?? 'Failed to approve application';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: const Color(0xFFD32F2F)),
      );
    }
  }

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    _deliveryDateController.dispose();
    _deliveryInstructionsController.dispose();
    _paymentAmountController.dispose();
    _paymentInstructionsController.dispose();
    _approvalMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBackground(context);
    final border = AppTheme.border(context);
    final textPrim = AppTheme.textPrimary(context);
    final textSec = AppTheme.textSecondary(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: cardBg,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                      color: AppTheme.naturalSageGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppTheme.naturalSageGreen, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Approve Application & Set Handover Details',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrim),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Applicant: ${widget.details.adopterName} • Companion: ${widget.details.petName}',
                          style: TextStyle(fontSize: 12, color: textSec),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),

            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notice banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCoral.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryCoral.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppTheme.primaryCoral, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'The delivery method and payment instructions entered here will be officially emailed to ${widget.details.adopterEmail} and displayed in their adoption portal.',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= PART 1: DELIVERY & HANDOVER =================
                      _buildSectionTitle('1. Delivery & Handover Details', Icons.local_shipping_outlined, AppTheme.primaryCoral),
                      const SizedBox(height: 12),

                      // Delivery Method Dropdown
                      _buildFieldLabel('How will the pet be delivered / collected? *'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDeliveryMethod,
                        decoration: _inputDecoration(),
                        items: _deliveryMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: _onDeliveryMethodChanged,
                      ),
                      const SizedBox(height: 14),

                      // Meetup / Delivery Address
                      _buildFieldLabel('Handover Location / Delivery Address *'),
                      TextFormField(
                        controller: _deliveryAddressController,
                        decoration: _inputDecoration(hint: 'Enter store address, meetup landmark, or delivery address'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please specify the delivery / pickup address' : null,
                      ),
                      const SizedBox(height: 14),

                      // Handover Date & Time
                      _buildFieldLabel('Scheduled Handover Date & Time *'),
                      TextFormField(
                        controller: _deliveryDateController,
                        decoration: _inputDecoration(hint: 'e.g. This Saturday, October 4th at 2:00 PM'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please specify estimated date and time' : null,
                      ),
                      const SizedBox(height: 14),

                      // Handover Instructions
                      _buildFieldLabel('Delivery & Handover Instructions for Adopter *'),
                      TextFormField(
                        controller: _deliveryInstructionsController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          hint: 'Explain what the adopter should bring (carrier, leash) and how the physical handover will occur...',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter delivery / handover instructions' : null,
                      ),
                      const SizedBox(height: 24),

                      // ================= PART 2: PAYMENT METHOD =================
                      _buildSectionTitle('2. Payment Method & Purchase Details', Icons.payments_outlined, AppTheme.naturalSageGreen),
                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Method Dropdown
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('How should the adopter pay? *'),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedPaymentMethod,
                                  decoration: _inputDecoration(),
                                  items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                                  onChanged: _onPaymentMethodChanged,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Adoption Fee Amount
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel('Adoption Fee (\$) *'),
                                TextFormField(
                                  controller: _paymentAmountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _inputDecoration(prefixText: '\$ '),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Required';
                                    if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Payment Instructions & Account details
                      _buildFieldLabel('Payment Instructions / Account Details *'),
                      TextFormField(
                        controller: _paymentInstructionsController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          hint: 'Specify cash payment on handover, bank account/IFSC/wire details, UPI ID, or card instructions...',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please specify how the adopter should pay' : null,
                      ),
                      const SizedBox(height: 24),

                      // ================= PART 3: PERSONAL NOTE & EMAIL =================
                      _buildSectionTitle('3. Personal Message & Notification', Icons.mark_email_read_outlined, AppTheme.primaryDarkCoral),
                      const SizedBox(height: 12),

                      _buildFieldLabel('Congratulations Message / Note to Adopter (optional)'),
                      TextFormField(
                        controller: _approvalMessageController,
                        maxLines: 2,
                        decoration: _inputDecoration(hint: 'Add a warm welcome or personalized tip for the new pet parent...'),
                      ),
                      const SizedBox(height: 16),

                      // Send Email Checkbox & Preview
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _sendEmailNotification,
                              activeColor: AppTheme.primaryCoral,
                              onChanged: (v) => setState(() => _sendEmailNotification = v ?? true),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Send official approval email notification',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  Text(
                                    'Will be dispatched immediately to ${widget.details.adopterEmail}',
                                    style: TextStyle(fontSize: 11, color: textSec),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _previewEmail,
                              icon: const Icon(Icons.visibility_outlined, size: 14),
                              label: const Text('Preview Email', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                side: const BorderSide(color: AppTheme.primaryCoral),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions
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
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitApproval,
                        icon: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send_rounded, size: 16),
                        label: Text(_isSubmitting ? 'Approving & Sending...' : 'Approve & Send Instructions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.naturalSageGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary(context)),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      filled: true,
      fillColor: AppTheme.isDark(context) ? AppTheme.darkSurface : AppTheme.pureWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.border(context)),
      ),
    );
  }
}
