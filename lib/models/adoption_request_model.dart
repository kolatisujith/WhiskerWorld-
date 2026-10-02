import 'enums.dart';

/// Whisker World Adoption Request Model with Application, Delivery, and Payment Details
class AdoptionRequestModel {
  final String id;
  final String petId;
  final String adopterId;
  final String? ownerId;
  final String? storeId;
  final AdoptionRequestStatus status;
  final String message;
  final String? reasonForAdoption;
  final String? petExperience;
  final String? livingEnvironment;
  final String? otherPets;
  final String? contactPreference;

  // Approved Handover & Payment Details
  final String? deliveryMethod;
  final String? deliveryAddress;
  final String? deliveryDate;
  final String? deliveryInstructions;
  final String? paymentMethod;
  final double? paymentAmount;
  final String? paymentInstructions;
  final String? approvalMessage;
  final String? emailSentTo;
  final DateTime? emailSentAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  const AdoptionRequestModel({
    required this.id,
    required this.petId,
    required this.adopterId,
    this.ownerId,
    this.storeId,
    required this.status,
    required this.message,
    this.reasonForAdoption,
    this.petExperience,
    this.livingEnvironment,
    this.otherPets,
    this.contactPreference,
    this.deliveryMethod,
    this.deliveryAddress,
    this.deliveryDate,
    this.deliveryInstructions,
    this.paymentMethod,
    this.paymentAmount,
    this.paymentInstructions,
    this.approvalMessage,
    this.emailSentTo,
    this.emailSentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'adopter_id': adopterId,
      'owner_id': ownerId,
      'store_id': storeId,
      'status': status.name,
      'message': message,
      'reason_for_adoption': reasonForAdoption,
      'pet_experience': petExperience,
      'living_environment': livingEnvironment,
      'other_pets': otherPets,
      'contact_preference': contactPreference,
      'delivery_method': deliveryMethod,
      'delivery_address': deliveryAddress,
      'delivery_date': deliveryDate,
      'delivery_instructions': deliveryInstructions,
      'payment_method': paymentMethod,
      'payment_amount': paymentAmount,
      'payment_instructions': paymentInstructions,
      'approval_message': approvalMessage,
      'email_sent_to': emailSentTo,
      'email_sent_at': emailSentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AdoptionRequestModel.fromMap(Map<String, dynamic> map) {
    return AdoptionRequestModel(
      id: map['id'] as String,
      petId: map['pet_id'] as String,
      adopterId: map['adopter_id'] as String,
      ownerId: map['owner_id'] as String?,
      storeId: map['store_id'] as String?,
      status: AdoptionRequestStatus.fromString(map['status'] as String? ?? 'pending'),
      message: map['message'] as String? ?? '',
      reasonForAdoption: map['reason_for_adoption'] as String?,
      petExperience: map['pet_experience'] as String?,
      livingEnvironment: map['living_environment'] as String?,
      otherPets: map['other_pets'] as String?,
      contactPreference: map['contact_preference'] as String?,
      deliveryMethod: map['delivery_method'] as String?,
      deliveryAddress: map['delivery_address'] as String?,
      deliveryDate: map['delivery_date'] as String?,
      deliveryInstructions: map['delivery_instructions'] as String?,
      paymentMethod: map['payment_method'] as String?,
      paymentAmount: (map['payment_amount'] as num?)?.toDouble(),
      paymentInstructions: map['payment_instructions'] as String?,
      approvalMessage: map['approval_message'] as String?,
      emailSentTo: map['email_sent_to'] as String?,
      emailSentAt: map['email_sent_at'] != null ? DateTime.tryParse(map['email_sent_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  AdoptionRequestModel copyWith({
    String? id,
    String? petId,
    String? adopterId,
    String? ownerId,
    String? storeId,
    AdoptionRequestStatus? status,
    String? message,
    String? reasonForAdoption,
    String? petExperience,
    String? livingEnvironment,
    String? otherPets,
    String? contactPreference,
    String? deliveryMethod,
    String? deliveryAddress,
    String? deliveryDate,
    String? deliveryInstructions,
    String? paymentMethod,
    double? paymentAmount,
    String? paymentInstructions,
    String? approvalMessage,
    String? emailSentTo,
    DateTime? emailSentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdoptionRequestModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      adopterId: adopterId ?? this.adopterId,
      ownerId: ownerId ?? this.ownerId,
      storeId: storeId ?? this.storeId,
      status: status ?? this.status,
      message: message ?? this.message,
      reasonForAdoption: reasonForAdoption ?? this.reasonForAdoption,
      petExperience: petExperience ?? this.petExperience,
      livingEnvironment: livingEnvironment ?? this.livingEnvironment,
      otherPets: otherPets ?? this.otherPets,
      contactPreference: contactPreference ?? this.contactPreference,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      approvalMessage: approvalMessage ?? this.approvalMessage,
      emailSentTo: emailSentTo ?? this.emailSentTo,
      emailSentAt: emailSentAt ?? this.emailSentAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdoptionRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AdoptionRequestModel(id: $id, petId: $petId, adopterId: $adopterId, status: $status, deliveryMethod: $deliveryMethod, paymentMethod: $paymentMethod)';
}
