import 'adoption_request_model.dart';
import 'pet_model.dart';
import 'pet_store_model.dart';
import 'user_model.dart';

/// Enriched Adoption Request with joined Pet, Adopter, and Store metadata
class AdoptionRequestDetails {
  final AdoptionRequestModel request;
  final PetModel? pet;
  final UserModel? adopter;
  final PetStoreModel? store;

  const AdoptionRequestDetails({
    required this.request,
    this.pet,
    this.adopter,
    this.store,
  });

  String get petName => pet?.name ?? 'Young Companion';
  String get petBreed => pet?.breed ?? '';
  String get petYoungName => pet?.displayYoungName ?? 'Pet';
  String? get petImageUrl => pet?.primaryImageUrl;
  String get adopterName => adopter?.name ?? 'Applicant';
  String get adopterEmail => adopter?.email ?? (request.emailSentTo ?? '');
  String get adopterPhone => adopter?.phone ?? '';
  String? get storeName => store?.name;

  bool get isPending => request.status.name == 'pending';
  bool get isApproved => request.status.name == 'approved';
  bool get isRejected => request.status.name == 'rejected';
  bool get isCancelled => request.status.name == 'cancelled';
  bool get isCompleted => request.status.name == 'completed';

  // Handover & Payment Getters
  String? get deliveryMethod => request.deliveryMethod;
  String? get deliveryAddress => request.deliveryAddress;
  String? get deliveryDate => request.deliveryDate;
  String? get deliveryInstructions => request.deliveryInstructions;

  String? get paymentMethod => request.paymentMethod;
  double get paymentAmount => request.paymentAmount ?? (pet?.adoptionFee ?? 0.0);
  String? get paymentInstructions => request.paymentInstructions;
  String? get approvalMessage => request.approvalMessage;
  String? get emailSentTo => request.emailSentTo ?? adopter?.email;
  DateTime? get emailSentAt => request.emailSentAt;

  bool get hasHandoverDetails =>
      (request.deliveryMethod != null && request.deliveryMethod!.isNotEmpty) ||
      (request.paymentMethod != null && request.paymentMethod!.isNotEmpty);
}
