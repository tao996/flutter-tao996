import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:tao996/tao996.dart';

/// 自定义查询条件，将你的条件添加到 [conditions]中，将对应的值添加到 [whereArgs] 中
typedef WhereClauseBuilder =
    void Function(List<String> conditions, List<Object> whereArgs);

abstract class IDatabaseService {
  Database getDatabase();

  /// 更新数据库
  /// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md
  Future<void> migrate(Future<Database> Function(String path) createDatabase);

  Future<void> close();

  Future<void> execute(
    String sql, {
    List<Object?>? arguments,
    Transaction? txn,
  });

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, {
    List<Object?>? arguments,
    Transaction? txn,
  });

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
    Transaction? txn,
  });

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
    Transaction? txn,
  });

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
    Transaction? txn,
  });

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    Transaction? txn,
  });

  Future<int> count(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
    Transaction? txn,
  });

  Future<bool> exists(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
    Transaction? txn,
  });

  Future<int> firstRecordId(
    String tableName, {
    String? where,
    List<dynamic>? whereArgs,
    String key = 'id',
    Transaction? txn,
  });

  /// 执行一个事务，注意事务内部全部都需要传递 mt.txn 来执行，否则会导致锁
  Future<M> transaction<M>(
    Future<M> Function(ModelTransaction mt) action, {
    bool? exclusive,
  });
}

class SqfliteDatabaseService implements IDatabaseService {
  Database? _database;
  late String databasePath; // 数据库路径
  final bool printSQL;

  final IDebugService _debugService = getIDebugService();

  /// 数据库服务
  /// [databaseDir] 数据库文件所在目录，通常为 `await FilepathUtil.homeDir()`
  /// [databaseName] 数据库文件名
  SqfliteDatabaseService({
    required String databaseDir,
    String databaseName = 'main.sqlite.db',
    this.printSQL = false,
  }) {
    databasePath = path.join(databaseDir, databaseName);
    dprint('db path: $databasePath');
  }

  @override
  Database getDatabase() {
    if (_database == null) {
      throw Exception('database is not open');
    }
    return _database!;
  }

  /// 使用注意：在手机上禁止将全部语句合并成一条
  /// ```
  /// // 模型数据服务
  ///   final db = SqfliteDatabaseService(
  ///     printSQL: kDebugMode,
  ///     databaseDir: mainDIR,
  ///     databaseName: AppStorageKeys.databaseFileName,
  ///   );
  ///   locator.registerSingleton<SqfliteDatabaseService>(db);
  ///   locator.registerSingleton<IDatabaseService>(db);
  ///   try {
  ///     await DbSQL.execute(db);
  ///   } catch (e, st) {
  ///     getIDebugService().exception(e, st);
  ///     rethrow;
  ///   }
  /// // 建表语句
  /// class DbSQL {
  ///   static Future<void> execute(SqfliteDatabaseService db) async {
  ///     /// 在手机上禁止将全部语句合并成一条
  ///     void version1(Batch batch) {
  ///       batch.execute('');
  ///     }
  ///
  ///     await db.migrate((path) async {
  ///       return await openDatabase(
  ///         path,
  ///         version: 1,
  ///         onCreate: (db, version) async {
  ///           var batch = db.batch();
  ///           version1(batch);
  ///           await batch.commit();
  ///         },
  ///         onUpgrade: (db, oldVersion, newVersion) async {
  ///           var batch = db.batch();
  ///           await batch.commit();
  ///         },
  ///       );
  ///     });
  ///   }
  /// }
  /// ```
  @override
  Future<void> migrate(
    Future<Database> Function(String path) createDatabase,
  ) async {
    _database = await createDatabase(databasePath);
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
    List<Object?>? whereArgs,
    Transaction? txn,
  }) async {
    final sql =
        'SELECT COUNT(*) AS C FROM $tableName${where != null ? ' WHERE $where' : ''}';
    if (printSQL) {
      _debugService.d(
        sql,
        args: whereArgs == null ? null : {'args': whereArgs},
      );
    }
    final List<Map<String, dynamic>> result = await rawQuery(
      sql,
      arguments: whereArgs,
      txn: txn,
    );
    return result.first['C'] as int? ?? 0;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    Transaction? txn,
  }) async {
    return txn == null
        ? await _database!.delete(table, where: where, whereArgs: whereArgs)
        : await txn.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(
    String sql, {
    List<Object?>? arguments,
    Transaction? txn,
  }) async {
    txn == null
        ? await _database!.execute(sql, arguments)
        : await txn.execute(sql, arguments);
  }

  @override
  Future<bool> exists(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
    Transaction? txn,
  }) async {
    final List<Map<String, dynamic>> result = await query(
      tableName,
      limit: 1,
      where: where,
      whereArgs: whereArgs,
      txn: txn,
    );
    return result.isNotEmpty;
  }

  @override
  Future<int> firstRecordId(
    String tableName, {
    String? where,
    List<dynamic>? whereArgs,
    String key = 'id',
    Transaction? txn,
  }) async {
    final List<Map<String, dynamic>> result = await query(
      tableName,
      columns: [key],
      where: where,
      whereArgs: whereArgs,
      limit: 1,
      txn: txn,
    );
    return result.first[key] as int? ?? 0;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
    Transaction? txn,
  }) async {
    return txn == null
        ? await _database!.insert(
            table,
            values,
            conflictAlgorithm: conflictAlgorithm,
          )
        : await txn.insert(table, values, conflictAlgorithm: conflictAlgorithm);
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
    Transaction? txn,
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
    return txn == null
        ? await _database!.query(
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
          )
        : await txn.query(
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
    String sql, {
    List<Object?>? arguments,
    Transaction? txn,
  }) async {
    return txn == null
        ? await _database!.rawQuery(sql, arguments)
        : await txn.rawQuery(sql, arguments);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
    Transaction? txn,
  }) async {
    return txn == null
        ? await _database!.update(
            table,
            values,
            where: where,
            whereArgs: whereArgs,
            conflictAlgorithm: conflictAlgorithm,
          )
        : await txn.update(
            table,
            values,
            where: where,
            whereArgs: whereArgs,
            conflictAlgorithm: conflictAlgorithm,
          );
  }

  /// 执行一个事务
  @override
  Future<M> transaction<M>(
    Future<M> Function(ModelTransaction mt) action, {
    bool? exclusive,
  }) async {
    try {
      final db = getDatabase();
      return await db.transaction<M>((txn) async {
        return action(ModelTransaction(txn));
      }, exclusive: exclusive);
    } catch (e, st) {
      getIDebugService().exception(e, st);
      rethrow;
    }
  }
}

class ModelTransaction {
  final Transaction _txn;

  Transaction get txn => _txn;

  ModelTransaction(Transaction txn) : _txn = txn;
}
