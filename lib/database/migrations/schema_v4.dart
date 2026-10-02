import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Database Version 4: Extended Pet Store attributes, store ownership,
/// cover images, operating hours, active status, and store pet indexes.
class SchemaV4 implements Migration {
  @override
  int get version => 4;

  @override
  Future<void> up(Database db) async {
    // 1. Alter pet_stores table to include store management fields
    await db.execute('ALTER TABLE pet_stores ADD COLUMN owner_id TEXT;');
    await db.execute('ALTER TABLE pet_stores ADD COLUMN cover_image_url TEXT;');
    await db.execute('ALTER TABLE pet_stores ADD COLUMN country TEXT DEFAULT "United States";');
    await db.execute('ALTER TABLE pet_stores ADD COLUMN opening_hours TEXT;');
    await db.execute('ALTER TABLE pet_stores ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;');
    await db.execute('ALTER TABLE pet_stores ADD COLUMN updated_at TEXT;');

    // 2. Indexes for store ownership and active status
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pet_stores_owner_id ON pet_stores(owner_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pet_stores_is_active ON pet_stores(is_active);',
    );
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_pet_stores_is_active;');
    await db.execute('DROP INDEX IF EXISTS idx_pet_stores_owner_id;');
  }
}
