import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/services/auth_service.dart';

void main() {
  group('AuthService & SQLite Integration Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;
    late AuthService authService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);
      authService = AuthService(repository: repository, prefs: prefs);
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Owner registration saves user with salted hash and persists session', () async {
      final user = await authService.register(
        name: 'Alice Cooper',
        email: 'alice@sanctuary.org',
        password: 'Password123!',
        phone: '555-1234',
        role: UserRole.petOwner,
        location: 'Austin, TX',
        bio: 'Caregiver and pet sanctuary manager.',
      );

      expect(user.id, isNotEmpty);
      expect(user.name, 'Alice Cooper');
      expect(user.email, 'alice@sanctuary.org');
      expect(user.role, UserRole.petOwner);
      expect(user.passwordHash, isNull); // Sanitized for UI
      expect(authService.isAuthenticated, true);
      expect(authService.userRole, UserRole.petOwner);

      // Verify in SQLite that password_hash is populated and NOT plaintext
      final dbUser = await repository.getUserByEmail('alice@sanctuary.org');
      expect(dbUser, isNotNull);
      expect(dbUser!.passwordHash, isNotNull);
      expect(dbUser.passwordHash, isNot(contains('Password123!')));
      expect(dbUser.location, 'Austin, TX');
    });

    test('Adopter registration saves user with petAdopter role', () async {
      final user = await authService.register(
        name: 'Bob Builder',
        email: 'bob@adopter.com',
        password: 'SecurePassword456',
        phone: '555-5678',
        role: UserRole.petAdopter,
      );

      expect(user.role, UserRole.petAdopter);
      expect(authService.userRole, UserRole.petAdopter);
    });

    test('Prevents duplicate email registration', () async {
      await authService.register(
        name: 'Charlie Brown',
        email: 'charlie@example.com',
        password: 'Password123!',
        phone: '555-9999',
        role: UserRole.petAdopter,
      );

      expect(
        () => authService.register(
          name: 'Another Charlie',
          email: 'charlie@example.com',
          password: 'DifferentPassword789',
          phone: '555-8888',
          role: UserRole.petOwner,
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('already exists'),
        )),
      );
    });

    test('Owner login with valid credentials succeeds', () async {
      await authService.register(
        name: 'Owner Dan',
        email: 'dan@petstore.com',
        password: 'OwnerPassword!789',
        phone: '555-2222',
        role: UserRole.petOwner,
      );

      await authService.logout();
      expect(authService.isAuthenticated, false);

      final loggedInUser = await authService.login(
        email: 'dan@petstore.com',
        password: 'OwnerPassword!789',
      );

      expect(loggedInUser.email, 'dan@petstore.com');
      expect(loggedInUser.role, UserRole.petOwner);
      expect(authService.isAuthenticated, true);
    });

    test('Adopter login with valid credentials succeeds', () async {
      await authService.register(
        name: 'Adopter Emma',
        email: 'emma@lovepets.org',
        password: 'EmmaPassword321!',
        phone: '555-3333',
        role: UserRole.petAdopter,
      );

      await authService.logout();

      final loggedInUser = await authService.login(
        email: 'emma@lovepets.org',
        password: 'EmmaPassword321!',
      );

      expect(loggedInUser.email, 'emma@lovepets.org');
      expect(loggedInUser.role, UserRole.petAdopter);
    });

    test('Login with incorrect password throws AuthException', () async {
      await authService.register(
        name: 'Fiona Gallagher',
        email: 'fiona@example.com',
        password: 'CorrectPassword123',
        phone: '555-4444',
        role: UserRole.petAdopter,
      );

      expect(
        () => authService.login(
          email: 'fiona@example.com',
          password: 'IncorrectPassword',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Invalid email or password'),
        )),
      );
    });

    test('Login with non-existent email throws AuthException', () async {
      expect(
        () => authService.login(
          email: 'unknown@example.com',
          password: 'SomePassword123',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Invalid email or password'),
        )),
      );
    });

    test('Logout clears session and current user', () async {
      await authService.register(
        name: 'George Weasley',
        email: 'george@example.com',
        password: 'Password123!',
        phone: '555-7777',
        role: UserRole.petOwner,
      );

      expect(authService.isAuthenticated, true);
      await authService.logout();

      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, isNull);

      final restored = await authService.restoreSession();
      expect(restored, isNull);
    });

    test('Session restoration loads user on app restart', () async {
      final user = await authService.register(
        name: 'Harry Potter',
        email: 'harry@hogwarts.org',
        password: 'MagicPassword123!',
        phone: '555-0000',
        role: UserRole.petAdopter,
      );

      // Simulate app restart by creating a new AuthService instance with same persistent storage
      final prefs = await SharedPreferences.getInstance();
      final newAuthService = AuthService(repository: repository, prefs: prefs);

      expect(newAuthService.isAuthenticated, false);
      final restored = await newAuthService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.id, user.id);
      expect(restored.name, 'Harry Potter');
      expect(newAuthService.isAuthenticated, true);
      expect(newAuthService.userRole, UserRole.petAdopter);
    });

    test('Update profile modifies SQLite record while preserving password hash', () async {
      await authService.register(
        name: 'Ian Malcolm',
        email: 'ian@jurassic.org',
        password: 'LifeFindsAWay123!',
        phone: '555-1111',
        role: UserRole.petOwner,
        location: 'Isla Nublar',
      );

      final updated = await authService.updateProfile(
        name: 'Dr. Ian Malcolm',
        phone: '555-9999',
        location: 'Austin, TX',
        bio: 'Chaos theorist and pet enthusiast.',
      );

      expect(updated.name, 'Dr. Ian Malcolm');
      expect(updated.location, 'Austin, TX');
      expect(updated.bio, contains('Chaos theorist'));

      // Confirm user can still log in with existing password
      await authService.logout();
      final reLoggedIn = await authService.login(
        email: 'ian@jurassic.org',
        password: 'LifeFindsAWay123!',
      );
      expect(reLoggedIn.name, 'Dr. Ian Malcolm');
    });
  });
}
