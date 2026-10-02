import '../models/enums.dart';
import '../models/pet_image_model.dart';
import '../models/pet_model.dart';
import '../models/pet_store_model.dart';
import '../models/user_model.dart';
import '../repositories/database_repository.dart';
import '../utils/password_hasher.dart';

/// DatabaseSeeder provides default demo accounts, stores, and young pets
/// for development, automated acceptance testing, and public demonstration.
class DatabaseSeeder {
  DatabaseSeeder._();

  static const String demoOwnerId = 'demo-owner-100';
  static const String demoOwnerEmail = 'owner@example.com';
  static const String demoOwnerPassword = 'Owner@123';

  static const String demoAdopterId = 'demo-adopter-200';
  static const String demoAdopterEmail = 'adopter@example.com';
  static const String demoAdopterPassword = 'Adopter@123';

  static const String whiskerHavenStoreId = 'store-whisker-haven';
  static const String happyPawsStoreId = 'store-happy-paws';

  /// Seeds default data if demo accounts or pets do not exist yet.
  static Future<void> seedIfEmpty(DatabaseRepository repository) async {
    // Check if demo owner already exists
    final existingOwner = await repository.getUserByEmail(demoOwnerEmail);
    if (existingOwner != null) {
      return; // Database already seeded
    }

    final now = DateTime.now();

    // 1. Seed Demo Accounts
    final demoOwner = UserModel(
      id: demoOwnerId,
      name: 'Eleanor Vance (Demo Owner)',
      email: demoOwnerEmail,
      passwordHash: PasswordHasher.hashPassword(demoOwnerPassword),
      phone: '+1 (555) 234-5678',
      role: UserRole.petOwner,
      location: 'Portland, OR',
      latitude: 45.5152,
      longitude: -122.6784,
      bio: 'Lifelong animal rescue director and founder of Whisker Haven Sanctuary.',
      profileImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveUser(demoOwner);

    final demoAdopter = UserModel(
      id: demoAdopterId,
      name: 'Liam Gallagher (Demo Adopter)',
      email: demoAdopterEmail,
      passwordHash: PasswordHasher.hashPassword(demoAdopterPassword),
      phone: '+1 (555) 876-5432',
      role: UserRole.petAdopter,
      location: 'Seattle, WA',
      latitude: 47.6062,
      longitude: -122.3321,
      bio: 'Remote software engineer looking to adopt and love a playful companion.',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveUser(demoAdopter);

    // 2. Seed Store A: Whisker Haven
    final whiskerHaven = PetStoreModel(
      id: whiskerHavenStoreId,
      ownerId: demoOwnerId,
      name: 'Whisker Haven',
      description: 'A boutique young animal nursery offering vaccinated, healthy puppies and kittens ready for adoption.',
      address: '100 Paw Lane',
      city: 'Portland',
      state: 'OR',
      country: 'USA',
      phone: '503-555-0101',
      email: demoOwnerEmail,
      website: 'https://whiskerhaven.example.com',
      logoUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=150',
      coverImageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800',
      openingHours: 'Mon-Sat 9:00 AM - 6:00 PM',
      latitude: 45.5231,
      longitude: -122.6865,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await repository.savePetStore(whiskerHaven);

    // 3. Seed Store B: Happy Paws
    final happyPaws = PetStoreModel(
      id: happyPawsStoreId,
      ownerId: demoOwnerId,
      name: 'Happy Paws',
      description: 'Premier sanctuary and care center specializing in gentle, socialized companion pets.',
      address: '200 Bark Ave',
      city: 'Seattle',
      state: 'WA',
      country: 'USA',
      phone: '206-555-0202',
      email: 'happypaws@example.com',
      website: 'https://happypaws.example.com',
      logoUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=150',
      coverImageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800',
      openingHours: 'Tue-Sun 10:00 AM - 7:00 PM',
      latitude: 47.6101,
      longitude: -122.3421,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    await repository.savePetStore(happyPaws);

    // 4. Seed Whisker Haven Pets: Bruno, Luna, Milo
    final bruno = PetModel(
      id: 'pet-bruno',
      ownerId: demoOwnerId,
      storeId: whiskerHavenStoreId,
      name: 'Bruno',
      animalType: AnimalType.dog,
      breed: 'Golden Retriever',
      ageValue: 3,
      ageUnit: AgeUnit.months,
      lifeStage: LifeStage.baby,
      youngAnimalName: 'Puppy',
      gender: Gender.male,
      description: 'Cheerful Golden Retriever puppy who loves playing fetch and giving warm hugs.',
      personality: 'Playful, Affectionate, Energetic',
      color: 'Golden',
      size: 'Medium',
      weight: 5.5,
      healthInformation: 'De-wormed, microchipped, fully checked by licensed vet.',
      vaccinationStatus: 'Vaccinated (DHPP)',
      dewormingStatus: 'Up-to-date',
      veterinaryCheck: 'Passed full wellness exam',
      isNeutered: false,
      adoptionFee: 250.0,
      location: 'Portland, OR',
      latitude: 45.5240,
      longitude: -122.6850,
      availabilityStatus: PetAvailabilityStatus.available,
      images: [
        PetImageModel(
          id: 'img-bruno',
          petId: 'pet-bruno',
          imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=600',
          isPrimary: true,
          createdAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final luna = PetModel(
      id: 'pet-luna',
      ownerId: demoOwnerId,
      storeId: whiskerHavenStoreId,
      name: 'Luna',
      animalType: AnimalType.cat,
      breed: 'Siamese',
      ageValue: 8,
      ageUnit: AgeUnit.weeks,
      lifeStage: LifeStage.baby,
      youngAnimalName: 'Kitten',
      gender: Gender.female,
      description: 'Sweet purring blue-eyed Siamese kitten with soft paws and endless curiosity.',
      personality: 'Curious, Gentle, Loving',
      color: 'Cream & Seal Point',
      size: 'Small',
      weight: 1.1,
      healthInformation: 'First round feline distemper shots administered.',
      vaccinationStatus: 'FVRCP Initial Dose',
      dewormingStatus: 'Up-to-date',
      veterinaryCheck: 'Healthy and clear vitals',
      isNeutered: false,
      adoptionFee: 150.0,
      location: 'Portland, OR',
      latitude: 45.5225,
      longitude: -122.6875,
      availabilityStatus: PetAvailabilityStatus.available,
      images: [
        PetImageModel(
          id: 'img-luna',
          petId: 'pet-luna',
          imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600',
          isPrimary: true,
          createdAt: now,
        ),
      ],
      createdAt: now.add(const Duration(minutes: 1)),
      updatedAt: now.add(const Duration(minutes: 1)),
    );

    final milo = PetModel(
      id: 'pet-milo',
      ownerId: demoOwnerId,
      storeId: whiskerHavenStoreId,
      name: 'Milo',
      animalType: AnimalType.dog,
      breed: 'Beagle',
      ageValue: 4,
      ageUnit: AgeUnit.months,
      lifeStage: LifeStage.young,
      youngAnimalName: 'Puppy',
      gender: Gender.male,
      description: 'Curious Beagle pup with an inquisitive nose and friendly temperament.',
      personality: 'Friendly, Active, Alert',
      color: 'Tri-color',
      size: 'Medium',
      weight: 4.8,
      healthInformation: 'Regular vet checks, rabies and puppy booster shots up to date.',
      vaccinationStatus: 'Vaccinated',
      dewormingStatus: 'Up-to-date',
      veterinaryCheck: 'Passed checkup',
      isNeutered: false,
      adoptionFee: 200.0,
      location: 'Portland, OR',
      latitude: 45.5238,
      longitude: -122.6880,
      availabilityStatus: PetAvailabilityStatus.available,
      images: [
        PetImageModel(
          id: 'img-milo',
          petId: 'pet-milo',
          imageUrl: 'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=600',
          isPrimary: true,
          createdAt: now,
        ),
      ],
      createdAt: now.add(const Duration(minutes: 2)),
      updatedAt: now.add(const Duration(minutes: 2)),
    );

    // 5. Seed Happy Paws Pets: Simba, Coco, Rocky
    final simba = PetModel(
      id: 'pet-simba',
      ownerId: demoOwnerId,
      storeId: happyPawsStoreId,
      name: 'Simba',
      animalType: AnimalType.cat,
      breed: 'Bengal',
      ageValue: 3,
      ageUnit: AgeUnit.months,
      lifeStage: LifeStage.baby,
      youngAnimalName: 'Kitten',
      gender: Gender.male,
      description: 'Little king Simba with dazzling rosetted spots and an acrobatic spirit.',
      personality: 'Adventurous, Bold, Playful',
      color: 'Spotted Brown Tabby',
      size: 'Small',
      weight: 1.6,
      healthInformation: 'Parasite free, negative for FIV/FeLV.',
      vaccinationStatus: 'Vaccinated',
      dewormingStatus: 'Up-to-date',
      veterinaryCheck: 'Certified healthy',
      isNeutered: false,
      adoptionFee: 300.0,
      location: 'Seattle, WA',
      latitude: 47.6095,
      longitude: -122.3410,
      availabilityStatus: PetAvailabilityStatus.available,
      images: [
        PetImageModel(
          id: 'img-simba',
          petId: 'pet-simba',
          imageUrl: 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=600',
          isPrimary: true,
          createdAt: now,
        ),
      ],
      createdAt: now.add(const Duration(minutes: 3)),
      updatedAt: now.add(const Duration(minutes: 3)),
    );

    final coco = PetModel(
      id: 'pet-coco',
      ownerId: demoOwnerId,
      storeId: happyPawsStoreId,
      name: 'Coco',
      animalType: AnimalType.rabbit,
      breed: 'Mini Lop',
      ageValue: 8,
      ageUnit: AgeUnit.weeks,
      lifeStage: LifeStage.baby,
      youngAnimalName: 'Kit',
      gender: Gender.female,
      description: 'Soft floppy-eared bunny kit who enjoys snacking on fresh greens and gentle head pats.',
      personality: 'Calm, Sweet, Gentle',
      color: 'Chocolate Brown',
      size: 'Small',
      weight: 0.9,
      healthInformation: 'Vaccinated for RHDV2, vet examined.',
      vaccinationStatus: 'RHDV2 Vaccinated',
      dewormingStatus: 'Preventive treatment done',
      veterinaryCheck: 'Excellent condition',
      isNeutered: false,
      adoptionFee: 80.0,
      location: 'Seattle, WA',
      latitude: 47.6110,
      longitude: -122.3435,
      availabilityStatus: PetAvailabilityStatus.available,
      images: [
        PetImageModel(
          id: 'img-coco',
          petId: 'pet-coco',
          imageUrl: 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=600',
          isPrimary: true,
          createdAt: now,
        ),
      ],
      createdAt: now.add(const Duration(minutes: 4)),
      updatedAt: now.add(const Duration(minutes: 4)),
    );

    final rocky = PetModel(
      id: 'pet-rocky',
      ownerId: demoOwnerId,
      storeId: happyPawsStoreId,
      name: 'Rocky',
      animalType: AnimalType.dog,
      breed: 'Bulldog',
      ageValue: 5,
      ageUnit: AgeUnit.months,
      lifeStage: LifeStage.young,
      youngAnimalName: 'Puppy',
      gender: Gender.male,
      description: 'Chubby, lovable Bulldog puppy who loves tummy rubs and short leisurely walks.',
      personality: 'Affectionate, Chill, Friendly',
      color: 'Brindle & White',
      size: 'Medium',
      weight: 8.2,
      healthInformation: 'Fully vet inspected, heartworm test negative.',
      vaccinationStatus: 'Fully Vaccinated',
      dewormingStatus: 'Completed',
      veterinaryCheck: 'Cleared by surgeon vet',
      isNeutered: false,
      adoptionFee: 350.0,
      location: 'Seattle, WA',
      latitude: 47.6105,
      longitude: -122.3415,
      availabilityStatus: PetAvailabilityStatus.available,
      images: [
        PetImageModel(
          id: 'img-rocky',
          petId: 'pet-rocky',
          imageUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?w=600',
          isPrimary: true,
          createdAt: now,
        ),
      ],
      createdAt: now.add(const Duration(minutes: 5)),
      updatedAt: now.add(const Duration(minutes: 5)),
    );

    // Save all initial pets
    for (final pet in [bruno, luna, milo, simba, coco, rocky]) {
      await repository.savePet(pet);
    }
  }
}
