import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/enums.dart';
import '../models/pet_model.dart';
import '../models/pet_store_model.dart';
import '../models/user_model.dart';
import '../repositories/database_repository.dart';
import '../services/geo_location_service.dart';

/// Available marker display filters for the interactive map
enum MapFilterMode {
  all('All Locations', Icons.explore_rounded),
  stores('Pet Stores', Icons.storefront_rounded),
  owners('Pet Owners', Icons.people_alt_rounded),
  chosenPet('Chosen Pet', Icons.pets_rounded);

  final String label;
  final IconData icon;
  const MapFilterMode(this.label, this.icon);
}

/// Type of entity currently selected on the map
enum MapItemType { store, owner, pet }

/// Represents an entity selected on the map for detail inspection
class SelectedMapItem {
  final MapItemType type;
  final PetStoreModel? store;
  final UserModel? owner;
  final PetModel? pet;
  final LatLng coordinates;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final List<PetModel> associatedPets;

  const SelectedMapItem({
    required this.type,
    this.store,
    this.owner,
    this.pet,
    required this.coordinates,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.associatedPets = const [],
  });
}

/// State management for the Interactive Pet Stores & Pet Owners Map
class MapProvider extends ChangeNotifier {
  final DatabaseRepository repository;

  List<PetStoreModel> _stores = [];
  List<UserModel> _petOwners = [];
  List<PetModel> _allPets = [];
  final Map<String, int> _storePetCounts = {};
  final Map<String, List<PetModel>> _ownerPets = {};

  PetModel? _chosenPet;
  UserModel? _chosenPetOwner;
  PetStoreModel? _chosenPetStore;

  SelectedMapItem? _selectedItem;
  MapFilterMode _filterMode = MapFilterMode.all;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Cached resolved coordinates to avoid recalculating jitter
  final Map<String, LatLng> _storeCoords = {};
  final Map<String, LatLng> _ownerCoords = {};
  final Map<String, LatLng> _petCoords = {};

  MapProvider({required this.repository});

  List<PetStoreModel> get stores => _stores;
  List<UserModel> get petOwners => _petOwners;
  List<PetModel> get allPets => _allPets;
  Map<String, int> get storePetCounts => _storePetCounts;
  Map<String, List<PetModel>> get ownerPets => _ownerPets;

  PetModel? get chosenPet => _chosenPet;
  UserModel? get chosenPetOwner => _chosenPetOwner;
  PetStoreModel? get chosenPetStore => _chosenPetStore;

  SelectedMapItem? get selectedItem => _selectedItem;
  MapFilterMode get filterMode => _filterMode;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads all pet stores, pet owners, pets, and resolves the initial chosen pet if [initialPetId] is provided.
  Future<void> loadMapData({String? initialPetId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch Stores, Owners, and Available Pets
      _stores = await repository.getAllPetStores(activeOnly: false);
      _petOwners = await repository.getPetOwners();
      _allPets = await repository.getPets(status: PetAvailabilityStatus.available);

      // 2. Compute store pet counts
      _storePetCounts.clear();
      for (final store in _stores) {
        final count = await repository.getAvailablePetCountForStore(store.id);
        _storePetCounts[store.id] = count;
      }

      // 3. Map pets to owners
      _ownerPets.clear();
      for (final owner in _petOwners) {
        final pets = await repository.getPetsByOwner(owner.id);
        _ownerPets[owner.id] = pets;
      }

      // 4. Precompute resolved coordinates with deterministic dispersion
      _precomputeCoordinates();

      // 5. Select initial chosen pet if provided
      if (initialPetId != null && initialPetId.isNotEmpty) {
        await choosePetById(initialPetId);
      } else if (_chosenPet != null) {
        // Refresh chosen pet if already set
        await choosePetById(_chosenPet!.id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _precomputeCoordinates() {
    _storeCoords.clear();
    for (int i = 0; i < _stores.length; i++) {
      final s = _stores[i];
      _storeCoords[s.id] = GeoLocationService.resolveCoordinates(
        explicitLat: s.latitude,
        explicitLng: s.longitude,
        city: s.city,
        address: s.address,
        fullLocation: s.fullLocation,
        entityId: 'store-${s.id}',
        indexHint: i,
      );
    }

    _ownerCoords.clear();
    for (int i = 0; i < _petOwners.length; i++) {
      final o = _petOwners[i];
      _ownerCoords[o.id] = GeoLocationService.resolveCoordinates(
        explicitLat: o.latitude,
        explicitLng: o.longitude,
        fullLocation: o.location,
        entityId: 'owner-${o.id}',
        indexHint: i + 10,
      );
    }

    _petCoords.clear();
    for (int i = 0; i < _allPets.length; i++) {
      final p = _allPets[i];
      _petCoords[p.id] = GeoLocationService.resolveCoordinates(
        explicitLat: p.latitude,
        explicitLng: p.longitude,
        fullLocation: p.location,
        entityId: 'pet-${p.id}',
        indexHint: i + 20,
      );
    }
  }

  LatLng getStoreLocation(PetStoreModel store) {
    return _storeCoords[store.id] ??
        GeoLocationService.resolveCoordinates(
          explicitLat: store.latitude,
          explicitLng: store.longitude,
          city: store.city,
          address: store.address,
        );
  }

  LatLng getOwnerLocation(UserModel owner) {
    return _ownerCoords[owner.id] ??
        GeoLocationService.resolveCoordinates(
          explicitLat: owner.latitude,
          explicitLng: owner.longitude,
          fullLocation: owner.location,
        );
  }

  LatLng getPetLocation(PetModel pet) {
    return _petCoords[pet.id] ??
        GeoLocationService.resolveCoordinates(
          explicitLat: pet.latitude,
          explicitLng: pet.longitude,
          fullLocation: pet.location,
        );
  }

  void setFilterMode(MapFilterMode mode) {
    _filterMode = mode;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectItem(SelectedMapItem? item) {
    _selectedItem = item;
    notifyListeners();
  }

  /// Sets the chosen pet by ID and resolves its associated owner and store
  Future<void> choosePetById(String petId) async {
    PetModel? pet = _allPets.where((p) => p.id == petId).firstOrNull;
    pet ??= await repository.getPetById(petId);

    if (pet != null) {
      choosePet(pet);
    }
  }

  /// Sets the chosen pet and automatically links its owner and store
  void choosePet(PetModel? pet) {
    _chosenPet = pet;
    if (pet == null) {
      _chosenPetOwner = null;
      _chosenPetStore = null;
    } else {
      if (pet.ownerId != null) {
        _chosenPetOwner = _petOwners.where((o) => o.id == pet.ownerId).firstOrNull;
      } else {
        _chosenPetOwner = null;
      }

      if (pet.storeId != null) {
        _chosenPetStore = _stores.where((s) => s.id == pet.storeId).firstOrNull;
      } else {
        _chosenPetStore = null;
      }

      // Automatically select the chosen pet map item for inspection
      final coords = getPetLocation(pet);
      _selectedItem = SelectedMapItem(
        type: MapItemType.pet,
        pet: pet,
        coordinates: coords,
        title: pet.name,
        subtitle: '${pet.displayYoungName} • ${pet.breed}',
        imageUrl: pet.primaryImageUrl,
        associatedPets: [pet],
      );
    }
    notifyListeners();
  }

  /// Clears current chosen pet
  void clearChosenPet() {
    _chosenPet = null;
    _chosenPetOwner = null;
    _chosenPetStore = null;
    if (_selectedItem?.type == MapItemType.pet) {
      _selectedItem = null;
    }
    notifyListeners();
  }

  /// Filtered stores matching search query
  List<PetStoreModel> get filteredStores {
    if (_filterMode == MapFilterMode.owners || _filterMode == MapFilterMode.chosenPet) {
      return [];
    }
    if (_searchQuery.trim().isEmpty) return _stores;
    final q = _searchQuery.toLowerCase();
    return _stores.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.city.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q);
    }).toList();
  }

  /// Filtered pet owners matching search query
  List<UserModel> get filteredPetOwners {
    if (_filterMode == MapFilterMode.stores || _filterMode == MapFilterMode.chosenPet) {
      return [];
    }
    if (_searchQuery.trim().isEmpty) return _petOwners;
    final q = _searchQuery.toLowerCase();
    return _petOwners.where((o) {
      return o.name.toLowerCase().contains(q) ||
          (o.location ?? '').toLowerCase().contains(q);
    }).toList();
  }

  /// Filtered pets matching search query
  List<PetModel> get filteredPets {
    if (_searchQuery.trim().isEmpty) return _allPets;
    final q = _searchQuery.toLowerCase();
    return _allPets.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.breed.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
    }).toList();
  }
}
