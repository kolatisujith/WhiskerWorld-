import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Database Version 2: Extended User authentication and profile fields
class SchemaV2 implements Migration {
  @override
  int get version => 2;

  @override
  Future<void> up(Database db) async {
    // Add authentication and profile fields to users table
    await db.execute('ALTER TABLE users ADD COLUMN password_hash TEXT;');
    await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT;');
    await db.execute('ALTER TABLE users ADD COLUMN location TEXT;');
    await db.execute('ALTER TABLE users ADD COLUMN bio TEXT;');
    await db.execute('ALTER TABLE users ADD COLUMN updated_at TEXT;');
  }

  @override
  Future<void> down(Database db) async {
    // Schema downgrades are handled via backup or recreation if needed
  }
}
