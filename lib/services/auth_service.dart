import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../models/user_model.dart';
import '../repositories/database_repository.dart';
import '../utils/password_hasher.dart';

/// Custom exception for authentication and authorization errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Authentication Service managing registration, secure login,
/// session persistence via SharedPreferences, and profile updates.
class AuthService {
  static const String sessionKey = 'whisker_world_session_user_id';

  final DatabaseRepository repository;
  SharedPreferences? prefs;
  UserModel? _currentUser;

  AuthService({
    required this.repository,
    this.prefs,
  });

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get userRole => _currentUser?.role;

  /// Ensures SharedPreferences instance is loaded.
  Future<SharedPreferences> _getPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
    return prefs!;
  }

  /// Restores persistent session on application start.
  Future<UserModel?> restoreSession() async {
    try {
      final p = await _getPrefs();
      final userId = p.getString(sessionKey);
      if (userId == null || userId.isEmpty) {
        _currentUser = null;
        return null;
      }

      final user = await repository.getUserById(userId);
      if (user != null) {
        _currentUser = user.sanitize();
        return _currentUser;
      } else {
        await p.remove(sessionKey);
        _currentUser = null;
        return null;
      }
    } catch (_) {
      _currentUser = null;
      return null;
    }
  }

  /// Registers a new user with secure password hashing.
  /// Prevents duplicate email registration.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? location,
    String? bio,
    String? profileImage,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const AuthException('Please provide a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters long.');
    }
    if (name.trim().isEmpty) {
      throw const AuthException('Full name is required.');
    }

    // Check duplicate email
    final existing = await repository.getUserByEmail(normalizedEmail);
    if (existing != null) {
      throw const AuthException('An account with this email address already exists.');
    }

    // Hash password with salt
    final passwordHash = PasswordHasher.hashPassword(password);
    final now = DateTime.now();
    final newId = 'user_${now.millisecondsSinceEpoch}_${role.name}';

    final newUser = UserModel(
      id: newId,
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: passwordHash,
      phone: phone.trim(),
      profileImage: profileImage,
      location: location?.trim(),
      bio: bio?.trim(),
      role: role,
      createdAt: now,
      updatedAt: now,
    );

    // Save to SQLite
    await repository.saveUser(newUser);

    // Persist session
    final p = await _getPrefs();
    await p.setString(sessionKey, newUser.id);

    _currentUser = newUser.sanitize();
    return _currentUser!;
  }

  /// Authenticates an existing user and initiates a session.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter your email and password.');
    }

    final user = await repository.getUserByEmail(normalizedEmail);
    if (user == null || user.passwordHash == null) {
      throw const AuthException('Invalid email or password.');
    }

    final isValid = PasswordHasher.verifyPassword(password, user.passwordHash!);
    if (!isValid) {
      throw const AuthException('Invalid email or password.');
    }

    // Persist session
    final prefs = await _getPrefs();
    await prefs.setString(sessionKey, user.id);

    _currentUser = user.sanitize();
    return _currentUser!;
  }

  /// Updates profile information for the currently authenticated user.
  Future<UserModel> updateProfile({
    required String name,
    String? phone,
    String? location,
    String? bio,
    String? profileImage,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('No user is currently signed in.');
    }

    // Load full user with password_hash so we don't lose the hash
    final fullUser = await repository.getUserById(_currentUser!.id);
    if (fullUser == null) {
      throw const AuthException('User record not found.');
    }

    final updated = fullUser.copyWith(
      name: name.trim(),
      phone: phone?.trim(),
      location: location?.trim(),
      bio: bio?.trim(),
      profileImage: profileImage,
      updatedAt: DateTime.now(),
    );

    await repository.updateUser(updated);

    _currentUser = updated.sanitize();
    return _currentUser!;
  }

  /// Terminates active session.
  Future<void> logout() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(sessionKey);
    } catch (_) {}
    _currentUser = null;
  }
}
