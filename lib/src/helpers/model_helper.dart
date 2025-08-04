import 'package:get/get.dart';

import '../../tao996.dart';

abstract class IModelHelper<T> {
  /// 初始化数据源。
  /// 对于有缓存的实现，这可能包括从数据库加载初始数据。
  /// [language] 系统语言
  Future<void> init(String language);

  /// 查询全部的记录
  Future<List<T>> getAll();

  /// 根据指定字段和值查询单条记录。
  /// 如果存在多条匹配记录，返回第一条。
  Future<T?> getBy({required String fieldName, required dynamic value});

  /// 根据 [id] 查询记录
  Future<T?> getById(int id);

  /// 保存或更新记录。
  /// 如果实体存在主键，则更新；否则插入新记录。
  /// [values] 可选，如果只更新部分字段，可以传入要更新的键值对。
  /// 返回保存操作是否成功。
  Future<bool> save(
    T entity, {
    Map<String, Object?>? values,
    String primaryName = 'id',
  });

  /// 根据指定字段和值删除记录。
  /// 返回删除操作是否成功。
  Future<bool> deleteBy({required String fieldName, required dynamic value});

  /// 根据主键 ID 删除记录。
  /// 返回删除操作是否成功。
  Future<bool> deleteById(int id);

  /// 检查记录是否存在
  Future<bool> exists(dynamic value, {required String fieldName});

  /// 获取记录总数。
  Future<int> count();

  /// 获取分页数据。
  Future<List<T>> getPagedData({
    required int pageSize,
    WhereClauseBuilder? clauseBuilder, // 用于构建 WHERE 子句的函数
    List<String>? columns,
    String? orderBy,
    int? offset,
  });

  /// 执行自定义 SQL 查询并返回 Map 列表。
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  /// 根据字段查询多条记录
  Future<List<T>> findManyBy({
    required String fieldName,
    required dynamic value,
    List<String>? columns,
  });
}

/// 模型服务
abstract class ModelHelper<T> implements IModelHelper<T> {
  final IDatabaseService _dbService = getIDatabaseService();
  final IDebugService _debugService = getIDebugService();

  final String tableName;
  final bool useCache;

  /// 缓存全部的记录，通常用于小表使用
  /// 使用 `RxList` (如果使用 GetX) 或其他响应式列表，方便 UI 自动刷新
  /// 如果不使用响应式框架，普通 List 即可
  List<T> _cache = [];

  /// 提供对缓存的只读访问
  List<T> get cache => List.unmodifiable(_cache);

  /// 构造函数。
  /// [tableName] 数据库表名。
  /// [useCache] 是否启用内存缓存。
  ModelHelper(this.tableName, {this.useCache = false});

  /// 将 Map 数据转换为实体对象 [T]。
  T fromMap(Map<String, dynamic> map);

  /// 将实体对象 [T] 转换为 Map&lt;String, dynamic>。
  Map<String, dynamic> toMap(T entity);

  /// 检查实体对象是否拥有有效的主键 ID。
  /// 通常用于判断是插入 (ID 为空/0) 还是更新 (ID 非空/非0)。
  bool hasId(T entity);

  /// 更新实体对象的主键 ID。
  /// 在插入新记录后，数据库通常会返回新生成的 ID，需要更新到实体对象中。
  T updateId(T entity, dynamic id);

  /// 用于获取实体的特定字段值，通常用于检查实体是否已存在
  dynamic getByFieldValue(T entity, String fieldName);

  // --- IModelHelper 接口的实现 ---
  @override
  Future<void> init(String language) async {
    _debugService.d('[ModelHelper]: Initializing $tableName...');
    if (useCache) {
      await loadAllFromDb();
      _debugService.d(
        '[ModelHelper]: $tableName cache loaded with ${_cache.length} items.',
      );
    }
  }

  @override
  /// 获取全部的记录（可能使用缓存）
  Future<List<T>> getAll() async {
    if (this.useCache) {
      return _cache.isNotEmpty ? Future.value(_cache) : await loadAllFromDb();
    } else {
      return await loadAllFromDb();
    }
  }

  /// 从数据库中查询全部的记录并更新缓存。
  Future<List<T>> loadAllFromDb() async {
    try {
      final List<Map<String, dynamic>> maps = await _dbService.query(tableName);
      final rows = maps.map((map) => fromMap(map)).toList();
      if (useCache) {
        _cache = rows; // 直接赋值以更新缓存
      }
      return rows;
    } catch (e, st) {
      _debugService.exception(e, st, errorMessage: '加载表 $tableName 失败！');
      return []; // 加载失败返回空列表
    }
  }

  @override
  Future<T?> getBy({required String fieldName, required dynamic value}) async {
    if (useCache) {
      return _cache.firstWhereOrNull(
        (element) => getByFieldValue(element, fieldName) == value,
      );
    } else {
      try {
        final maps = await _dbService.query(
          tableName,
          where: '$fieldName = ?',
          whereArgs: [value],
          limit: 1, // 只查询一条
        );
        return maps.isNotEmpty ? fromMap(maps.first) : null;
      } catch (e, st) {
        _debugService.exception(
          e,
          st,
          errorMessage:
              'Failed to get record by $fieldName=$value from $tableName',
        );
        return null;
      }
    }
  }

  @override
  Future<T?> getById(int id) async {
    return await getBy(fieldName: 'id', value: id);
  }

  @override
  Future<bool> save(
    T entity, {
    Map<String, Object?>? values,
    String primaryName = 'id',
  }) async {
    try {
      if (hasId(entity)) {
        // 更新记录
        final primaryValue = getByFieldValue(entity, primaryName);
        final updatedRows = await _dbService.update(
          tableName,
          values ?? toMap(entity),
          where: '$primaryName = ?',
          whereArgs: [primaryValue],
        );
        if (updatedRows > 0) {
          if (useCache) {
            final index = _cache.indexWhere(
              (element) =>
                  getByFieldValue(element, primaryName) ==
                  getByFieldValue(entity, primaryName),
            );
            if (index != -1) {
              _cache[index] = entity;
            } else {
              // 如果缓存中没有，可能是因为缓存尚未完全加载或实体是新加载的，考虑重新加载缓存
              _debugService.d(
                '[ModelHelper]: Updated entity not found in cache. Consider reloading cache for $tableName.',
              );
              await loadAllFromDb(); // 确保缓存最新
            }
          }
          _debugService.d(
            '[ModelHelper]: Updated record in $tableName with $primaryName: $primaryValue',
          );
          return true;
        } else {
          _debugService.d(
            '[ModelHelper]: Updated record in $tableName with $primaryName: $primaryValue failed, not any row updated',
          );
          return false;
        }
      } else {
        // 添加新的记录
        final newId = await _dbService.insert(
          tableName,
          toMap(entity)..remove(primaryName),
        );
        if (newId > 0) {
          final updatedEntity = updateId(entity, newId); // 更新实体对象的 ID
          if (useCache) {
            _cache.add(updatedEntity); // 添加到缓存
          }
          _debugService.d(
            '[ModelHelper]: Inserted new record into $tableName with new ID: $newId',
          );
          return true;
        } else {
          _debugService.d(
            '[ModelHelper]: Failed to insert new record into $tableName.',
          );
          return false;
        }
      }
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to save record in $tableName: $e',
      );
      return false;
    }
  }

  @override
  Future<bool> deleteBy({
    required String fieldName,
    required dynamic value,
  }) async {
    try {
      final count = await _dbService.delete(
        tableName,
        where: '$fieldName = ?',
        whereArgs: [value],
      );
      if (count > 0) {
        if (useCache) {
          _cache.removeWhere(
            (element) => getByFieldValue(element, fieldName) == value,
          );
          _debugService.d(
            '[ModelHelper]: Removed $count records from cache for $tableName.',
          );
        }
        _debugService.d(
          '[ModelHelper]: Deleted $count records from $tableName where $fieldName = $value.',
        );
        return true;
      } else {
        _debugService.d(
          '[ModelHelper]: No records deleted from $tableName where $fieldName = $value.',
        );
        return false;
      }
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage:
            'Failed to delete record by $fieldName=$value from $tableName',
      );
      return false;
    }
  }

  @override
  Future<bool> deleteById(int id) async {
    return await deleteBy(fieldName: 'id', value: id);
  }

  @override
  Future<bool> exists(dynamic value, {required String fieldName}) async {
    if (useCache) {
      return _cache.any((element) {
        final elementValue = getByFieldValue(element, fieldName);
        // 注意：这里需要考虑 value 的类型，以及 elementValue 是否可空
        return elementValue == value;
      });
    } else {
      try {
        return await _dbService.exists(
          tableName,
          where: '$fieldName = ?',
          whereArgs: [value],
        );
      } catch (e, st) {
        _debugService.exception(
          e,
          st,
          errorMessage:
              'Failed to check existence of record in $tableName for $fieldName=$value',
        );
        return false;
      }
    }
  }

  @override
  Future<int> count({String? where, List<Object?>? arguments}) async {
    if (useCache) {
      return _cache.length;
    }
    try {
      return await _dbService.count(
        tableName,
        where: where,
        arguments: arguments,
      );
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to get count for $tableName',
      );
      return 0;
    }
  }

  /// 通用的分页查询方法，基于自增主键ID
  ///
  /// [pageSize]: 每页的记录数。
  /// [lastItemId]: 上一页的最后一条记录的ID。如果是第一次加载或下拉刷新，传入 null。
  /// [orderByColumn]: 用于排序的列名，通常是 'id'。
  /// [isAscending]: 排序方向，true 为升序（加载更多），false 为降序（下拉刷新）。
  ///
  /// 返回一个 Map 列表，其中包含查询到的记录。
  @override
  Future<List<T>> getPagedData({
    required int pageSize,
    WhereClauseBuilder? clauseBuilder,
    List<String>? columns,
    String? orderBy,
    int? offset,
  }) async {
    try {
      final List<String> conditions = [];
      final List<Object> whereArgs = [];
      if (clauseBuilder != null) {
        clauseBuilder(conditions, whereArgs);
      }
      final result = await _dbService.query(
        tableName,
        columns: columns,
        where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: pageSize,
        offset: offset,
      );
      return result.map((map) => fromMap(map)).toList();
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to get paged data for $tableName',
      );
      return [];
    }
  }

  @override
  Future<List<T>> findManyBy({
    required String fieldName,
    required dynamic value,
    List<String>? columns,
  }) async {
    try {
      final result = await _dbService.query(
        tableName,
        columns: columns,
        where: '$fieldName = ?',
        whereArgs: [value],
      );
      return result.map((map) => fromMap(map)).toList();
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to findManyBy data for $tableName',
      );
      return [];
    }
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    try {
      await _dbService.execute(sql, arguments);
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to execute SQL for $tableName',
        args: {'sql': sql, 'arguments': arguments},
      );
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      return await _dbService.rawQuery(sql, arguments);
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to execute raw query for $tableName',
        args: {'sql': sql, 'arguments': arguments},
      );
      rethrow; // 重新抛出以便上层处理
    }
  }

  Future<List<Map<String, dynamic>>> query({
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
    return await _dbService.query(
      tableName,
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

  /// 添加记录并返回 ID，你可能需要从 values 中移除  id 列，如 post.toMap()..remove('id')
  Future<int> insert(Map<String, Object?> values) async {
    try {
      return await _dbService.insert(tableName, values);
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to insert record into $tableName',
        args: values,
      );
      rethrow; // 重新抛出以便上层处理
    }
  }

  /// 返回记录的更新数量
  Future<int> update(
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      return await _dbService.update(
        tableName,
        values,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: 'Failed to update record in $tableName',
      );
      rethrow; // 重新抛出以便上层处理
    }
  }

  Future<bool> delete({String? where, List<Object?>? whereArgs}) async {
    try {
      final count = await _dbService.delete(
        tableName,
        where: where,
        whereArgs: whereArgs,
      );
      return count > 0;
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        errorMessage: ' Failed to delete record from $tableName',
      );
      rethrow; // 重新抛出以便上层处理
    }
  }

  Future<int?> firstRecordId({
    required String where,
    required List<dynamic> whereArgs,
    String idColumn = 'id',
  }) async {
    try {
      return await _dbService.firstRecordId(
        tableName,
        where: where,
        whereArgs: whereArgs,
        idColumn: idColumn,
      );
    } catch (e, st) {
      _debugService.exception(
        e,
        st,
        log: true,
        errorMessage: 'Failed to get first record ID for $tableName',
      );
      return null;
    }
  }
}
