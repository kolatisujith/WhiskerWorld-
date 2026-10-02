import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Database Version 3: Extended Pet attributes, young animal metadata,
/// adoption fee, health statuses, and initial seed companion data.
class SchemaV3 implements Migration {
  @override
  int get version => 3;

  @override
  Future<void> up(Database db) async {
    // 1. Alter pets table to include Phase 3 & 4 fields
    await db.execute('ALTER TABLE pets ADD COLUMN young_animal_name TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN personality TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN color TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN weight REAL;');
    await db.execute('ALTER TABLE pets ADD COLUMN health_information TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN vaccination_status TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN deworming_status TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN veterinary_check TEXT;');
    await db.execute('ALTER TABLE pets ADD COLUMN is_neutered INTEGER NOT NULL DEFAULT 0;');
    await db.execute('ALTER TABLE pets ADD COLUMN adoption_fee REAL NOT NULL DEFAULT 0.0;');
    await db.execute('ALTER TABLE pets ADD COLUMN updated_at TEXT;');

    // 2. Index for young animal searches
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_young_animal_name ON pets(young_animal_name);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_adoption_fee ON pets(adoption_fee);',
    );
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_pets_adoption_fee;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_young_animal_name;');
  }
}
