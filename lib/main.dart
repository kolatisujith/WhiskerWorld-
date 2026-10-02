import 'package:flutter/material.dart';

import 'app/app.dart';
import 'database/database_seeder.dart';
import 'database/database_service.dart';
import 'repositories/database_repository_impl.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database (Web WASM or VM/FFI)
  final dbService = DatabaseService();
  try {
    await dbService.init();
  } catch (e, st) {
    debugPrint('DatabaseService init error: $e\n$st');
  }

  final repository = DatabaseRepositoryImpl(dbService: dbService);

  // Seed demo accounts and pets if empty
  try {
    await DatabaseSeeder.seedIfEmpty(repository);
  } catch (e, st) {
    debugPrint('DatabaseSeeder error: $e\n$st');
  }

  // Initialize Authentication & Session persistence
  final authService = AuthService(repository: repository);
  try {
    await authService.restoreSession();
  } catch (e, st) {
    debugPrint('AuthService restoreSession error: $e\n$st');
  }

  runApp(WhiskerWorldApp(
    repository: repository,
    authService: authService,
  ));
}
