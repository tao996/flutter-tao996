import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../tao996.dart';

typedef WhereClauseBuilder =
    void Function(List<String> conditions, List<Object> whereArgs);

abstract class IDatabaseService {
  Database getDatabase();

  /// 更新数据库
  /// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md
  Future<void> migrate(Future<Database> Function(String path) createDatabase);

  Future<void> close();

  Future<void> execute(String sql, [List<Object?>? arguments]);

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

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
  });

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  Future<int> count(
    String tableName, {
    String? where,
    List<Object?>? arguments,
  });

  Future<bool> exists(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<int> firstRecordId(
    String tableName, {
    String? where,
    List<dynamic> whereArgs,
    String key = 'id',
  });
}

class SqfliteDatabaseService implements IDatabaseService {
  Database? _database;
  String databasePath; // 数据库路径

  final String databaseName;
  final bool printSQL;

  final IDebugService _debugService = getIDebugService();

  SqfliteDatabaseService({
    this.databaseName = 'main.sqlite.db',
    this.databasePath = '',
    this.printSQL = false,
  });

  Future<String> _getDatabasesPath() async {
    // 存在同名函数 getDatabasesPath()
    if (databasePath.isEmpty) {
      final Directory documentsDirectory =
          await getApplicationDocumentsDirectory();
      databasePath = path.join(documentsDirectory.path, databaseName);
    }
    _debugService.d('[SQLite]: database path: $databasePath.');
    return databasePath;
  }

  @override
  Database getDatabase() => _database!;

  @override
  Future<void> migrate(
    Future<Database> Function(String path) createDatabase,
  ) async {
    _database = await createDatabase(await _getDatabasesPath());
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  @override
  Future<int> count(
    String tableName, {
    String? where,
    List<Object?>? arguments,
  }) async {
    final sql =
        'SELECT COUNT(*) AS C FROM $tableName${where != null ? ' WHERE $where' : ''}';
    if (printSQL) {
      _debugService.d(
        sql,
        args: arguments == null ? null : {'args': arguments},
      );
    }
    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      sql,
      arguments,
    );
    return result.first['C'] as int? ?? 0;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _database!.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    await _database!.execute(sql, arguments);
  }

  @override
  Future<bool> exists(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final List<Map<String, dynamic>> result = await _database!.query(
      tableName,
      limit: 1,
      where: where,
      whereArgs: whereArgs,
    );
    return result.isNotEmpty;
  }

  @override
  Future<int> firstRecordId(
    String tableName, {
    String? where,
    List<dynamic>? whereArgs,
    String key = 'id',
  }) async {
    final List<Map<String, dynamic>> result = await _database!.query(
      tableName,
      columns: [key],
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return result.first[key] as int? ?? 0;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _database!.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
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
    if (printSQL) {
      final whereSql = where != null ? 'WHERE $where' : '';
      var sql = columns != null
          ? 'SELECT ${columns.join(', ')} FROM $table $whereSql  ORDER BY $orderBy LIMIT $limit'
          : 'SELECT * FROM $table $whereSql ORDER BY $orderBy LIMIT $limit';
      if (offset != null) {
        sql = '$sql OFFSET $offset';
      }
      _debugService.d(
        sql,
        args: whereArgs == null ? null : {'args': whereArgs},
      );
    }
    return await _database!.query(
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

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    return await _database!.rawQuery(sql, arguments);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _database!.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }
}
