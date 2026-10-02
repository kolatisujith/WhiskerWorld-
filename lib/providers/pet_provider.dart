import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/pet_model.dart';
import '../repositories/database_repository.dart';

/// State management for Pet Discovery, Search, Filtering, and Owner Management
class PetProvider extends ChangeNotifier {
  final DatabaseRepository repository;

  // Discovery state
  List<PetModel> _pets = [];
  List<PetModel> _featuredPets = [];
  PetModel? _selectedPet;
  bool _isLoading = false;
  String? _errorMessage;

  // Owner state
  List<PetModel> _myPets = [];
  bool _isMyPetsLoading = false;

  // Search & Filter state
  String _searchQuery = '';
  AnimalType? _selectedAnimalType;
  LifeStage? _selectedLifeStage;
  Gender? _selectedGender;
  PetAvailabilityStatus? _selectedAvailabilityStatus;
  String? _selectedBreed;
  String? _selectedLocation;
  String? _selectedStoreId;
  double? _minFee;
  double? _maxFee;
  PetSortOrder _sortOrder = PetSortOrder.newest;

  PetProvider({required this.repository});

  // Getters
  List<PetModel> get pets => _pets;
  List<PetModel> get featuredPets => _featuredPets;
  List<PetModel> get myPets => _myPets;
  PetModel? get selectedPet => _selectedPet;
  bool get isLoading => _isLoading;
  bool get isMyPetsLoading => _isMyPetsLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  AnimalType? get selectedAnimalType => _selectedAnimalType;
  LifeStage? get selectedLifeStage => _selectedLifeStage;
  Gender? get selectedGender => _selectedGender;
  PetAvailabilityStatus? get selectedAvailabilityStatus => _selectedAvailabilityStatus;
  String? get selectedBreed => _selectedBreed;
  String? get selectedLocation => _selectedLocation;
  String? get selectedStoreId => _selectedStoreId;
  double? get minFee => _minFee;
  double? get maxFee => _maxFee;
  PetSortOrder get sortOrder => _sortOrder;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedAnimalType != null ||
      _selectedLifeStage != null ||
      _selectedGender != null ||
      _selectedAvailabilityStatus != null ||
      _selectedBreed != null ||
      _selectedLocation != null ||
      _selectedStoreId != null ||
      _minFee != null ||
      _maxFee != null;

  /// Updates search query and re-runs query
  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchPets();
  }

  /// Sets specific filters and refreshes pets list
  void setFilters({
    String? query,
    AnimalType? animalType,
    LifeStage? lifeStage,
    Gender? gender,
    PetAvailabilityStatus? status,
    String? breed,
    String? location,
    String? storeId,
    double? minFee,
    double? maxFee,
    PetSortOrder? sortOrder,
  }) {
    if (query != null) _searchQuery = query;
    _selectedAnimalType = animalType;
    _selectedLifeStage = lifeStage;
    _selectedGender = gender;
    _selectedAvailabilityStatus = status;
    _selectedBreed = breed;
    _selectedLocation = location;
    _selectedStoreId = storeId;
    _minFee = minFee;
    _maxFee = maxFee;
    if (sortOrder != null) _sortOrder = sortOrder;
    fetchPets();
  }

  /// Updates sort order and refreshes results
  void setSortOrder(PetSortOrder order) {
    _sortOrder = order;
    fetchPets();
  }

  /// Resets all filters back to default
  void resetFilters() {
    _searchQuery = '';
    _selectedAnimalType = null;
    _selectedLifeStage = null;
    _selectedGender = null;
    _selectedAvailabilityStatus = null;
    _selectedBreed = null;
    _selectedLocation = null;
    _selectedStoreId = null;
    _minFee = null;
    _maxFee = null;
    _sortOrder = PetSortOrder.newest;
    fetchPets();
  }

  /// Selects a pet for details view
  void selectPet(PetModel? pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  /// Fetches a specific pet by ID
  Future<PetModel?> fetchPetById(String id) async {
    try {
      final pet = await repository.getPetById(id);
      _selectedPet = pet;
      notifyListeners();
      return pet;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Queries all public pets matching search & filters
  Future<void> fetchPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure seed data exists
      await repository.seedInitialDataIfEmpty();

      _pets = await repository.getPets(
        searchQuery: _searchQuery,
        animalType: _selectedAnimalType,
        lifeStage: _selectedLifeStage,
        gender: _selectedGender,
        status: _selectedAvailabilityStatus,
        breed: _selectedBreed,
        location: _selectedLocation,
        storeId: _selectedStoreId,
        minFee: _minFee,
        maxFee: _maxFee,
        sortOrder: _sortOrder,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads top featured young pets for homepage
  Future<void> fetchFeaturedPets() async {
    try {
      await repository.seedInitialDataIfEmpty();
      _featuredPets = await repository.getPets(
        status: PetAvailabilityStatus.available,
        sortOrder: PetSortOrder.youngest,
        limit: 6,
      );
      notifyListeners();
    } catch (_) {}
  }

  // ================= OWNER MANAGEMENT =================

  /// Fetches all pets owned by the authenticated pet owner
  Future<void> fetchMyPets(String ownerId) async {
    _isMyPetsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myPets = await repository.getPetsByOwner(ownerId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isMyPetsLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new pet to database and refreshes listings
  Future<bool> addPet(PetModel pet) async {
    try {
      await repository.savePet(pet);
      if (pet.ownerId != null) {
        await fetchMyPets(pet.ownerId!);
      }
      await fetchPets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing pet in database
  Future<bool> updatePet(PetModel pet) async {
    try {
      await repository.updatePet(pet);
      if (pet.ownerId != null) {
        await fetchMyPets(pet.ownerId!);
      }
      if (_selectedPet?.id == pet.id) {
        _selectedPet = pet;
      }
      await fetchPets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Deletes a pet from database with cascading image removal
  Future<bool> deletePet(String petId, String ownerId) async {
    try {
      await repository.deletePet(petId);
      await fetchMyPets(ownerId);
      await fetchPets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Quick 1-click toggle between Available and Unavailable
  Future<void> togglePetAvailability(
    String petId,
    PetAvailabilityStatus currentStatus,
    String ownerId,
  ) async {
    final newStatus = currentStatus == PetAvailabilityStatus.available
        ? PetAvailabilityStatus.unavailable
        : PetAvailabilityStatus.available;

    await updatePetStatus(petId, newStatus, ownerId: ownerId);
  }

  /// Direct status update
  Future<void> updatePetStatus(
    String petId,
    PetAvailabilityStatus status, {
    String? ownerId,
  }) async {
    try {
      await repository.updatePetStatus(petId, status);
      if (ownerId != null) {
        await fetchMyPets(ownerId);
      }
      if (_selectedPet?.id == petId) {
        _selectedPet = _selectedPet?.copyWith(availabilityStatus: status);
      }
      await fetchPets();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
