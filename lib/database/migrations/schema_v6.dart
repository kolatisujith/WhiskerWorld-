import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Database Version 6: Geographic coordinates (latitude & longitude) for Pet Stores,
/// Users (Pet Owners/Adopters), and Pets to support interactive mapping.
class SchemaV6 implements Migration {
  @override
  int get version => 6;

  @override
  Future<void> up(Database db) async {
    // 1. Add coordinates to pet_stores table
    await db.execute('ALTER TABLE pet_stores ADD COLUMN latitude REAL;');
    await db.execute('ALTER TABLE pet_stores ADD COLUMN longitude REAL;');

    // 2. Add coordinates to users table
    await db.execute('ALTER TABLE users ADD COLUMN latitude REAL;');
    await db.execute('ALTER TABLE users ADD COLUMN longitude REAL;');

    // 3. Add coordinates to pets table
    await db.execute('ALTER TABLE pets ADD COLUMN latitude REAL;');
    await db.execute('ALTER TABLE pets ADD COLUMN longitude REAL;');
  }

  @override
  Future<void> down(Database db) async {
    // SQLite doesn't natively drop columns cleanly across all versions without table recreation.
  }
}
