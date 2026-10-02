import 'package:sqflite_common/sqlite_api.dart';

import '../database/database_service.dart';
import '../models/adoption_request_details.dart';
import '../models/adoption_request_model.dart';
import '../models/email_notification_model.dart';
import '../models/enums.dart';
import '../models/favorite_model.dart';
import '../models/pet_image_model.dart';
import '../models/pet_model.dart';
import '../models/pet_store_model.dart';
import '../models/user_model.dart';
import 'database_repository.dart';

/// Concrete SQLite implementation of [DatabaseRepository].
/// All queries use parameterized statements to prevent SQL injection vulnerabilities.
class DatabaseRepositoryImpl implements DatabaseRepository {
  final DatabaseService _dbService;

  DatabaseRepositoryImpl({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService();

  // ================= USERS =================

  @override
  Future<void> saveUser(UserModel user) async {
    await _dbService.insert(
      'users',
      user.toMap(includePassword: true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _dbService.update(
      'users',
      user.toMap(includePassword: true),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    final rows = await _dbService.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final rows = await _dbService.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final rows = await _dbService.query('users', orderBy: 'name ASC');
    return rows.map(UserModel.fromMap).toList();
  }

  @override
  Future<List<UserModel>> getPetOwners() async {
    final rows = await _dbService.query(
      'users',
      where: 'role = ?',
      whereArgs: [UserRole.petOwner.name],
      orderBy: 'name ASC',
    );
    return rows.map(UserModel.fromMap).toList();
  }

  // ================= PET STORES =================

  @override
  Future<void> savePetStore(PetStoreModel store) async {
    await _dbService.insert(
      'pet_stores',
      store.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<PetStoreModel?> getPetStoreById(String id) async {
    final rows = await _dbService.query(
      'pet_stores',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PetStoreModel.fromMap(rows.first);
  }

  @override
  Future<void> updatePetStore(PetStoreModel store) async {
    await _dbService.update(
      'pet_stores',
      store.toMap(),
      where: 'id = ?',
      whereArgs: [store.id],
    );
  }

  @override
  Future<void> deletePetStore(String storeId) async {
    await _dbService.transaction((txn) async {
      // Unlink pets associated with this store so they aren't orphaned
      await txn.update(
        'pets',
        {'store_id': null},
        where: 'store_id = ?',
        whereArgs: [storeId],
      );
      await txn.delete(
        'pet_stores',
        where: 'id = ?',
        whereArgs: [storeId],
      );
    });
  }

  @override
  Future<void> toggleStoreActiveStatus(String storeId, bool isActive) async {
    await _dbService.update(
      'pet_stores',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [storeId],
    );
  }

  @override
  Future<List<PetStoreModel>> getAllPetStores({String? searchQuery, bool activeOnly = false}) async {
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (activeOnly) {
      whereClauses.add('is_active = 1');
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim()}%';
      whereClauses.add('(name LIKE ? OR city LIKE ? OR state LIKE ? OR description LIKE ?)');
      whereArgs.addAll([term, term, term, term]);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
    final rows = await _dbService.query(
      'pet_stores',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );
    return rows.map(PetStoreModel.fromMap).toList();
  }

  @override
  Future<List<PetStoreModel>> getStoresByOwner(String ownerId) async {
    final rows = await _dbService.query(
      'pet_stores',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(PetStoreModel.fromMap).toList();
  }

  @override
  Future<int> getAvailablePetCountForStore(String storeId) async {
    final rows = await _dbService.rawQuery(
      'SELECT COUNT(*) as pet_count FROM pets WHERE store_id = ? AND availability_status = ?;',
      [storeId, PetAvailabilityStatus.available.name],
    );
    if (rows.isEmpty) return 0;
    return (rows.first['pet_count'] as int?) ?? 0;
  }

  // ================= PETS =================

  @override
  Future<void> savePet(PetModel pet) async {
    await _dbService.transaction((txn) async {
      await txn.insert(
        'pets',
        pet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Save associated images
      for (final image in pet.images) {
        await txn.insert(
          'pet_images',
          image.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updatePet(PetModel pet) async {
    await _dbService.transaction((txn) async {
      await txn.update(
        'pets',
        pet.toMap(),
        where: 'id = ?',
        whereArgs: [pet.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Refresh images if provided
      if (pet.images.isNotEmpty) {
        await txn.delete(
          'pet_images',
          where: 'pet_id = ?',
          whereArgs: [pet.id],
        );
        for (final image in pet.images) {
          await txn.insert(
            'pet_images',
            image.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  @override
  Future<PetModel?> getPetById(String id) async {
    final rows = await _dbService.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final images = await getImagesForPet(id);
    return PetModel.fromMap(rows.first, images: images);
  }

  @override
  Future<List<PetModel>> getPetsByStore(
    String storeId, {
    String? searchQuery,
    AnimalType? animalType,
    String? breed,
    Gender? gender,
    int? maxAgeWeeks,
  }) async {
    // Immutable parameterized constraint: store_id = ? AND availability_status = 'available'
    final whereClauses = <String>[
      'store_id = ?',
      'availability_status = ?',
    ];
    final whereArgs = <dynamic>[
      storeId,
      PetAvailabilityStatus.available.name,
    ];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim()}%';
      whereClauses.add('(name LIKE ? OR breed LIKE ? OR animal_type LIKE ? OR young_animal_name LIKE ?)');
      whereArgs.addAll([term, term, term, term]);
    }

    if (animalType != null) {
      whereClauses.add('animal_type = ?');
      whereArgs.add(animalType.name);
    }

    if (breed != null && breed.trim().isNotEmpty) {
      whereClauses.add('breed LIKE ?');
      whereArgs.add('%${breed.trim()}%');
    }

    if (gender != null) {
      whereClauses.add('gender = ?');
      whereArgs.add(gender.name);
    }

    if (maxAgeWeeks != null) {
      whereClauses.add(
        '((age_unit = "weeks" AND age_value <= ?) OR (age_unit = "months" AND age_value * 4 <= ?) OR (age_unit = "days" AND age_value <= ?))',
      );
      whereArgs.addAll([maxAgeWeeks, maxAgeWeeks, maxAgeWeeks * 7]);
    }

    final where = whereClauses.join(' AND ');
    final rows = await _dbService.query(
      'pets',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    final pets = <PetModel>[];
    for (final row in rows) {
      final petId = row['id'] as String;
      final images = await getImagesForPet(petId);
      pets.add(PetModel.fromMap(row, images: images));
    }
    return pets;
  }

  @override
  Future<List<PetModel>> getPets({
    String? searchQuery,
    AnimalType? animalType,
    LifeStage? lifeStage,
    Gender? gender,
    PetAvailabilityStatus? status,
    String? location,
    String? breed,
    String? storeId,
    String? ownerId,
    double? minFee,
    double? maxFee,
    PetSortOrder sortOrder = PetSortOrder.newest,
    int? limit,
    int? offset,
  }) async {
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    // 1. Parameterized Full-Text Search across name, breed, animal type, location, young animal term
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      whereClauses.add(
        '(name LIKE ? OR breed LIKE ? OR animal_type LIKE ? OR location LIKE ? OR young_animal_name LIKE ?)',
      );
      whereArgs.addAll([q, q, q, q, q]);
    }

    // 2. Exact & Pattern Filters
    if (animalType != null) {
      whereClauses.add('animal_type = ?');
      whereArgs.add(animalType.name);
    }
    if (lifeStage != null) {
      whereClauses.add('life_stage = ?');
      whereArgs.add(lifeStage.name);
    }
    if (gender != null) {
      whereClauses.add('gender = ?');
      whereArgs.add(gender.name);
    }
    if (status != null) {
      whereClauses.add('availability_status = ?');
      whereArgs.add(status.name);
    }
    if (location != null && location.trim().isNotEmpty) {
      whereClauses.add('location LIKE ?');
      whereArgs.add('%${location.trim()}%');
    }
    if (breed != null && breed.trim().isNotEmpty) {
      whereClauses.add('breed LIKE ?');
      whereArgs.add('%${breed.trim()}%');
    }
    if (storeId != null) {
      whereClauses.add('store_id = ?');
      whereArgs.add(storeId);
    }
    if (ownerId != null) {
      whereClauses.add('owner_id = ?');
      whereArgs.add(ownerId);
    }
    if (minFee != null) {
      whereClauses.add('adoption_fee >= ?');
      whereArgs.add(minFee);
    }
    if (maxFee != null) {
      whereClauses.add('adoption_fee <= ?');
      whereArgs.add(maxFee);
    }

    // 3. Sorting clause
    final orderBy = switch (sortOrder) {
      PetSortOrder.newest => 'created_at DESC',
      PetSortOrder.oldest => 'created_at ASC',
      PetSortOrder.youngest =>
        '''(CASE age_unit 
            WHEN 'days' THEN age_value 
            WHEN 'weeks' THEN age_value * 7 
            WHEN 'months' THEN age_value * 30 
            WHEN 'years' THEN age_value * 365 
            ELSE age_value END) ASC''',
      PetSortOrder.priceLowToHigh => 'adoption_fee ASC',
      PetSortOrder.priceHighToLow => 'adoption_fee DESC',
    };

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
    final rows = await _dbService.query(
      'pets',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    final pets = <PetModel>[];
    for (final row in rows) {
      final petId = row['id'] as String;
      final images = await getImagesForPet(petId);
      pets.add(PetModel.fromMap(row, images: images));
    }
    return pets;
  }

  @override
  Future<List<PetModel>> getPetsByOwner(String ownerId) async {
    return getPets(
      ownerId: ownerId,
      sortOrder: PetSortOrder.newest,
    );
  }

  @override
  Future<void> updatePetStatus(String petId, PetAvailabilityStatus status) async {
    await _dbService.update(
      'pets',
      {
        'availability_status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [petId],
    );
  }

  @override
  Future<void> deletePet(String petId) async {
    await _dbService.delete(
      'pets',
      where: 'id = ?',
      whereArgs: [petId],
    );
  }

  // ================= PET IMAGES =================

  @override
  Future<void> savePetImage(PetImageModel image) async {
    await _dbService.insert(
      'pet_images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<PetImageModel>> getImagesForPet(String petId) async {
    final rows = await _dbService.query(
      'pet_images',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'is_primary DESC, created_at ASC',
    );
    return rows.map(PetImageModel.fromMap).toList();
  }

  @override
  Future<void> deletePetImage(String imageId) async {
    await _dbService.delete(
      'pet_images',
      where: 'id = ?',
      whereArgs: [imageId],
    );
  }

  // ================= ADOPTION REQUESTS =================

  @override
  Future<void> saveAdoptionRequest(AdoptionRequestModel request) async {
    final hasActive = await hasActiveAdoptionRequest(request.adopterId, request.petId);
    if (hasActive) {
      throw StateError('An active application for this companion is already pending or approved.');
    }
    await _dbService.insert(
      'adoption_requests',
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> hasActiveAdoptionRequest(String adopterId, String petId) async {
    final rows = await _dbService.rawQuery(
      "SELECT COUNT(*) as count FROM adoption_requests WHERE adopter_id = ? AND pet_id = ? AND status IN ('pending', 'approved');",
      [adopterId, petId],
    );
    final count = (rows.isNotEmpty && rows.first['count'] != null)
        ? (rows.first['count'] as num).toInt()
        : 0;
    return count > 0;
  }

  @override
  Future<AdoptionRequestModel?> getAdoptionRequestById(String id) async {
    final rows = await _dbService.query(
      'adoption_requests',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AdoptionRequestModel.fromMap(rows.first);
  }

  @override
  Future<List<AdoptionRequestModel>> getAdoptionRequestsForUser(String userId) async {
    final rows = await _dbService.query(
      'adoption_requests',
      where: 'adopter_id = ? OR owner_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(AdoptionRequestModel.fromMap).toList();
  }

  @override
  Future<List<AdoptionRequestModel>> getAdoptionRequestsForPet(String petId) async {
    final rows = await _dbService.query(
      'adoption_requests',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'created_at DESC',
    );
    return rows.map(AdoptionRequestModel.fromMap).toList();
  }

  @override
  Future<List<AdoptionRequestDetails>> getAdoptionRequestDetailsForAdopter(String adopterId) async {
    final requests = await _dbService.query(
      'adoption_requests',
      where: 'adopter_id = ?',
      whereArgs: [adopterId],
      orderBy: 'created_at DESC',
    );
    final list = <AdoptionRequestDetails>[];
    for (final row in requests) {
      final req = AdoptionRequestModel.fromMap(row);
      final pet = await getPetById(req.petId);
      PetStoreModel? store;
      if (req.storeId != null) {
        store = await getPetStoreById(req.storeId!);
      } else if (pet?.storeId != null) {
        store = await getPetStoreById(pet!.storeId!);
      }
      final adopter = await getUserById(req.adopterId);
      list.add(AdoptionRequestDetails(
        request: req,
        pet: pet,
        adopter: adopter,
        store: store,
      ));
    }
    return list;
  }

  @override
  Future<List<AdoptionRequestDetails>> getAdoptionRequestDetailsForOwner(String ownerId) async {
    final rows = await _dbService.rawQuery(
      '''
      SELECT ar.* FROM adoption_requests ar
      INNER JOIN pets p ON ar.pet_id = p.id
      WHERE p.owner_id = ? OR ar.owner_id = ?
      ORDER BY ar.created_at DESC;
      ''',
      [ownerId, ownerId],
    );
    final list = <AdoptionRequestDetails>[];
    for (final row in rows) {
      final req = AdoptionRequestModel.fromMap(row);
      final pet = await getPetById(req.petId);
      final adopter = await getUserById(req.adopterId);
      PetStoreModel? store;
      if (req.storeId != null) {
        store = await getPetStoreById(req.storeId!);
      } else if (pet?.storeId != null) {
        store = await getPetStoreById(pet!.storeId!);
      }
      list.add(AdoptionRequestDetails(
        request: req,
        pet: pet,
        adopter: adopter,
        store: store,
      ));
    }
    return list;
  }

  @override
  Future<void> updateAdoptionRequestStatus(String requestId, AdoptionRequestStatus status) async {
    await _dbService.update(
      'adoption_requests',
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [requestId],
    );
  }

  @override
  Future<void> approveAdoptionRequest(
    String requestId, {
    String? deliveryMethod,
    String? deliveryAddress,
    String? deliveryDate,
    String? deliveryInstructions,
    String? paymentMethod,
    double? paymentAmount,
    String? paymentInstructions,
    String? approvalMessage,
    String? emailSentTo,
    EmailNotificationModel? emailNotification,
  }) async {
    await _dbService.transaction((txn) async {
      final reqRows = await txn.query('adoption_requests', where: 'id = ?', whereArgs: [requestId]);
      if (reqRows.isEmpty) throw StateError('Adoption request not found: $requestId');
      final req = AdoptionRequestModel.fromMap(reqRows.first);
      final now = DateTime.now().toIso8601String();

      final updateMap = <String, dynamic>{
        'status': AdoptionRequestStatus.approved.name,
        'updated_at': now,
      };
      if (deliveryMethod != null) updateMap['delivery_method'] = deliveryMethod;
      if (deliveryAddress != null) updateMap['delivery_address'] = deliveryAddress;
      if (deliveryDate != null) updateMap['delivery_date'] = deliveryDate;
      if (deliveryInstructions != null) updateMap['delivery_instructions'] = deliveryInstructions;
      if (paymentMethod != null) updateMap['payment_method'] = paymentMethod;
      if (paymentAmount != null) updateMap['payment_amount'] = paymentAmount;
      if (paymentInstructions != null) updateMap['payment_instructions'] = paymentInstructions;
      if (approvalMessage != null) updateMap['approval_message'] = approvalMessage;
      if (emailSentTo != null) updateMap['email_sent_to'] = emailSentTo;
      updateMap['email_sent_at'] = now;

      // 1. Set request status to APPROVED with delivery and payment fields
      await txn.update(
        'adoption_requests',
        updateMap,
        where: 'id = ?',
        whereArgs: [requestId],
      );

      // 2. Set pet availability_status to pending (PENDING_ADOPTION)
      await txn.update(
        'pets',
        {
          'availability_status': PetAvailabilityStatus.pending.name,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [req.petId],
      );

      // 3. Save email notification record if provided
      if (emailNotification != null) {
        await txn.insert(
          'email_notifications',
          emailNotification.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> rejectAdoptionRequest(String requestId) async {
    await _dbService.transaction((txn) async {
      final reqRows = await txn.query('adoption_requests', where: 'id = ?', whereArgs: [requestId]);
      if (reqRows.isEmpty) throw StateError('Adoption request not found: $requestId');
      final req = AdoptionRequestModel.fromMap(reqRows.first);
      final now = DateTime.now().toIso8601String();

      // 1. Set request status to REJECTED
      await txn.update(
        'adoption_requests',
        {
          'status': AdoptionRequestStatus.rejected.name,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );

      // 2. If no other approved requests exist for this pet, revert pet to AVAILABLE
      final otherApproved = await txn.query(
        'adoption_requests',
        where: 'pet_id = ? AND status = ? AND id != ?',
        whereArgs: [req.petId, AdoptionRequestStatus.approved.name, requestId],
      );
      if (otherApproved.isEmpty) {
        await txn.update(
          'pets',
          {
            'availability_status': PetAvailabilityStatus.available.name,
            'updated_at': now,
          },
          where: 'id = ?',
          whereArgs: [req.petId],
        );
      }
    });
  }

  @override
  Future<void> completeAdoptionRequest(String requestId) async {
    await _dbService.transaction((txn) async {
      final reqRows = await txn.query('adoption_requests', where: 'id = ?', whereArgs: [requestId]);
      if (reqRows.isEmpty) throw StateError('Adoption request not found: $requestId');
      final req = AdoptionRequestModel.fromMap(reqRows.first);
      final now = DateTime.now().toIso8601String();

      // 1. Set request status to COMPLETED
      await txn.update(
        'adoption_requests',
        {
          'status': AdoptionRequestStatus.completed.name,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );

      // 2. Set pet availability_status to ADOPTED
      await txn.update(
        'pets',
        {
          'availability_status': PetAvailabilityStatus.adopted.name,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [req.petId],
      );

      // 3. Automatically reject any other pending requests for this companion
      await txn.update(
        'adoption_requests',
        {
          'status': AdoptionRequestStatus.rejected.name,
          'updated_at': now,
        },
        where: 'pet_id = ? AND status = ?',
        whereArgs: [req.petId, AdoptionRequestStatus.pending.name],
      );
    });
  }

  @override
  Future<void> cancelAdoptionRequest(String requestId, String adopterId) async {
    await _dbService.transaction((txn) async {
      final reqRows = await txn.query(
        'adoption_requests',
        where: 'id = ? AND adopter_id = ?',
        whereArgs: [requestId, adopterId],
      );
      if (reqRows.isEmpty) throw StateError('Adoption request not found or unauthorized');
      final req = AdoptionRequestModel.fromMap(reqRows.first);
      if (req.status != AdoptionRequestStatus.pending) {
        throw StateError('Only pending adoption requests can be cancelled');
      }
      final now = DateTime.now().toIso8601String();
      await txn.update(
        'adoption_requests',
        {
          'status': AdoptionRequestStatus.cancelled.name,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );
    });
  }

  // ================= FAVORITES =================

  @override
  Future<void> toggleFavorite(String userId, String petId) async {
    final isFav = await isFavorite(userId, petId);
    if (isFav) {
      await removeFavorite(userId, petId);
    } else {
      await addFavorite(userId, petId);
    }
  }

  @override
  Future<void> addFavorite(String userId, String petId) async {
    final exists = await isFavorite(userId, petId);
    if (!exists) {
      final fav = FavoriteModel(
        id: '${userId}_$petId',
        userId: userId,
        petId: petId,
        createdAt: DateTime.now(),
      );
      await _dbService.insert(
        'favorites',
        fav.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  @override
  Future<void> removeFavorite(String userId, String petId) async {
    await _dbService.delete(
      'favorites',
      where: 'user_id = ? AND pet_id = ?',
      whereArgs: [userId, petId],
    );
  }

  @override
  Future<bool> isFavorite(String userId, String petId) async {
    final rows = await _dbService.query(
      'favorites',
      where: 'user_id = ? AND pet_id = ?',
      whereArgs: [userId, petId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    final rows = await _dbService.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(FavoriteModel.fromMap).toList();
  }

  @override
  Future<List<String>> getFavoritePetIds(String userId) async {
    final rows = await _dbService.query(
      'favorites',
      columns: ['pet_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map((r) => r['pet_id'] as String).toList();
  }

  @override
  Future<List<PetModel>> getFavoritePets(String userId) async {
    final ids = await getFavoritePetIds(userId);
    if (ids.isEmpty) return [];

    final pets = <PetModel>[];
    for (final id in ids) {
      final pet = await getPetById(id);
      if (pet != null) pets.add(pet);
    }
    return pets;
  }

  // ================= INITIAL SEED DATA =================

  @override
  Future<void> seedInitialDataIfEmpty() async {
    final stores = await getAllPetStores();
    if (stores.isEmpty) {
      final now = DateTime.now();

      // Seed verified pet stores with full Phase 5 store attributes
      final store1 = PetStoreModel(
        id: 'store_austin_nursery',
        ownerId: 'owner_austin_care',
        name: 'Little Paws Nursery & Sanctuary',
        description: 'Certified caregiver center specializing in rescued puppies, kittens, and gentle young animals.',
        address: '420 Woodland Trail',
        city: 'Austin',
        state: 'TX',
        country: 'United States',
        phone: '512-555-0142',
        email: 'hello@littlepaws.org',
        website: 'https://littlepaws.org',
        logoUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=300&q=80',
        coverImageUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=1200&q=80',
        openingHours: 'Mon - Sat: 9:00 AM - 6:00 PM',
        isActive: true,
        createdAt: now,
      );
      final store2 = PetStoreModel(
        id: 'store_portland_haven',
        ownerId: 'owner_portland_care',
        name: 'Whisker Woods Young Pet Haven',
        description: 'Dedicated sanctuary for baby bunnies, chicks, hand-fed cockatiels, and young companions.',
        address: '880 Evergreen Blvd',
        city: 'Portland',
        state: 'OR',
        country: 'United States',
        phone: '503-555-0188',
        email: 'contact@whiskerwoods.org',
        website: 'https://whiskerwoods.org',
        logoUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&q=80',
        coverImageUrl: 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?auto=format&fit=crop&w=1200&q=80',
        openingHours: 'Tue - Sun: 10:00 AM - 5:00 PM',
        isActive: true,
        createdAt: now,
      );
      final store3 = PetStoreModel(
        id: 'store_phoenix_center',
        ownerId: 'owner_phoenix_care',
        name: 'Sunshine Feather & Scale Sanctuary',
        description: 'Ethical small pet, reptile hatchling, and aquatic caregiver center with verified health records.',
        address: '1240 Sonoran Way',
        city: 'Phoenix',
        state: 'AZ',
        country: 'United States',
        phone: '602-555-0199',
        email: 'info@sunshinefeathers.org',
        website: 'https://sunshinefeathers.org',
        logoUrl: 'https://images.unsplash.com/photo-1535930891776-0c2dfb7fda1a?auto=format&fit=crop&w=300&q=80',
        coverImageUrl: 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=1200&q=80',
        openingHours: 'Mon - Sun: 9:00 AM - 7:00 PM',
        isActive: true,
        createdAt: now,
      );

      await savePetStore(store1);
      await savePetStore(store2);
      await savePetStore(store3);
    }

    final existingPets = await _dbService.query('pets', limit: 1);
    if (existingPets.isEmpty) {
      final now = DateTime.now();

      // Curated seed young pets prioritizing puppies, kittens, baby birds, baby rabbits, small animals, reptiles, fish
      final seedPets = <PetModel>[
        // 1. Puppy - Milo
        PetModel(
          id: 'pet_milo_puppy',
          name: 'Milo',
          animalType: AnimalType.dog,
          breed: 'Golden Retriever',
          ageValue: 10,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Puppy',
          gender: Gender.male,
          description:
              'Milo is an exceptionally playful, gentle, and curious Golden puppy. He loves tummy rubs, soft squeaky toys, and is doing wonderfully with potty training basics.',
          personality: 'Playful, affectionate, fast learner, gentle with kids',
          color: 'Warm Golden',
          size: 'Medium',
          weight: 6.2,
          healthInformation: 'Comprehensive vet examination completed. Strong heart and clear eyes.',
          vaccinationStatus: 'DHPP Core Vaccines Up-to-date (2nd round complete)',
          dewormingStatus: 'Completed (Bi-weekly protocol up to 10 weeks)',
          veterinaryCheck: 'Certified Healthy by Dr. Sarah Jenkins (DVM)',
          isNeutered: false,
          adoptionFee: 320.0,
          location: 'Austin, TX',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_austin_nursery',
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_milo_1',
              petId: 'pet_milo_puppy',
              imageUrl:
                  'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 2. Kitten - Luna
        PetModel(
          id: 'pet_luna_kitten',
          name: 'Luna',
          animalType: AnimalType.cat,
          breed: 'Ragdoll',
          ageValue: 8,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Kitten',
          gender: Gender.female,
          description:
              'Luna is an adorable baby blue-eyed Ragdoll kitten with a purr engine that starts the moment you hold her. Extremely docile and loves lap naps.',
          personality: 'Cuddly, peaceful, sweet, loves feather wands',
          color: 'Seal Point & White',
          size: 'Small',
          weight: 1.1,
          healthInformation: 'Litter trained, flea-free, negative for FeLV/FIV.',
          vaccinationStatus: 'FVRCP Initial Vaccine administered',
          dewormingStatus: 'Completed',
          veterinaryCheck: 'Health Certificate Verified',
          isNeutered: false,
          adoptionFee: 240.0,
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_portland_haven',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_luna_1',
              petId: 'pet_luna_kitten',
              imageUrl:
                  'https://images.unsplash.com/photo-1574158622682-e40e69881006?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 3. Puppy - Daisy
        PetModel(
          id: 'pet_daisy_puppy',
          name: 'Daisy',
          animalType: AnimalType.dog,
          breed: 'French Bulldog',
          ageValue: 14,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.young,
          youngAnimalName: 'Puppy',
          gender: Gender.female,
          description:
              'Daisy is a spirited, comical little Frenchie puppy who loves rolling on plush rugs and chasing tennis balls. Friendly with dogs and people of all ages.',
          personality: 'Energetic, goofy, social, sweet snuggler',
          color: 'Fawn & Black Mask',
          size: 'Small',
          weight: 5.4,
          healthInformation: 'Clear airways, healthy spine, microchipped.',
          vaccinationStatus: 'Fully vaccinated for age (Rabies + DHPP)',
          dewormingStatus: 'Completed',
          veterinaryCheck: 'Full veterinary wellness exam passed',
          isNeutered: false,
          adoptionFee: 450.0,
          location: 'Austin, TX',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_austin_nursery',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_daisy_1',
              petId: 'pet_daisy_puppy',
              imageUrl:
                  'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 4. Baby Rabbit - Clover
        PetModel(
          id: 'pet_clover_bunny',
          name: 'Clover',
          animalType: AnimalType.rabbit,
          breed: 'Holland Lop',
          ageValue: 9,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Kit (Bunny)',
          gender: Gender.female,
          description:
              'Clover is a velvety-eared Holland Lop baby bunny. She binkies with delight during morning greens time and enjoys gentle petting between her ears.',
          personality: 'Curious, gentle, quiet, loves Timothy hay treats',
          color: 'Tortoiseshell / Cinnamon',
          size: 'Small',
          weight: 0.9,
          healthInformation: 'Ears and teeth checked and aligned. Active and healthy digestion.',
          vaccinationStatus: 'RHDV2 Vaccine administered',
          dewormingStatus: 'Preventative protocol complete',
          veterinaryCheck: 'Certified by Exotic Animal Vet',
          isNeutered: false,
          adoptionFee: 85.0,
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_portland_haven',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_clover_1',
              petId: 'pet_clover_bunny',
              imageUrl:
                  'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 5. Baby Bird - Pip
        PetModel(
          id: 'pet_pip_bird',
          name: 'Pip',
          animalType: AnimalType.bird,
          breed: 'Cockatiel',
          ageValue: 7,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Chick (Fledgling)',
          gender: Gender.male,
          description:
              'Pip was hand-fed and is fully socialized. He loves sitting on your finger or shoulder and practice whistling friendly morning tunes.',
          personality: 'Vocal, affectionate, curious, loves head scratches',
          color: 'Pied Grey & Yellow Crest',
          size: 'Small',
          weight: 0.08,
          healthInformation: 'Feathers in immaculate condition, strong wings and beak.',
          vaccinationStatus: 'Avian Polyomavirus negative',
          dewormingStatus: 'Internal parasite screening clear',
          veterinaryCheck: 'Avian Specialist Health Certificate',
          isNeutered: false,
          adoptionFee: 120.0,
          location: 'Phoenix, AZ',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_phoenix_center',
          createdAt: now.subtract(const Duration(days: 6)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_pip_1',
              petId: 'pet_pip_bird',
              imageUrl:
                  'https://images.unsplash.com/photo-1552728089-57bdde30beb3?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 6. Kitten - Oliver
        PetModel(
          id: 'pet_oliver_kitten',
          name: 'Oliver',
          animalType: AnimalType.cat,
          breed: 'British Shorthair',
          ageValue: 12,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.young,
          youngAnimalName: 'Kitten',
          gender: Gender.male,
          description:
              'Oliver has the famous chubby cheeks and plush dense coat of a British Blue kitten. Calm, poised, and fond of laser pointers and window watching.',
          personality: 'Gentle, observant, playful, independent yet affectionate',
          color: 'Classic British Blue',
          size: 'Medium',
          weight: 1.8,
          healthInformation: 'Feline leukemia negative, microchipped, fully weaned.',
          vaccinationStatus: 'Core vaccines completed (FVRCP 2 rounds)',
          dewormingStatus: 'Completed',
          veterinaryCheck: 'Certified Healthy',
          isNeutered: false,
          adoptionFee: 290.0,
          location: 'Austin, TX',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_austin_nursery',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_oliver_1',
              petId: 'pet_oliver_kitten',
              imageUrl:
                  'https://images.unsplash.com/photo-1548802673-380ab8ebc7b7?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 7. Young Small Animal - Peanut
        PetModel(
          id: 'pet_peanut_hamster',
          name: 'Peanut',
          animalType: AnimalType.other,
          breed: 'Syrian Hamster (Teddy Bear)',
          ageValue: 5,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Pup',
          gender: Gender.male,
          description:
              'Peanut is an active little hamster pup who loves his silent runner wheel, burrowing in aspen bedding, and pouching sunflower seeds from hands.',
          personality: 'Docile, gentle handler, active explorer',
          color: 'Golden Honey',
          size: 'Small',
          weight: 0.11,
          healthInformation: 'Wet tail free, clear respiratory check.',
          vaccinationStatus: 'N/A for hamsters',
          dewormingStatus: 'Clear',
          veterinaryCheck: 'Examined by Small Pet Vet',
          isNeutered: false,
          adoptionFee: 35.0,
          location: 'Phoenix, AZ',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_phoenix_center',
          createdAt: now.subtract(const Duration(days: 7)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_peanut_1',
              petId: 'pet_peanut_hamster',
              imageUrl:
                  'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 8. Young Reptile - Ziggy
        PetModel(
          id: 'pet_ziggy_gecko',
          name: 'Ziggy',
          animalType: AnimalType.reptile,
          breed: 'Crested Gecko',
          ageValue: 8,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Hatchling',
          gender: Gender.unknown,
          description:
              'Ziggy is a lively little Crested Gecko hatchling eating Pangea fruit diet regularly. Has a full tail, loves climbing ficus leaves, and is easy to care for.',
          personality: 'Curious, calm, friendly nocturnal climber',
          color: 'Harlequin Flame',
          size: 'Small',
          weight: 0.04,
          healthInformation: 'MBD free, full tail, eating fruit puree & dusted crickets.',
          vaccinationStatus: 'N/A for reptiles',
          dewormingStatus: 'Quarantined and clear',
          veterinaryCheck: 'Reptile Health Certificate Verified',
          isNeutered: false,
          adoptionFee: 95.0,
          location: 'Phoenix, AZ',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_phoenix_center',
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_ziggy_1',
              petId: 'pet_ziggy_gecko',
              imageUrl:
                  'https://images.unsplash.com/photo-1508817628294-5a453fa0b8fb?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),

        // 9. Young Fish - Finn
        PetModel(
          id: 'pet_finn_fish',
          name: 'Finn & Friends (Trio)',
          animalType: AnimalType.fish,
          breed: 'Dumbo Ear Halfmoon Guppy',
          ageValue: 4,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          youngAnimalName: 'Fry',
          gender: Gender.unknown,
          description:
              'A vibrant, active trio of young healthy fancy guppy fry. Already showing bright metallic blue and orange iridescent colorations.',
          personality: 'Peaceful, active schooling, eager feeders',
          color: 'Iridescent Blue & Gold',
          size: 'Small',
          weight: 0.01,
          healthInformation: 'Tank cycled, zero fin rot, eating micro-pellets.',
          vaccinationStatus: 'N/A for fish',
          dewormingStatus: 'Preventative copper-free quarantine passed',
          veterinaryCheck: 'Aquatic Specialist Inspected',
          isNeutered: false,
          adoptionFee: 25.0,
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          storeId: 'store_portland_haven',
          createdAt: now.subtract(const Duration(days: 9)),
          updatedAt: now,
          images: [
            PetImageModel(
              id: 'img_finn_1',
              petId: 'pet_finn_fish',
              imageUrl:
                  'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?auto=format&fit=crop&w=800&q=80',
              isPrimary: true,
              createdAt: now,
            ),
          ],
        ),
      ];

      for (final pet in seedPets) {
        await savePet(pet);
      }
    }
  }

  // ================= EMAIL NOTIFICATIONS =================

  @override
  Future<void> saveEmailNotification(EmailNotificationModel email) async {
    await _dbService.insert(
      'email_notifications',
      email.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<EmailNotificationModel>> getEmailNotificationsForUser(String userId) async {
    final rows = await _dbService.query(
      'email_notifications',
      where: 'recipient_id = ? OR sender_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(EmailNotificationModel.fromMap).toList();
  }

  @override
  Future<List<EmailNotificationModel>> getEmailNotificationsForRequest(String requestId) async {
    final rows = await _dbService.query(
      'email_notifications',
      where: 'request_id = ?',
      whereArgs: [requestId],
      orderBy: 'created_at DESC',
    );
    return rows.map(EmailNotificationModel.fromMap).toList();
  }

  @override
  Future<void> markEmailAsRead(String emailId) async {
    await _dbService.update(
      'email_notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [emailId],
    );
  }
}
