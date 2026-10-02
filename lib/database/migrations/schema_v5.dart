import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Whisker World Schema Migration V5: Adoption Requests Fields & Favorites Indexes
class SchemaV5 implements Migration {
  @override
  int get version => 5;

  @override
  Future<void> up(Database db) async {
    // 1. Add application fields to adoption_requests
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN reason_for_adoption TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN pet_experience TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN living_environment TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN other_pets TEXT;');
    await db.execute('ALTER TABLE adoption_requests ADD COLUMN contact_preference TEXT;');

    // 2. Add performance indexes for adoption status and favorites
    await db.execute('CREATE INDEX IF NOT EXISTS idx_adoption_requests_status ON adoption_requests(status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_favorites_pet_id ON favorites(pet_id);');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_adoption_requests_status;');
    await db.execute('DROP INDEX IF EXISTS idx_favorites_user_id;');
    await db.execute('DROP INDEX IF EXISTS idx_favorites_pet_id;');
  }
}
