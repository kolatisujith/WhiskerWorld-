import '../models/adoption_request_details.dart';
import '../models/adoption_request_model.dart';
import '../models/email_notification_model.dart';
import '../models/enums.dart';
import '../models/favorite_model.dart';
import '../models/pet_image_model.dart';
import '../models/pet_model.dart';
import '../models/pet_store_model.dart';
import '../models/user_model.dart';

/// Supported sort orders for pet queries.
enum PetSortOrder {
  newest('Newest First'),
  oldest('Oldest First'),
  youngest('Youngest Pets First'),
  priceLowToHigh('Adoption Fee: Low to High'),
  priceHighToLow('Adoption Fee: High to Low');

  final String label;
  const PetSortOrder(this.label);
}

/// Abstract contract for data persistence in Whisker World.
/// The application relies strictly on this contract, decoupling business logic from SQLite.
abstract class DatabaseRepository {
  // Users
  Future<void> saveUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<UserModel?> getUserById(String id);
  Future<UserModel?> getUserByEmail(String email);
  Future<List<UserModel>> getAllUsers();
  Future<List<UserModel>> getPetOwners();

  // Pet Stores
  Future<void> savePetStore(PetStoreModel store);
  Future<void> updatePetStore(PetStoreModel store);
  Future<void> deletePetStore(String storeId);
  Future<void> toggleStoreActiveStatus(String storeId, bool isActive);
  Future<PetStoreModel?> getPetStoreById(String id);
  Future<List<PetStoreModel>> getAllPetStores({String? searchQuery, bool activeOnly = false});
  Future<List<PetStoreModel>> getStoresByOwner(String ownerId);
  Future<int> getAvailablePetCountForStore(String storeId);

  // Pets
  Future<void> savePet(PetModel pet);
  Future<void> updatePet(PetModel pet);
  Future<PetModel?> getPetById(String id);
  Future<List<PetModel>> getPetsByStore(
    String storeId, {
    String? searchQuery,
    AnimalType? animalType,
    String? breed,
    Gender? gender,
    int? maxAgeWeeks,
  });
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
  });
  Future<List<PetModel>> getPetsByOwner(String ownerId);
  Future<void> updatePetStatus(String petId, PetAvailabilityStatus status);
  Future<void> deletePet(String petId);

  // Pet Images
  Future<void> savePetImage(PetImageModel image);
  Future<List<PetImageModel>> getImagesForPet(String petId);
  Future<void> deletePetImage(String imageId);

  // Adoption Requests
  Future<void> saveAdoptionRequest(AdoptionRequestModel request);
  Future<AdoptionRequestModel?> getAdoptionRequestById(String id);
  Future<List<AdoptionRequestModel>> getAdoptionRequestsForUser(String userId);
  Future<List<AdoptionRequestModel>> getAdoptionRequestsForPet(String petId);
  Future<void> updateAdoptionRequestStatus(String requestId, AdoptionRequestStatus status);
  Future<bool> hasActiveAdoptionRequest(String adopterId, String petId);
  Future<List<AdoptionRequestDetails>> getAdoptionRequestDetailsForAdopter(String adopterId);
  Future<List<AdoptionRequestDetails>> getAdoptionRequestDetailsForOwner(String ownerId);
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
  });
  Future<void> rejectAdoptionRequest(String requestId);
  Future<void> completeAdoptionRequest(String requestId);
  Future<void> cancelAdoptionRequest(String requestId, String adopterId);

  // Email Notifications
  Future<void> saveEmailNotification(EmailNotificationModel email);
  Future<List<EmailNotificationModel>> getEmailNotificationsForUser(String userId);
  Future<List<EmailNotificationModel>> getEmailNotificationsForRequest(String requestId);
  Future<void> markEmailAsRead(String emailId);

  // Favorites
  Future<void> toggleFavorite(String userId, String petId);
  Future<void> addFavorite(String userId, String petId);
  Future<void> removeFavorite(String userId, String petId);
  Future<bool> isFavorite(String userId, String petId);
  Future<List<FavoriteModel>> getFavorites(String userId);
  Future<List<String>> getFavoritePetIds(String userId);
  Future<List<PetModel>> getFavoritePets(String userId);

  // Seed Data Initializer
  Future<void> seedInitialDataIfEmpty();
}
