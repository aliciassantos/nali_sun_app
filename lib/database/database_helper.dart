// Conexão, criação de tabelas e migrations

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper _instance =
      DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    late String databasePath;

    if (kIsWeb) {
      // Web: SQLite executado no navegador.
      databaseFactory = databaseFactoryFfiWeb;
      databasePath = 'nalisun.db';
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Desktop: SQLite via FFI.
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final directory = await getDatabasesPath();
      databasePath = p.join(directory, 'nalisun.db');
    } else {
      // Android e iOS: SQLite nativo.
      final directory = await getDatabasesPath();
      databasePath = p.join(directory, 'nalisun.db');
    }

    return databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE UNIQUE,
        password TEXT NOT NULL,
        avatar_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }
}

