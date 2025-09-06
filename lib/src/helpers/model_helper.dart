import 'dart:math';

import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

abstract class ModelHelper<T extends IModel> {
  final IDatabaseService dbService = getIDatabaseService();
  final IDebugService debugService = getIDebugService();

  final String _tableName;

  /// 是否启用缓存
  final bool enableCache;

  /// 是否开启软删除 soft delete
  final bool enableSoftDelete;

  /// 缓存全部的记录，通常用于小表使用
  /// 使用 `RxList` (如果使用 GetX) 或其他响应式列表，方便 UI 自动刷新
  /// 如果不使用响应式框架，普通 List 即可
  List<T> _cache = [];

  /// 提供对缓存的只读访问
  List<T> get cache => List.unmodifiable(_cache);

  /// 获取表名
  String get tableName => _tableName;

  /// [enableCache] 是否使用缓存，通常用于小表使用;
  /// [enableSoftDelete] 是否使用软删除功能，注意：如果你的表中包含了 unique 索引，请不要使用软删除功能
  ModelHelper(
    this._tableName, {
    this.enableCache = false,
    this.enableSoftDelete = false,
  });

  Future<void> init(String language) async {
    debugService.d('Initializing $tableName...');
    if (enableCache) {
      await getAllFromDb();
      debugService.d(' $tableName cache loaded with ${_cache.length} items.');
    }
  }

  /// 将 Map 数据转换为实体对象 [T]。
  T fromMap(Map<String, dynamic> map);

  /// 通常用在 getBy 中，用于获取实体的特定字段值，通常用于检查实体是否已存在
  dynamic getValueByField(T entity, String fieldName);

  /// 用在查询记录中
  dynamic getMsValueByField(T entity, String fieldName) {
    switch (fieldName) {
      case 'id':
        return entity.id;
      case 'createdAt':
        return entity.createdAt;
      case 'updatedAt':
        return entity.updatedAt;
      case 'deletedAt':
        return entity.deletedAt;
      default:
        return getValueByField(entity, fieldName);
    }
  }

  /// 用在 update 操作中，会将修改的值同步到实体中
  void setValueByField(T entity, String fieldName, dynamic value);

  void setMsValueByField(T entity, String fieldName, dynamic value) {
    switch (fieldName) {
      case 'id':
        entity.id = value;
        break;
      case 'createdAt':
        entity.createdAt = value;
        break;
      case 'updatedAt':
        entity.updatedAt = value;
        break;
      case 'deletedAt':
        entity.deletedAt = value;
        break;
      default:
        setValueByField(entity, fieldName, value);
    }
  }

  /// 获取全部的记录（可能使用缓存）
  Future<List<T>> getAll() async {
    if (this.enableCache) {
      return _cache.isNotEmpty ? Future.value(_cache) : await getAllFromDb();
    } else {
      return await getAllFromDb();
    }
  }

  /// 如果启用了软删除，则在 where 条件中自动添加 `deletedAt IS NULL AND`
  String? appendWhere(String? where) {
    if (where == null || where == '') {
      return enableSoftDelete ? 'deletedAt IS NULL ' : null;
    }

    return enableSoftDelete ? 'deletedAt IS NULL AND $where' : where;
  }

  /// 从数据库中查询全部的记录并更新缓存。
  Future<List<T>> getAllFromDb() async {
    try {
      final List<Map<String, dynamic>> maps = await dbService.query(
        tableName,
        where: appendWhere(null),
        orderBy: 'id DESC',
      );
      final rows = maps.map((map) => fromMap(map)).toList();
      if (enableCache) {
        _cache = rows; // 直接赋值以更新缓存
      }
      return rows;
    } catch (e, st) {
      debugService.exception(e, st);
      throw '加载表 $tableName 失败！原因: ${e.toString()}';
    }
  }

  /// 获取指定字段和值的第一个记录
  Future<T?> getFirstBy({
    required String fieldName,
    required dynamic value,
    bool tryCache = true,
  }) async {
    if (tryCache && enableCache) {
      return _cache.firstWhereOrNull(
        (element) => getMsValueByField(element, fieldName) == value,
      );
    } else {
      try {
        final maps = await dbService.query(
          tableName,
          where: appendWhere('$fieldName = ?'),
          whereArgs: [value],
          limit: 1, // 只查询一条
        );
        return maps.isNotEmpty ? fromMap(maps.first) : null;
      } catch (e, st) {
        debugService.exception(e, st, log: true);
        throw 'Failed to get record by $fieldName=$value from $tableName; because: $e';
      }
    }
  }

  Future<T?> getById(int id, {bool tryCache = true}) async {
    return await getFirstBy(fieldName: 'id', value: id, tryCache: tryCache);
  }

  /// 删除符合条件的记录，自动更新缓存
  Future<int> delete({String? where, List<Object?>? whereArgs}) async {
    try {
      var count = 0;
      if (enableSoftDelete) {
        count = await update(
          {"deletedAt": DateTime.now().toIso8601String()},
          where: appendWhere(where),
          whereArgs: whereArgs,
        );
        debugService.d(
          'softDeleted result',
          args: {"where": where, "whereArgs": whereArgs, "count": count},
        );
      } else {
        count = await dbService.delete(
          tableName,
          where: where,
          whereArgs: whereArgs,
        );
        debugService.d(
          'deleted result',
          args: {"where": where, "whereArgs": whereArgs, "count": count},
        );
      }
      if (enableCache && count > 0) {
        await getAllFromDb();
      }

      return count;
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to delete record from $tableName; because: $e';
    }
  }

  /// 根据指定字段和值删除记录。返回删除操作是否成功。
  Future<int> deleteBy({
    required dynamic value,
    String fieldName = 'id',
  }) async {
    return await delete(where: '$fieldName = ?', whereArgs: [value]);
  }

  /// 根据主键 ID 删除记录。
  Future<int> deleteById(int id) async {
    return await deleteBy(fieldName: 'id', value: id);
  }

  /// 检查记录在数据库中是否存在
  Future<bool> exists(
    dynamic value, {
    required String fieldName,
    int? excludeId,
  }) async {
    try {
      final where = excludeId != null
          ? '$fieldName = ? AND id != ?'
          : '$fieldName = ?';
      return await dbService.exists(
        tableName,
        where: appendWhere(where),
        whereArgs: excludeId != null ? [value, excludeId] : [value],
      );
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to check existence of record in $tableName for $fieldName=$value; because: $e';
    }
  }

  /// 获取记录总数。
  Future<int> count({String? where, List<Object?>? arguments}) async {
    if (enableCache) {
      return _cache.length;
    }
    try {
      return await dbService.count(
        tableName,
        where: appendWhere(where),
        arguments: arguments,
      );
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to get count for $tableName; because: $e';
    }
  }

  /// 通用的分页查询方法，基于自增主键ID
  ///
  /// [pageSize]: 每页的记录数。[columns] 查询的字段; [orderBy] 排序；
  ///
  /// [offset] 偏移量，优先使用；[pageIndex] 当前页码，默认为1
  ///
  /// [where] 查询条件；[whereArgs] 条件参数; [clauseBuilder] 复合查询条件（优先级比 [where] 和 [whereArgs] 低）
  ///
  /// 返回一个 Map 列表，其中包含查询到的记录。
  Future<List<T>> getPaginationData({
    required int pageSize,
    String? where,
    List<Object?>? whereArgs,
    WhereClauseBuilder? clauseBuilder,
    List<String>? columns,
    String? orderBy,
    int? offset,
    int? pageIndex,
  }) async {
    try {
      final List<String> conditions = [];
      final List<Object> whereArgs1 = [];
      if (clauseBuilder != null) {
        clauseBuilder(conditions, whereArgs1);
      }
      final baseWhere =
          where ?? (conditions.isNotEmpty ? conditions.join(' AND ') : null);
      final result = await dbService.query(
        tableName,
        columns: columns,
        where: appendWhere(baseWhere),
        whereArgs: whereArgs ?? whereArgs1,
        orderBy: orderBy,
        limit: pageSize,
        offset:
            offset ??
            (pageIndex == null ? null : (max(1, pageIndex) - 1) * pageSize),
      );
      return result.map((map) => fromMap(map)).toList();
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to get paged data for $tableName; because: $e';
    }
  }

  /// 获取指定字段和值的所有记录。
  Future<List<T>> getManyBy({
    required String fieldName,
    required dynamic value,
    List<String>? columns,
  }) async {
    try {
      final result = await dbService.query(
        tableName,
        columns: columns,
        where: appendWhere('$fieldName = ?'),
        whereArgs: [value],
      );
      return result.map((map) => fromMap(map)).toList();
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to getManyBy data for $tableName; because: $e';
    }
  }

  /// 执行原生 SQL 语句
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    try {
      await dbService.execute(sql, arguments);
    } catch (e, st) {
      debugService.exception(
        e,
        st,
        args: {'sql': sql, 'arguments': arguments},
        log: true,
      );
      throw 'Failed to execute SQL for $tableName; because: $e';
    }
  }

  /// 执行原生 SQL 查询
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      return await dbService.rawQuery(sql, arguments);
    } catch (e, st) {
      debugService.exception(e, st, args: {'sql': sql, 'arguments': arguments});
      throw 'Failed to execute raw query for $tableName; because: $e';
    }
  }

  /// 查询记录
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
    try {
      return await dbService.query(
        tableName,
        distinct: distinct,
        columns: columns,
        where: appendWhere(where),
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to query for $tableName; because: $e';
    }
  }

  /// 添加记录并返回新记录，已经自动从 [values] 中移除 id 列；
  /// 如果使用缓存，则自动添加到缓存中
  Future<T> insert(Map<String, Object?> values) async {
    try {
      values['createdAt'] = DateTime.now().toIso8601String();
      values['updatedAt'] = DateTime.now().toIso8601String();
      final newId = await dbService.insert(tableName, values..remove('id'));
      if (newId > 0) {
        final record = await getById(newId, tryCache: false);
        if (record == null) {
          throw 'Failed to get record by id=$newId from $tableName';
        }
        debugService.d(
          'Inserted new record into $tableName with new ID: $newId',
        );
        if (enableCache) {
          await getAllFromDb();
        }
        return record;
      } else {
        throw 'Failed to insert record into $tableName';
      }
    } catch (e, st) {
      debugService.exception(e, st, args: values, log: true);
      throw 'Failed to insert record into $tableName; because: $e';
    }
  }

  /// 更新符合条件的记录，并返回影响行数；如果提供 [entity] 则会更新缓存
  Future<int> update(
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    T? entity,
  }) async {
    try {
      values['updatedAt'] = DateTime.now().toIso8601String();
      final updatedRows = await dbService.update(
        tableName,
        values,
        where: appendWhere(where),
        whereArgs: whereArgs,
      );
      if (entity != null && entity.hasRecord()) {
        for (final key in values.keys) {
          setMsValueByField(entity, key, values[key]);
        }
      }
      if (updatedRows == 0) {
        debugService.d(
          'No record updated in $tableName. Check your where clause and values.',
          args: values,
        );
      }
      if (enableCache && updatedRows > 0) {
        await getAllFromDb(); // 确保缓存最新
      }

      return updatedRows;
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to update record in $tableName; because: $e';
    }
  }

  /// 更新指定 ID 记录的数据
  Future<int> updateWithId(
    int id,
    Map<String, Object?> values, {
    T? entity,
  }) async {
    return update(values, entity: entity, where: "id=?", whereArgs: [id]);
  }

  /// 从数据库中获取第1条符合条件的记录的字段 [key]值
  Future<int> getFirstRecordKey({
    required String where,
    required List<dynamic> whereArgs,
    String key = 'id',
  }) async {
    try {
      return await dbService.firstRecordId(
        tableName,
        where: appendWhere(where),
        whereArgs: whereArgs,
        key: key,
      );
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to get first record ID for $tableName; because: $e';
    }
  }
}
