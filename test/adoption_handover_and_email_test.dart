import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/adoption_request_model.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/services/email_notification_service.dart';

void main() {
  sqfliteFfiInit();

  group('Adoption Handover, Payment Instructions & Email Notification Tests', () {
    late DatabaseRepositoryImpl repository;
    final now = DateTime.now();

    const ownerId = 'test_owner_1';
    const adopterId = 'test_adopter_1';
    const petId = 'test_pet_1';

    setUp(() async {
      await DatabaseService().init(inMemory: true);
      repository = DatabaseRepositoryImpl();

      // Seed Owner
      await repository.saveUser(
        UserModel(
          id: ownerId,
          name: 'Sarah Owner',
          email: 'owner@example.com',
          role: UserRole.petOwner,
          location: 'San Francisco, CA',
          createdAt: now,
        ),
      );

      // Seed Adopter
      await repository.saveUser(
        UserModel(
          id: adopterId,
          name: 'Alex Adopter',
          email: 'alex@example.com',
          phone: '+1 555-123-4567',
          role: UserRole.petAdopter,
          location: 'Oakland, CA',
          createdAt: now,
        ),
      );

      // Seed Pet
      await repository.savePet(
        PetModel(
          id: petId,
          ownerId: ownerId,
          name: 'Mochi',
          animalType: AnimalType.cat,
          breed: 'Scottish Fold',
          ageValue: 3,
          ageUnit: AgeUnit.months,
          lifeStage: LifeStage.young,
          youngAnimalName: 'Kitten',
          gender: Gender.female,
          description: 'Sweet playful kitten',
          personality: 'Cuddly, Gentle',
          adoptionFee: 150.0,
          location: 'San Francisco, CA',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        ),
      );
    });

    tearDown(() async {
      await DatabaseService().close();
    });

    test('1. Adopter submits full application form which owner receives', () async {
      final request = AdoptionRequestModel(
        id: 'req_101',
        petId: petId,
        adopterId: adopterId,
        ownerId: ownerId,
        status: AdoptionRequestStatus.pending,
        message: 'Looking forward to meeting Mochi!',
        reasonForAdoption: 'We want a loving companion for our family home.',
        petExperience: 'Experienced cat parent of 5 years',
        livingEnvironment: 'Single Family House with cat-proof patio',
        otherPets: 'None',
        contactPreference: 'Email',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveAdoptionRequest(request);

      // Owner receives application form
      final ownerRequests = await repository.getAdoptionRequestDetailsForOwner(ownerId);
      expect(ownerRequests.length, 1);

      final received = ownerRequests.first;
      expect(received.request.id, 'req_101');
      expect(received.adopterName, 'Alex Adopter');
      expect(received.adopterEmail, 'alex@example.com');
      expect(received.adopterPhone, '+1 555-123-4567');
      expect(received.request.reasonForAdoption, 'We want a loving companion for our family home.');
      expect(received.request.petExperience, 'Experienced cat parent of 5 years');
      expect(received.request.livingEnvironment, 'Single Family House with cat-proof patio');
      expect(received.isPending, isTrue);
    });

    test('2. Owner accepts request specifying Delivery Method, Payment Method & Dispatches Email', () async {
      // 1. Submit application
      final request = AdoptionRequestModel(
        id: 'req_202',
        petId: petId,
        adopterId: adopterId,
        ownerId: ownerId,
        status: AdoptionRequestStatus.pending,
        message: 'Excited to adopt!',
        reasonForAdoption: 'Adoring cat lover',
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveAdoptionRequest(request);

      // 2. Compose Approval Email with Handover & Payment Details
      const deliveryMethod = 'Direct Home Delivery by Owner';
      const deliveryAddress = '123 Market St, Oakland, CA';
      const deliveryDate = 'Saturday at 2:00 PM';
      const deliveryInstructions = 'Owner will safely bring Mochi with vaccination passport, carrier, and starter food.';
      const paymentMethod = 'Direct Bank Transfer / Wire';
      const paymentAmount = 150.0;
      const paymentInstructions = 'Please transfer \$150 to Account #987654321 with reference "Mochi Adoption".';
      const approvalMsg = 'Congratulations! We are so glad to approve your application.';

      final email = EmailNotificationService.composeApprovalEmail(
        requestId: 'req_202',
        senderId: ownerId,
        senderName: 'Sarah Owner',
        recipientId: adopterId,
        recipientName: 'Alex Adopter',
        recipientEmail: 'alex@example.com',
        petName: 'Mochi',
        petBreed: 'Scottish Fold',
        petFee: 150.0,
        deliveryMethod: deliveryMethod,
        deliveryAddress: deliveryAddress,
        deliveryDate: deliveryDate,
        deliveryInstructions: deliveryInstructions,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        paymentInstructions: paymentInstructions,
        personalMessage: approvalMsg,
      );

      expect(email.subject, contains('Mochi has been Approved!'));
      expect(email.bodyText, contains(deliveryMethod));
      expect(email.bodyText, contains(deliveryAddress));
      expect(email.bodyText, contains(paymentMethod));
      expect(email.bodyText, contains(paymentInstructions));

      // 3. Owner approves application
      await repository.approveAdoptionRequest(
        'req_202',
        deliveryMethod: deliveryMethod,
        deliveryAddress: deliveryAddress,
        deliveryDate: deliveryDate,
        deliveryInstructions: deliveryInstructions,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        paymentInstructions: paymentInstructions,
        approvalMessage: approvalMsg,
        emailSentTo: 'alex@example.com',
        emailNotification: email,
      );

      // 4. Verify request updated in database
      final updatedReq = await repository.getAdoptionRequestById('req_202');
      expect(updatedReq, isNotNull);
      expect(updatedReq!.status, AdoptionRequestStatus.approved);
      expect(updatedReq.deliveryMethod, deliveryMethod);
      expect(updatedReq.deliveryAddress, deliveryAddress);
      expect(updatedReq.deliveryDate, deliveryDate);
      expect(updatedReq.deliveryInstructions, deliveryInstructions);
      expect(updatedReq.paymentMethod, paymentMethod);
      expect(updatedReq.paymentAmount, 150.0);
      expect(updatedReq.paymentInstructions, paymentInstructions);
      expect(updatedReq.approvalMessage, approvalMsg);
      expect(updatedReq.emailSentTo, 'alex@example.com');
      expect(updatedReq.emailSentAt, isNotNull);

      // 5. Verify email notification stored for adopter
      final emails = await repository.getEmailNotificationsForUser(adopterId);
      expect(emails.length, 1);
      expect(emails.first.recipientEmail, 'alex@example.com');
      expect(emails.first.subject, contains('Mochi'));
      expect(emails.first.bodyText, contains('\$150.00'));

      // 6. Verify adopter request details contains handover metadata
      final adopterRequests = await repository.getAdoptionRequestDetailsForAdopter(adopterId);
      expect(adopterRequests.length, 1);
      final details = adopterRequests.first;
      expect(details.isApproved, isTrue);
      expect(details.hasHandoverDetails, isTrue);
      expect(details.deliveryMethod, deliveryMethod);
      expect(details.paymentMethod, paymentMethod);
      expect(details.paymentAmount, 150.0);
    });
  });
}
