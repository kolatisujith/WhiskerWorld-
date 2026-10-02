import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../repositories/database_repository.dart';

/// State management for Favorite Pets
class FavoriteProvider extends ChangeNotifier {
  final DatabaseRepository repository;

  Set<String> _favoritePetIds = {};
  List<PetModel> _favoritePets = [];
  bool _isLoading = false;
  String? _errorMessage;

  FavoriteProvider({required this.repository});

  Set<String> get favoritePetIds => _favoritePetIds;
  List<PetModel> get favoritePets => _favoritePets;
  int get count => _favoritePetIds.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isFavorite(String petId) => _favoritePetIds.contains(petId);

  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ids = await repository.getFavoritePetIds(userId);
      _favoritePetIds = ids.toSet();
      _favoritePets = await repository.getFavoritePets(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String userId, String petId) async {
    try {
      await repository.toggleFavorite(userId, petId);
      if (_favoritePetIds.contains(petId)) {
        _favoritePetIds.remove(petId);
        _favoritePets.removeWhere((p) => p.id == petId);
      } else {
        _favoritePetIds.add(petId);
        final pet = await repository.getPetById(petId);
        if (pet != null) _favoritePets.insert(0, pet);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String userId, String petId) async {
    try {
      await repository.removeFavorite(userId, petId);
      _favoritePetIds.remove(petId);
      _favoritePets.removeWhere((p) => p.id == petId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addFavorite(String userId, String petId) async {
    try {
      await repository.addFavorite(userId, petId);
      if (!_favoritePetIds.contains(petId)) {
        _favoritePetIds.add(petId);
        final pet = await repository.getPetById(petId);
        if (pet != null) _favoritePets.insert(0, pet);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
