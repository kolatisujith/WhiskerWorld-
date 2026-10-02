import 'package:sqflite_common/sqlite_api.dart';
import 'migration.dart';

/// Database Version 1: Initial Whisker World Schema
class SchemaV1 implements Migration {
  @override
  int get version => 1;

  @override
  Future<void> up(Database db) async {
    // 1. Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        role TEXT NOT NULL,
        avatar_url TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // 2. Pet Stores table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pet_stores (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        website TEXT,
        logo_url TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // 3. Pets table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        animal_type TEXT NOT NULL,
        breed TEXT NOT NULL,
        age_value INTEGER NOT NULL,
        age_unit TEXT NOT NULL,
        life_stage TEXT NOT NULL,
        gender TEXT NOT NULL,
        size TEXT,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        availability_status TEXT NOT NULL,
        owner_id TEXT,
        store_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (store_id) REFERENCES pet_stores(id) ON DELETE SET NULL
      );
    ''');

    // 4. Pet Images table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pet_images (
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
      );
    ''');

    // 5. Adoption Requests table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS adoption_requests (
        id TEXT PRIMARY KEY,
        pet_id TEXT NOT NULL,
        adopter_id TEXT NOT NULL,
        owner_id TEXT,
        store_id TEXT,
        status TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
        FOREIGN KEY (adopter_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (store_id) REFERENCES pet_stores(id) ON DELETE SET NULL
      );
    ''');

    // 6. Favorites table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, pet_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
      );
    ''');

    // Indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON pets(owner_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_store_id ON pets(store_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_animal_type ON pets(animal_type);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_breed ON pets(breed);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_location ON pets(location);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pets_availability_status ON pets(availability_status);',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_adoption_requests_adopter_id ON adoption_requests(adopter_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_adoption_requests_owner_id ON adoption_requests(owner_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_adoption_requests_pet_id ON adoption_requests(pet_id);',
    );
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('DROP INDEX IF EXISTS idx_adoption_requests_pet_id;');
    await db.execute('DROP INDEX IF EXISTS idx_adoption_requests_owner_id;');
    await db.execute('DROP INDEX IF EXISTS idx_adoption_requests_adopter_id;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_availability_status;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_location;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_breed;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_animal_type;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_store_id;');
    await db.execute('DROP INDEX IF EXISTS idx_pets_owner_id;');

    await db.execute('DROP TABLE IF EXISTS favorites;');
    await db.execute('DROP TABLE IF EXISTS adoption_requests;');
    await db.execute('DROP TABLE IF EXISTS pet_images;');
    await db.execute('DROP TABLE IF EXISTS pets;');
    await db.execute('DROP TABLE IF EXISTS pet_stores;');
    await db.execute('DROP TABLE IF EXISTS users;');
  }
}
