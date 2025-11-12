import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vision_capture.dart';

/// Servicio de base de datos local para almacenar capturas con sqflite
///
/// Implementa patrón Singleton para garantizar una única instancia de DB.
/// Maneja operaciones CRUD completas para VisionCapture.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  /// Versión actual de la base de datos (para migrations futuras)
  static const int _databaseVersion = 1;

  /// Nombre del archivo de base de datos
  static const String _databaseName = 'crazytrip.db';

  /// Nombre de la tabla de capturas
  static const String _capturesTable = 'captures';

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// Obtiene la instancia de la base de datos
  /// Inicializa si es necesario
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);

      debugPrint('📦 Initializing database at: $path');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Crea las tablas al inicializar por primera vez
  Future<void> _onCreate(Database db, int version) async {
    try {
      debugPrint('🏗️ Creating database tables...');

      await db.execute('''
        CREATE TABLE $_capturesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vision_result TEXT NOT NULL,
          image_path TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          location TEXT,
          location_info TEXT,
          orientation TEXT,
          is_synced INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Índices para mejorar performance de queries
      await db.execute('''
        CREATE INDEX idx_timestamp ON $_capturesTable(timestamp DESC)
      ''');

      await db.execute('''
        CREATE INDEX idx_is_synced ON $_capturesTable(is_synced)
      ''');

      debugPrint('✅ Database tables created successfully');
    } catch (e) {
      debugPrint('❌ Error creating tables: $e');
      rethrow;
    }
  }

  /// Maneja upgrades de versión de base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from v$oldVersion to v$newVersion');

    // Aquí se agregarán migrations futuras
    // Ejemplo:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE captures ADD COLUMN new_field TEXT');
    // }
  }

  /// Inserta una nueva captura en la base de datos
  ///
  /// Returns: ID de la captura insertada
  Future<int> insertCapture(VisionCapture capture) async {
    try {
      final db = await database;
      final id = await db.insert(
        _capturesTable,
        capture.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('💾 Capture saved with ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ Error inserting capture: $e');
      rethrow;
    }
  }

  /// Obtiene todas las capturas ordenadas por timestamp (más recientes primero)
  ///
  /// [limit] - Número máximo de resultados (null = sin límite)
  /// [offset] - Número de resultados a saltar (para paginación)
  Future<List<VisionCapture>> getAllCaptures({int? limit, int? offset}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _capturesTable,
        orderBy: 'timestamp DESC',
        limit: limit,
        offset: offset,
      );

      debugPrint('📖 Retrieved ${maps.length} captures from database');

      return maps.map((map) => VisionCapture.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting all captures: $e');
      rethrow;
    }
  }

  /// Obtiene capturas filtradas por categoría
  ///
  /// [category] - Categoría a filtrar (LANDMARK, NATURE, WILDLIFE, etc.)
  Future<List<VisionCapture>> getCapturesByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _capturesTable,
        orderBy: 'timestamp DESC',
      );

      // Filtrar por categoría parseando el JSON de vision_result
      final captures = maps.map((map) => VisionCapture.fromMap(map)).toList();
      final filtered =
          captures.where((capture) => capture.category == category).toList();

      debugPrint(
        '📖 Retrieved ${filtered.length} captures for category: $category',
      );

      return filtered;
    } catch (e) {
      debugPrint('❌ Error getting captures by category: $e');
      rethrow;
    }
  }

  /// Obtiene una captura específica por ID
  Future<VisionCapture?> getCaptureById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _capturesTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        debugPrint('⚠️ No capture found with ID: $id');
        return null;
      }

      return VisionCapture.fromMap(maps.first);
    } catch (e) {
      debugPrint('❌ Error getting capture by ID: $e');
      rethrow;
    }
  }

  /// Actualiza una captura existente
  ///
  /// Returns: número de filas afectadas (1 si exitoso)
  Future<int> updateCapture(VisionCapture capture) async {
    try {
      if (capture.id == null) {
        throw ArgumentError('Cannot update capture without ID');
      }

      final db = await database;
      final count = await db.update(
        _capturesTable,
        capture.toMap(),
        where: 'id = ?',
        whereArgs: [capture.id],
      );

      debugPrint('🔄 Updated $count capture(s) with ID: ${capture.id}');
      return count;
    } catch (e) {
      debugPrint('❌ Error updating capture: $e');
      rethrow;
    }
  }

  /// Elimina una captura por ID
  ///
  /// Returns: número de filas eliminadas (1 si exitoso)
  Future<int> deleteCapture(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        _capturesTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      debugPrint('🗑️ Deleted $count capture(s) with ID: $id');
      return count;
    } catch (e) {
      debugPrint('❌ Error deleting capture: $e');
      rethrow;
    }
  }

  /// Obtiene el conteo total de capturas
  Future<int> getCaptureCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_capturesTable',
      );
      final count = result.first['count'] as int;

      debugPrint('📊 Total captures: $count');
      return count;
    } catch (e) {
      debugPrint('❌ Error getting capture count: $e');
      rethrow;
    }
  }

  /// Obtiene el conteo de capturas por categoría
  Future<Map<String, int>> getCaptureCountByCategory() async {
    try {
      final captures = await getAllCaptures();
      final Map<String, int> counts = {};

      for (final capture in captures) {
        counts[capture.category] = (counts[capture.category] ?? 0) + 1;
      }

      debugPrint('📊 Captures by category: $counts');
      return counts;
    } catch (e) {
      debugPrint('❌ Error getting category counts: $e');
      rethrow;
    }
  }

  /// Marca una captura como sincronizada (para uso futuro con backend)
  Future<int> markAsSynced(int id) async {
    try {
      final capture = await getCaptureById(id);
      if (capture == null) {
        throw ArgumentError('Capture with ID $id not found');
      }

      return await updateCapture(capture.copyWith(isSynced: true));
    } catch (e) {
      debugPrint('❌ Error marking capture as synced: $e');
      rethrow;
    }
  }

  /// Obtiene capturas no sincronizadas (para uso futuro con backend)
  Future<List<VisionCapture>> getUnsyncedCaptures() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _capturesTable,
        where: 'is_synced = ?',
        whereArgs: [0],
        orderBy: 'timestamp DESC',
      );

      debugPrint('📤 Found ${maps.length} unsynced captures');

      return maps.map((map) => VisionCapture.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Error getting unsynced captures: $e');
      rethrow;
    }
  }

  /// Elimina todas las capturas (usar con precaución)
  Future<int> deleteAllCaptures() async {
    try {
      final db = await database;
      final count = await db.delete(_capturesTable);

      debugPrint('🗑️ Deleted all $count captures');
      return count;
    } catch (e) {
      debugPrint('❌ Error deleting all captures: $e');
      rethrow;
    }
  }

  /// Cierra la conexión de base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('🔒 Database closed');
  }
}
