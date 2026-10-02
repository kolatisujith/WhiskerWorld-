import 'package:sqflite_common/sqlite_api.dart';

/// Base contract for all database schema migrations.
abstract class Migration {
  /// The target schema version this migration advances to.
  int get version;

  /// Executes migration statements.
  Future<void> up(Database db);

  /// Reverts migration statements if supported.
  Future<void> down(Database db);
}
