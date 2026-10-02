/// Email notification sent to adopters upon adoption approval
class EmailNotificationModel {
  final String id;
  final String requestId;
  final String? senderId;
  final String recipientId;
  final String recipientEmail;
  final String subject;
  final String bodyText;
  final String? deliveryDetails;
  final String? paymentDetails;
  final DateTime createdAt;
  final bool isRead;

  const EmailNotificationModel({
    required this.id,
    required this.requestId,
    this.senderId,
    required this.recipientId,
    required this.recipientEmail,
    required this.subject,
    required this.bodyText,
    this.deliveryDetails,
    this.paymentDetails,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'request_id': requestId,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'recipient_email': recipientEmail,
      'subject': subject,
      'body_text': bodyText,
      'delivery_details': deliveryDetails,
      'payment_details': paymentDetails,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory EmailNotificationModel.fromMap(Map<String, dynamic> map) {
    return EmailNotificationModel(
      id: map['id'] as String,
      requestId: map['request_id'] as String,
      senderId: map['sender_id'] as String?,
      recipientId: map['recipient_id'] as String,
      recipientEmail: map['recipient_email'] as String,
      subject: map['subject'] as String,
      bodyText: map['body_text'] as String,
      deliveryDetails: map['delivery_details'] as String?,
      paymentDetails: map['payment_details'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: (map['is_read'] as int? ?? 0) == 1,
    );
  }

  EmailNotificationModel copyWith({
    String? id,
    String? requestId,
    String? senderId,
    String? recipientId,
    String? recipientEmail,
    String? subject,
    String? bodyText,
    String? deliveryDetails,
    String? paymentDetails,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return EmailNotificationModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      subject: subject ?? this.subject,
      bodyText: bodyText ?? this.bodyText,
      deliveryDetails: deliveryDetails ?? this.deliveryDetails,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
