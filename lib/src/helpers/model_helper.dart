import 'dart:math';

import 'package:get/get.dart';
import 'package:tao996/tao996.dart';
typedef DbValue = String? Function(dynamic value); // 数据库值转换函数
typedef EntityField<T> = dynamic Function(T entity); // 实体字段提取函数

abstract class ModelHelper<T extends IModel<T>> {
  final IDatabaseService dbService = getIDatabaseService();
  final IDebugService debugService = getIDebugService();

  final String _tableName;

  /// 是否启用缓存
  final bool enableCache;

  /// 是否开启软删除 deletedAt 字段
  final bool enableSoftDelete;

  /// 表中是否有 createdAt 字段
  final bool enableCreatedAt;

  /// 表中是否有 updatedAt 字段
  final bool enableUpdatedAt;

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
    this.enableCreatedAt = true,
    this.enableUpdatedAt = true,
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
        return _hasCreatedAt(() {
          return entity.createdAt;
        });
      case 'updatedAt':
        return _hasUpdatedAt(() {
          return entity.updatedAt;
        });
      case 'deletedAt':
        return entity.deletedAt;
      default:
        return getValueByField(entity, fieldName);
    }
  }

  /// 插入前调用：返回 false 中断插入，返回 true 继续
  /// [entity]：待插入的实体（关联具体数据，替代原 Map 参数）
  bool beforeInsert(T entity) => true;

  /// 插入后调用：返回值可用于传递额外数据（如关联ID）
  /// [entity]：插入成功后的实体（含数据库生成的 id）
  dynamic afterInsert(T entity) => null;

  /// 更新前调用：返回 false 中断更新
  /// [entity]：待更新的实体；[updateFields]：本次要更新的字段名（避免全量判断）
  bool beforeUpdate(T entity, List<String> updateFields) => true;

  /// 更新后调用：返回值可用于传递额外数据
  /// [entity]：更新后的实体（非 null，更新操作必关联实体）
  dynamic afterUpdate(T entity) => null;

  /// 保存前调用（插入/更新通用）：返回 false 中断保存
  /// [entity]：待保存的实体；[isInsert]：标识是插入还是更新
  bool beforeSave(T entity, bool isInsert) => true;

  /// 保存后调用（插入/更新通用）：返回值可用于传递额外数据
  /// [entity]：保存后的实体；[isInsert]：标识是插入还是更新
  dynamic afterSave(T entity, bool isInsert) => null;

  /// 删除前调用：返回 false 中断删除
  /// [entity]：待删除的实体（非 null 时为按实体删除）；[where]：删除条件（按条件删除时生效）
  bool beforeDelete({T? entity, String? where, List<Object?>? whereArgs}) =>
      true;

  /// 删除后调用：返回值可用于传递额外数据（如删除的关联数量）
  /// [deletedCount]：实际删除/软删除的行数；[entity]：被删除的实体（非 null 时为按实体删除）
  dynamic afterDelete(int deletedCount, {T? entity}) => null;

  dynamic _hasCreatedAt(dynamic Function() action) {
    if (enableCreatedAt) {
      return action();
    } else {
      throw 'createdAt is not enabled in $tableName';
    }
  }

  dynamic _hasUpdatedAt(dynamic Function() action) {
    if (enableUpdatedAt) {
      return action();
    } else {
      throw 'updatedAt is not enabled in $tableName';
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
        _hasCreatedAt(() {
          entity.createdAt = value;
        });
        break;
      case 'updatedAt':
        _hasUpdatedAt(() {
          entity.updatedAt = value;
        });
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
      if (enableCreatedAt) {
        values['createdAt'] = DateTime.now().toIso8601String();
      }
      if (enableUpdatedAt) {
        values['updatedAt'] = DateTime.now().toIso8601String();
      }
      final entity = fromMap(values);
      if (!beforeInsert(entity)) {
        throw 'Insert interrupted by beforeInsert hook for $tableName';
      }
      if (!beforeSave(entity, true)) {
        // isInsert = true（插入场景）
        throw 'Insert interrupted by beforeSave hook for $tableName';
      }
      // debugService.d(entity.toMap()..remove('id'));
      // throw '~~~~ Insert interrupted by beforeSave hook for $tableName';
      final newId = await dbService.insert(
        tableName,
        entity.toMap()..remove('id'),
      );
      if (newId <= 0) throw 'Failed to insert record into $tableName';
      // 获取新插入的记录
      final record = await getById(newId, tryCache: false);
      if (record == null) {
        throw 'Failed to get record by id=$newId from $tableName';
      }
      debugService.d('Inserted new record into $tableName with new ID: $newId');

      /// 更新缓存
      if (enableCache) {
        await getAllFromDb();
      }
      // 更新后置钩子
      afterInsert(record);
      afterSave(record, true);
      return record;
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
      if (entity != null && !entity.hasRecord()) {
        throw 'Entity is null or has no valid id for $tableName update';
      }
      if (enableUpdatedAt) {
        values['updatedAt'] = DateTime.now().toIso8601String();
      }
      final updateFields = values.keys.toList();
      if (entity != null) {
        if (!beforeUpdate(entity, updateFields)) {
          throw 'Update interrupted by beforeUpdate hook for $tableName';
        }
        if (!beforeSave(entity, false)) {
          // isInsert = false（更新场景）
          throw 'Update interrupted by beforeSave hook for $tableName';
        }
      }
      final updatedRows = await dbService.update(
        tableName,
        values,
        where: appendWhere(where),
        whereArgs: whereArgs,
      );
      if (enableCache) await getAllFromDb();
      if (entity != null) {
        // 6. 更新实体字段 + 缓存 + 后置钩子
        if (updatedRows > 0) {
          for (final key in updateFields) {
            setMsValueByField(entity, key, values[key]);
          }
        }
        afterUpdate(entity);
        afterSave(entity, false); // isInsert = false
      }
      debugService.d('Updated $updatedRows records in $tableName');
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
    required T entity,
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

  /// 删除符合条件的记录，自动更新缓存
  Future<int> delete({
    String? where,
    List<Object?>? whereArgs,
    T? entity,
  }) async {
    try {
      // 1. 调用前置钩子：返回 false 中断删除
      if (!beforeDelete(entity: entity, where: where, whereArgs: whereArgs)) {
        throw 'Delete interrupted by beforeDelete hook for $tableName';
      }
      // 2. 执行删除/软删除（不变）
      final deletedCount = enableSoftDelete
          ? await update(
              {'deletedAt': DateTime.now().toIso8601String()},
              where: where ?? '',
              whereArgs: whereArgs ?? [],
              entity: entity,
            )
          : await dbService.delete(
              tableName,
              where: where,
              whereArgs: whereArgs,
            );
      // 更新缓存 + 后置钩子
      if (enableCache && deletedCount > 0) await getAllFromDb();
      afterDelete(deletedCount, entity: entity);

      debugService.d('Deleted $deletedCount records in $tableName');
      return deletedCount;
    } catch (e, st) {
      debugService.exception(e, st, log: true);
      throw 'Failed to delete record from $tableName; because: $e';
    }
  }

  /// 根据指定字段和值删除记录。返回删除操作是否成功。
  Future<int> deleteBy({
    required dynamic value,
    String fieldName = 'id',
    T? entity,
  }) async {
    return await delete(
      where: '$fieldName = ?',
      whereArgs: [value],
      entity: entity,
    );
  }

  /// 根据主键 ID 删除记录。
  Future<int> deleteById(int id, T? entity) async {
    return await deleteBy(fieldName: 'id', value: id, entity: entity);
  }

  // 1. 批量插入（使用事务）
  Future<List<int>> batchInsert(List<T> entities) async {
    if (entities.isEmpty) return [];
    final db = dbService.getDatabase();
    return await db.transaction((txn) async {
      final ids = <int>[];
      for (final entity in entities) {
        // 复用 beforeInsert/beforeSave 逻辑
        if (!beforeInsert(entity) || !beforeSave(entity, true)) {
          throw 'Batch insert interrupted for entity: ${entity.id}';
        }
        if (enableCreatedAt) entity.createdAt = DateTime.now();
        if (enableUpdatedAt) entity.updatedAt = DateTime.now();
        final id = await txn.insert(tableName, entity.toMap()..remove('id'));

        ids.add(id);
        entity.id = id; // 回填 ID
        afterInsert(entity);
        afterSave(entity, true);
      }
      if (enableCache) await getAllFromDb(); // 批量更新缓存
      return ids;
    });
  }

  // 1. 恢复软删除的记录
  Future<int> restore({String? where, List<Object?>? whereArgs}) async {
    if (!enableSoftDelete) {
      throw 'Soft delete is not enabled for $tableName';
    }
    return update(
      {'deletedAt': null},
      where: where,
      whereArgs: whereArgs,
      // 恢复操作无需实体，但需确保更新逻辑兼容
    );
  }

  // 2. 查询已删除的记录（与正常查询区分）
  Future<List<T>> getDeleted({String? where, List<Object?>? whereArgs}) async {
    if (!enableSoftDelete) return [];
    final actualWhere = where == null
        ? 'deletedAt IS NOT NULL'
        : 'deletedAt IS NOT NULL AND $where';
    final maps = await dbService.query(
      tableName,
      where: actualWhere,
      whereArgs: whereArgs,
    );
    return maps.map((m) => fromMap(m)).toList();
  }
}
