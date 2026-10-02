import 'package:intl/intl.dart';
import '../models/email_notification_model.dart';

/// Service responsible for composing and formatting adoption notification emails
class EmailNotificationService {
  EmailNotificationService._();

  /// Composes a formal adoption approval email notification
  static EmailNotificationModel composeApprovalEmail({
    required String requestId,
    required String? senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String recipientEmail,
    required String petName,
    required String petBreed,
    required double petFee,
    required String deliveryMethod,
    required String deliveryAddress,
    String? deliveryDate,
    required String deliveryInstructions,
    required String paymentMethod,
    required double paymentAmount,
    required String paymentInstructions,
    String? personalMessage,
  }) {
    final now = DateTime.now();
    final formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(now);
    final subject = '🎉 Congratulations! Your Adoption Request for $petName has been Approved!';

    final buffer = StringBuffer();
    buffer.writeln('Dear $recipientName,');
    buffer.writeln();
    buffer.writeln('Great news! We are thrilled to inform you that your adoption application for $petName ($petBreed) has been officially reviewed and APPROVED by $senderName!');
    buffer.writeln();

    if (personalMessage != null && personalMessage.trim().isNotEmpty) {
      buffer.writeln('--- Message from Owner ---');
      buffer.writeln('"$personalMessage"');
      buffer.writeln();
    }

    buffer.writeln('========================================');
    buffer.writeln('🚚 PET DELIVERY & HANDOVER INSTRUCTIONS');
    buffer.writeln('========================================');
    buffer.writeln('• Delivery Method: $deliveryMethod');
    buffer.writeln('• Handover Location: $deliveryAddress');
    if (deliveryDate != null && deliveryDate.trim().isNotEmpty) {
      buffer.writeln('• Scheduled Date & Time: $deliveryDate');
    }
    buffer.writeln('• Handover Instructions:');
    buffer.writeln('  $deliveryInstructions');
    buffer.writeln();

    buffer.writeln('========================================');
    buffer.writeln('💳 PAYMENT METHOD & ADOPTION FEE DETAILS');
    buffer.writeln('========================================');
    buffer.writeln('• Total Adoption Fee: \$${paymentAmount.toStringAsFixed(2)}');
    buffer.writeln('• Payment Method: $paymentMethod');
    buffer.writeln('• Payment Instructions:');
    buffer.writeln('  $paymentInstructions');
    buffer.writeln();

    buffer.writeln('========================================');
    buffer.writeln('📋 WHAT TO BRING ON HANDOVER DAY');
    buffer.writeln('========================================');
    buffer.writeln('1. A secure animal carrier or harness & leash suitable for $petName.');
    buffer.writeln('2. A valid government-issued photo ID.');
    buffer.writeln('3. Payment confirmation or cash (based on the payment method above).');
    buffer.writeln();
    buffer.writeln('If you have any questions before pickup or delivery, please reach out through the Whisker World portal.');
    buffer.writeln();
    buffer.writeln('Warmest congratulations,');
    buffer.writeln('$senderName & The Whisker World Team');
    buffer.writeln('Sent on: $formattedDate');

    final deliverySummary = '$deliveryMethod at $deliveryAddress${deliveryDate != null ? ' ($deliveryDate)' : ''}. $deliveryInstructions';
    final paymentSummary = '$paymentMethod: \$${paymentAmount.toStringAsFixed(2)}. $paymentInstructions';

    return EmailNotificationModel(
      id: 'email_${now.millisecondsSinceEpoch}',
      requestId: requestId,
      senderId: senderId,
      recipientId: recipientId,
      recipientEmail: recipientEmail,
      subject: subject,
      bodyText: buffer.toString(),
      deliveryDetails: deliverySummary,
      paymentDetails: paymentSummary,
      createdAt: now,
      isRead: false,
    );
  }
}
