import 'package:sqflite_common/sqlite_api.dart';
import 'migrations/migration.dart';
import 'migrations/schema_v1.dart';
import 'migrations/schema_v2.dart';
import 'migrations/schema_v3.dart';
import 'migrations/schema_v4.dart';
import 'migrations/schema_v5.dart';
import 'migrations/schema_v6.dart';
import 'migrations/schema_v7.dart';

/// DatabaseHelper manages schema versioning, foreign keys, and migration execution.
class DatabaseHelper {
  DatabaseHelper._();

  static const int currentVersion = 7;
  static const String databaseName = 'whisker_world.db';

  /// Ordered registry of database migrations.
  static final List<Migration> _migrations = [
    SchemaV1(),
    SchemaV2(),
    SchemaV3(),
    SchemaV4(),
    SchemaV5(),
    SchemaV6(),
    SchemaV7(),
  ];

  /// Configures SQLite connections to enforce foreign keys.
  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Executed when the database is created for the first time.
  static Future<void> onCreate(Database db, int version) async {
    for (final migration in _migrations) {
      if (migration.version <= version) {
        await migration.up(db);
      }
    }
  }

  /// Executed when migrating to a higher schema version without destroying existing data.
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (final migration in _migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        await migration.up(db);
      }
    }
  }
}
