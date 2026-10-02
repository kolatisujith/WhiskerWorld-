import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// State management for User Authentication, Roles, and Session
class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required this.authService});

  UserModel? get currentUser => authService.currentUser;
  bool get isAuthenticated => authService.isAuthenticated;
  UserRole? get userRole => authService.userRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isPetOwner => userRole == UserRole.petOwner;
  bool get isPetAdopter => userRole == UserRole.petAdopter;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Restores session from persistent storage on startup
  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.restoreSession();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new user account
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? location,
    String? bio,
    String? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        location: location,
        bio: bio,
        profileImage: profileImage,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Authenticates user with credentials
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates profile details
  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? location,
    String? bio,
    String? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authService.updateProfile(
        name: name,
        phone: phone,
        location: location,
        bio: bio,
        profileImage: profileImage,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Terminates user session
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await authService.logout();
    _isLoading = false;
    notifyListeners();
  }
}
