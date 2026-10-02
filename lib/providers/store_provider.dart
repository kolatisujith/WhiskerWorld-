import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/pet_model.dart';
import '../models/pet_store_model.dart';
import '../repositories/database_repository.dart';

/// State management for Pet Stores, Store-Specific Pet Discovery, and Owner Store Management
class StoreProvider extends ChangeNotifier {
  final DatabaseRepository repository;

  List<PetStoreModel> _stores = [];
  List<PetStoreModel> _myStores = [];
  PetStoreModel? _selectedStore;
  final Map<String, int> _storePetCounts = {};

  // Store-specific pet listing state
  List<PetModel> _storePets = [];
  String? _storeSearchQuery;
  AnimalType? _storeAnimalType;
  String? _storeBreed;
  Gender? _storeGender;
  int? _storeMaxAgeWeeks;

  bool _isLoading = false;
  bool _isStorePetsLoading = false;
  String? _errorMessage;
  String? _searchQuery;

  StoreProvider({required this.repository});

  List<PetStoreModel> get stores => _stores;
  List<PetStoreModel> get myStores => _myStores;
  PetStoreModel? get selectedStore => _selectedStore;
  Map<String, int> get storePetCounts => _storePetCounts;

  List<PetModel> get storePets => _storePets;
  String? get storeSearchQuery => _storeSearchQuery;
  AnimalType? get storeAnimalType => _storeAnimalType;
  String? get storeBreed => _storeBreed;
  Gender? get storeGender => _storeGender;
  int? get storeMaxAgeWeeks => _storeMaxAgeWeeks;

  bool get isLoading => _isLoading;
  bool get isStorePetsLoading => _isStorePetsLoading;
  String? get errorMessage => _errorMessage;
  String? get searchQuery => _searchQuery;

  int getPetCountForStore(String storeId) => _storePetCounts[storeId] ?? 0;

  void selectStore(PetStoreModel? store) {
    _selectedStore = store;
    notifyListeners();
  }

  PetStoreModel? getStoreById(String id) {
    return _stores.where((s) => s.id == id).firstOrNull ??
        _myStores.where((s) => s.id == id).firstOrNull;
  }

  /// Sets public store discovery search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    fetchStores(query: query);
  }

  /// Fetches all active stores for public discovery and calculates dynamic pet counts
  Future<void> fetchStores({String? query, bool activeOnly = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stores = await repository.getAllPetStores(
        searchQuery: query ?? _searchQuery,
        activeOnly: activeOnly,
      );

      // Dynamically calculate actual available pet count for each store
      for (final store in _stores) {
        final count = await repository.getAvailablePetCountForStore(store.id);
        _storePetCounts[store.id] = count;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches stores owned by the specified owner
  Future<void> fetchMyStores(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myStores = await repository.getStoresByOwner(ownerId);
      for (final store in _myStores) {
        final count = await repository.getAvailablePetCountForStore(store.id);
        _storePetCounts[store.id] = count;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches specific store by ID and updates selectedStore
  Future<PetStoreModel?> fetchStoreById(String id) async {
    try {
      final store = await repository.getPetStoreById(id);
      if (store != null) {
        _selectedStore = store;
        final count = await repository.getAvailablePetCountForStore(store.id);
        _storePetCounts[store.id] = count;
        notifyListeners();
      }
      return store;
    } catch (_) {
      return null;
    }
  }

  /// In-store pet filtering controls
  void setStoreFilters({
    String? searchQuery,
    AnimalType? animalType,
    String? breed,
    Gender? gender,
    int? maxAgeWeeks,
  }) {
    _storeSearchQuery = searchQuery;
    _storeAnimalType = animalType;
    _storeBreed = breed;
    _storeGender = gender;
    _storeMaxAgeWeeks = maxAgeWeeks;

    if (_selectedStore != null) {
      fetchPetsForStore(_selectedStore!.id);
    }
  }

  /// Resets in-store pet filters
  void resetStoreFilters() {
    _storeSearchQuery = null;
    _storeAnimalType = null;
    _storeBreed = null;
    _storeGender = null;
    _storeMaxAgeWeeks = null;

    if (_selectedStore != null) {
      fetchPetsForStore(_selectedStore!.id);
    }
  }

  /// Strict Parameterized Query fetching ONLY pets belonging to this store
  Future<void> fetchPetsForStore(String storeId) async {
    _isStorePetsLoading = true;
    notifyListeners();

    try {
      _storePets = await repository.getPetsByStore(
        storeId,
        searchQuery: _storeSearchQuery,
        animalType: _storeAnimalType,
        breed: _storeBreed,
        gender: _storeGender,
        maxAgeWeeks: _storeMaxAgeWeeks,
      );
      // Update real-time pet count
      _storePetCounts[storeId] = await repository.getAvailablePetCountForStore(storeId);
    } catch (e) {
      _errorMessage = e.toString();
      _storePets = [];
    } finally {
      _isStorePetsLoading = false;
      notifyListeners();
    }
  }

  /// Owner Store Creation
  Future<bool> createStore(PetStoreModel store) async {
    try {
      await repository.savePetStore(store);
      if (store.ownerId != null) {
        await fetchMyStores(store.ownerId!);
      }
      await fetchStores();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Owner Store Update with Security Verification
  Future<bool> updateStore(PetStoreModel store, String currentUserId) async {
    final existing = await repository.getPetStoreById(store.id);
    if (existing != null && existing.ownerId != null && existing.ownerId != currentUserId) {
      _errorMessage = 'Security Error: You are not authorized to edit this store.';
      notifyListeners();
      return false;
    }

    try {
      await repository.updatePetStore(store);
      if (store.ownerId != null) {
        await fetchMyStores(store.ownerId!);
      }
      await fetchStores();
      if (_selectedStore?.id == store.id) {
        _selectedStore = store;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Owner Store Deletion with Security Verification
  Future<bool> deleteStore(String storeId, String currentUserId) async {
    final existing = await repository.getPetStoreById(storeId);
    if (existing != null && existing.ownerId != null && existing.ownerId != currentUserId) {
      _errorMessage = 'Security Error: You cannot delete another owner\'s store.';
      notifyListeners();
      return false;
    }

    try {
      await repository.deletePetStore(storeId);
      await fetchMyStores(currentUserId);
      await fetchStores();
      if (_selectedStore?.id == storeId) {
        _selectedStore = null;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Owner Store Active/Inactive Toggle with Security Verification
  Future<bool> toggleStoreStatus(String storeId, bool isActive, String currentUserId) async {
    final existing = await repository.getPetStoreById(storeId);
    if (existing != null && existing.ownerId != null && existing.ownerId != currentUserId) {
      _errorMessage = 'Security Error: Unauthorized store modification.';
      notifyListeners();
      return false;
    }

    try {
      await repository.toggleStoreActiveStatus(storeId, isActive);
      await fetchMyStores(currentUserId);
      await fetchStores();
      if (_selectedStore?.id == storeId) {
        _selectedStore = _selectedStore?.copyWith(isActive: isActive);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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
