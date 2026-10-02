import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'database_helper.dart';

/// DatabaseService encapsulates SQLite initialization, connection lifecycle,
/// and low-level execution for Flutter Web (via WASM), Mobile (Android/iOS), and Desktop/VM/Test.
class DatabaseService {
  Database? _db;
  bool _isInitialized = false;

  /// Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Whether the database has been initialized.
  bool get isInitialized => _isInitialized && _db != null && _db!.isOpen;

  /// Underlying SQLite database handle.
  Database get database {
    if (_db == null || !_db!.isOpen) {
      throw StateError('DatabaseService has not been initialized. Call init() first.');
    }
    return _db!;
  }

  static bool _ffiInitialized = false;

  /// Initializes the SQLite engine and opens the database.
  /// Automatically selects Web WASM, native mobile, or FFI factory depending on environment.
  Future<void> init({String? dbName, bool inMemory = false}) async {
    if (_db != null && _db!.isOpen) {
      return;
    }

    if (kIsWeb) {
      // Flutter Web: Use WASM SQLite factory without web worker dependency
      if (!_ffiInitialized) {
        databaseFactory = databaseFactoryFfiWebNoWebWorker;
        _ffiInitialized = true;
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use standard native sqflite database factory
      databaseFactory = sqflite.databaseFactory;
    } else {
      // Desktop / VM / Unit tests
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }

    final String path;
    if (inMemory) {
      path = inMemoryDatabasePath;
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final databasesPath = await sqflite.getDatabasesPath();
      path = p.join(databasesPath, dbName ?? DatabaseHelper.databaseName);
    } else {
      path = dbName ?? DatabaseHelper.databaseName;
    }

    try {
      _db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: DatabaseHelper.currentVersion,
          onConfigure: DatabaseHelper.onConfigure,
          onCreate: DatabaseHelper.onCreate,
          onUpgrade: DatabaseHelper.onUpgrade,
        ),
      );
      _isInitialized = true;
    } catch (e, st) {
      debugPrint('Error opening database ($path): $e\n$st');
      // If Web fails to open persistent IndexedDB, fallback gracefully to in-memory
      if (kIsWeb && !inMemory) {
        try {
          _db = await databaseFactory.openDatabase(
            inMemoryDatabasePath,
            options: OpenDatabaseOptions(
              version: DatabaseHelper.currentVersion,
              onCreate: DatabaseHelper.onCreate,
            ),
          );
          _isInitialized = true;
          debugPrint('Successfully initialized in-memory database fallback on web.');
        } catch (fallbackError) {
          debugPrint('In-memory database fallback failed: $fallbackError');
        }
      }
    }
  }

  /// Executes an operation within a database transaction.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return database.transaction(action);
  }

  /// Parameterized insert.
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return database.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
  }

  /// Parameterized query.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Parameterized raw query.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return database.rawQuery(sql, arguments);
  }

  /// Parameterized update.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Parameterized delete.
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return database.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Fetches row counts across all core tables for status checks.
  Future<Map<String, int>> getTableCounts() async {
    final tables = [
      'users',
      'pet_stores',
      'pets',
      'pet_images',
      'adoption_requests',
      'favorites',
    ];
    final Map<String, int> counts = {};

    for (final table in tables) {
      final res = await rawQuery('SELECT COUNT(*) as count FROM $table;');
      final count = (res.isNotEmpty && res.first['count'] != null)
          ? (res.first['count'] as num).toInt()
          : 0;
      counts[table] = count;
    }
    return counts;
  }

  /// Closes the database.
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      _isInitialized = false;
    }
  }
}
