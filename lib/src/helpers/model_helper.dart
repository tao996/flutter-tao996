import 'dart:math';

import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

abstract class ModelHelper<T extends IModel<T>> {
  final IDatabaseService dbService = getIDatabaseService();
  final IDebugService debugService = getIDebugService();

  final String _tableName;

  /// 是否启用缓存
  final bool smallTable;

  /// 是否开启软删除 deletedAt 字段
  final bool enableSoftDelete;

  /// 表中是否有 createdAt 字段
  final bool enableCreatedAt;

  /// 表中是否有 updatedAt 字段
  final bool enableUpdatedAt;

  /// 是否启用 uuid
  final bool enableUuid;

  /// 缓存全部的记录，通常用于小表使用
  List<T> _cache = [];

  /// 提供对缓存的只读访问
  List<T> get cache => List.unmodifiable(_cache);

  /// 获取表名
  String get tableName => _tableName;

  // 1. 扩展 getFirstBy 的缓存支持（支持任意字段，需子类注册缓存字段）
  // 新增：缓存字段映射（子类可重写，指定需要缓存的字段）
  Map<String, dynamic Function(T)> get cacheFieldGetters => {
    'id': (entity) => entity.id,
  };

  /// [smallTable] 是否为小表，如果是，将一次性加载全部数据
  /// [enableSoftDelete] 是否使用软删除功能，注意：如果你的表中包含了 unique 索引，请不要使用软删除功能
  ModelHelper(
    this._tableName, {
    this.smallTable = false,
    this.enableSoftDelete = false,
    this.enableCreatedAt = true,
    this.enableUpdatedAt = true,
    this.enableUuid = false,
  });

  Future<void> init(String language) async {
    debugService.d('Initializing $tableName...');
    if (smallTable) {
      await getAll();
      debugService.d(' $tableName cache loaded with ${_cache.length} items.');
    }
  }

  /// 将 Map 数据转换为实体对象 [T]。
  T fromMap(Map<String, dynamic> map);

  /// 插入前调用：返回 false 中断插入，返回 true 继续
  /// [entity]：待插入的实体（关联具体数据，替代原 Map 参数）
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<bool> beforeInsert(T entity, {ModelTransaction? mtn}) async => true;

  /// 插入后调用：返回值可用于传递额外数据（如关联ID）
  /// [entity]：插入成功后的实体（含数据库生成的 id）
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<dynamic> afterInsert(T entity, {ModelTransaction? mtn}) async => null;

  /// 更新前调用：返回 false 中断更新
  /// [entity]：待更新的实体；[updateFields]：本次要更新的字段名（避免全量判断）
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<bool> beforeUpdate(T entity, {ModelTransaction? mtn}) async => true;

  /// 更新后调用：返回值可用于传递额外数据
  /// [entity]：更新后的实体（非 null，更新操作必关联实体）
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<dynamic> afterUpdate(T entity, {ModelTransaction? mtn}) async => null;

  /// 保存前调用（插入/更新通用）：返回 false 中断保存
  /// [entity]：待保存的实体；[isInsert]：标识是插入还是更新
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<bool> beforeSave(
    T entity,
    bool isInsert, {
    ModelTransaction? mtn,
  }) async => true;

  /// 保存后调用（插入/更新通用）：返回值可用于传递额外数据
  /// [entity]：保存后的实体；[isInsert]：标识是插入还是更新
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<dynamic> afterSave(
    T entity,
    bool isInsert, {
    ModelTransaction? mtn,
  }) async => null;

  /// 删除前调用：返回 false 中断删除
  /// [entity]：待删除的实体（非 null 时为按实体删除）；[where]：删除条件（按条件删除时生效）
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<bool> beforeDelete({
    T? entity,
    String? where,
    List<Object?>? whereArgs,
    ModelTransaction? mtn,
  }) async => true;

  /// 删除后调用：返回值可用于传递额外数据（如删除的关联数量）
  /// [deletedCount]：实际删除/软删除的行数；[entity]：被删除的实体（非 null 时为按实体删除）
  /// [mtn]：事务对象，如果为 null 表示不在事务中
  Future<dynamic> afterDelete(
    int deletedCount, {
    T? entity,
    ModelTransaction? mtn,
  }) async => null;

  /// 获取全部的记录（可能使用缓存）
  Future<List<T>> getAll({bool force = false}) async {
    if (_cache.isEmpty || force) {
      _cache.assignAll(await _getAllFromDb());
    }
    return _cache;
  }

  /// 如果启用了软删除，则在 where 条件中自动添加 `deletedAt IS NULL AND`
  String? appendWhere(String? where) {
    if (where == null || where == '') {
      return enableSoftDelete ? 'deletedAt IS NULL ' : null;
    }

    return enableSoftDelete ? 'deletedAt IS NULL AND $where' : where;
  }

  /// 从数据库中查询全部的记录并更新缓存。
  Future<List<T>> _getAllFromDb({ModelTransaction? mtn}) async {
    final List<Map<String, dynamic>> maps = await query(
      orderBy: 'id DESC',
      mtn: mtn,
    );
    final rows = maps.map((map) => fromMap(map)).toList();
    if (smallTable) {
      _cache = rows; // 直接赋值以更新缓存
    }
    return rows;
  }

  /// 获取指定字段和值的第一个记录
  Future<T?> getFirstBy({
    required String fieldName,
    required dynamic value,
    bool tryCache = true,
    ModelTransaction? mtn,
  }) async {
    if (tryCache && smallTable && cacheFieldGetters.containsKey(fieldName)) {
      final getter = cacheFieldGetters[fieldName]!;
      return _cache.firstWhereOrNull((element) => getter(element) == value);
    } else {
      final maps = await query(
        where: '$fieldName = ?',
        whereArgs: [value],
        limit: 1, // 只查询一条
        mtn: mtn,
      );
      return maps.isNotEmpty ? fromMap(maps.first) : null;
    }
  }

  Future<T?> getFirstWith(
    String where, {
    List<Object?>? whereArgs,
    List<String>? columns,
    String? orderBy,
    ModelTransaction? mtn,
  }) async {
    final maps = await query(
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      columns: columns,
      limit: 1, // 只查询一条
      mtn: mtn,
    );
    return maps.isNotEmpty ? fromMap(maps.first) : null;
  }

  Future<T?> getById(
    int id, {
    String fieldName = 'id',
    bool tryCache = true,
    ModelTransaction? mtn,
  }) async {
    if (id < 1) {
      return null;
    }
    return await getFirstBy(
      fieldName: fieldName,
      value: id,
      tryCache: tryCache,
      mtn: mtn,
    );
  }

  Future<List<T>> getByIds(
    List<int> ids, {
    String fieldName = 'id',
    bool tryCache = true,
    ModelTransaction? mtn,
  }) async {
    if (ids.isEmpty) {
      return [];
    }
    final where = '$fieldName IN (${ids.join(',')})';
    return await getManyBy(where: where, mtn: mtn);
  }

  /// 根据 ids 的个数生成占位符
  String inPlaceholder(List<Object> ids) {
    if (ids.isEmpty) {
      return '';
    }
    // 假设 memberIds = [1, 2, 3]
    return List.generate(ids.length, (i) => '?').join(',');
  }

  Future<T?> getByUuid(
    String uuid, {
    bool tryCache = true,
    ModelTransaction? mtn,
  }) async {
    if (uuid.isEmpty) {
      return null;
    }
    return await getFirstBy(
      fieldName: 'uuid',
      value: uuid,
      tryCache: tryCache,
      mtn: mtn,
    );
  }

  /// 检查记录在数据库中是否存在
  Future<bool> exists(
    dynamic value, {
    required String fieldName,
    int? excludeId,
    String? excludeUuid,
    ModelTransaction? mtn,
  }) async {
    return await existsWith(
      where: '$fieldName = ?',
      whereArgs: [value],
      excludeId: excludeId,
      excludeUuid: excludeUuid,
      mtn: mtn,
    );
  }

  /// 检查记录在数据库中是否存在
  Future<bool> existsWith({
    String? where,
    List<Object>? whereArgs,
    int? excludeId,
    String? excludeUuid,
    ModelTransaction? mtn,
  }) async {
    List<String> where1 = [];
    if (where != null && where.isNotEmpty) {
      where1.add(where);
    }
    List<Object> whereArgs1 = [];
    if (whereArgs != null && whereArgs.isNotEmpty) {
      whereArgs1.addAll(whereArgs);
    }
    if (excludeUuid != null && excludeUuid.isNotEmpty) {
      where1.add('uuid != ?');
      whereArgs1.add(excludeUuid);
    }
    if (excludeId != null && excludeId > 0) {
      where1.add('id != ?');
      whereArgs1.add(excludeId);
    }
    return await dbService.exists(
      tableName,
      where: appendWhere(where1.join(' AND ')),
      whereArgs: whereArgs1,
      txn: mtn?.txn,
    );
  }

  /// 获取记录总数。
  Future<int> count({
    String? where,
    List<Object?>? whereArgs,
    bool forceRefresh = false,
    ModelTransaction? mtn,
  }) async {
    if (smallTable && !forceRefresh) {
      // 若有查询条件，缓存无法覆盖，需查数据库
      if (where == null && whereArgs == null) {
        return _cache.length;
      }
    }

    return await dbService.count(
      tableName,
      where: appendWhere(where),
      whereArgs: whereArgs,
      txn: mtn?.txn,
    );
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
    int pageIndex = 1,
    ModelTransaction? mtn,
  }) async {
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
      orderBy: orderBy ?? 'id DESC',
      limit: pageSize,
      offset: offset ?? getOffset(pageIndex: pageIndex, pageSize: pageSize),
      txn: mtn?.txn,
    );
    return result.map((map) => fromMap(map)).toList();
  }

  int? getOffset({int? pageIndex, int? pageSize}) {
    if (pageIndex == null || pageSize == null) {
      return null;
    }
    return (max(1, pageIndex) - 1) * pageSize;
  }

  /// 从数据库中获取第1条符合条件的记录的字段 [key]值
  Future<int> getFirstRecordKey({
    required String where,
    required List<dynamic> whereArgs,
    String key = 'id',
    ModelTransaction? mtn,
  }) async {
    return await dbService.firstRecordId(
      tableName,
      where: appendWhere(where),
      whereArgs: whereArgs,
      key: key,
      txn: mtn?.txn,
    );
  }

  /// 获取指定字段和值的所有记录。如果提供了 [where] 则优先使用 [where] 和 [whereArgs]；
  /// 再使用 [fieldName] 和 [value] 组合
  Future<List<T>> getManyBy({
    String? fieldName,
    dynamic value,
    String? where,
    List<Object>? whereArgs,
    WhereClauseBuilder? clauseBuilder,
    String? groupBy,
    String? having,
    String? orderBy,
    int? pageSize,
    int? pageIndex,
    ModelTransaction? mtn,
  }) async {
    final result = await getManyMapWith(
      fieldName: fieldName,
      value: value,
      where: where,
      whereArgs: whereArgs,
      clauseBuilder: clauseBuilder,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      pageIndex: pageIndex,
      pageSize: pageSize,
      mtn: mtn,
    );
    return result.map((map) => fromMap(map)).toList();
  }

  /// 获取原始数据，需要自己动手转换
  /// 如果提供了 [where] 则优先使用 [where] 和 [whereArgs]
  /// 再使用 [fieldName] 和 [value] 组合
  Future<List<Map<String, dynamic>>> getManyMapWith({
    String? fieldName,
    dynamic value,
    String? where,
    List<Object>? whereArgs,
    WhereClauseBuilder? clauseBuilder,
    List<String>? columns,
    String? groupBy,
    String? having,
    String? orderBy,
    int? pageSize,
    int? pageIndex,
    ModelTransaction? mtn,
  }) async {
    var (newWhere, newWhereArgs) = createWhere(where, whereArgs, clauseBuilder);
    if (fieldName != null && fieldName.isNotEmpty) {
      if (newWhere != null) {
        newWhere += ' AND $fieldName = ?';
      }
      if (newWhereArgs == null) {
        newWhereArgs = [value];
      } else {
        newWhereArgs.add(value);
      }
    }
    return await query(
      columns: columns,
      where: newWhere,
      whereArgs: newWhereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: pageSize,
      offset: getOffset(pageIndex: pageIndex, pageSize: pageSize),
      mtn: mtn,
    );
  }

  /// 获取符合条件的记录ID
  Future<List<int>> getIdsWith({
    String? fieldName,
    dynamic value,
    String? where,
    List<Object>? whereArgs,
    WhereClauseBuilder? clauseBuilder,
    String? groupBy,
    String? having,
    String? orderBy,
    int? pageSize,
    int? pageIndex,
    ModelTransaction? mtn,
  }) async {
    return await getListIntColumnWith(
      'id',
      fieldName: fieldName,
      value: value,
      where: where,
      whereArgs: whereArgs,
      clauseBuilder: clauseBuilder,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      pageIndex: pageIndex,
      pageSize: pageSize,
      mtn: mtn,
    );
  }

  Future<List<int>> getListIntColumnWith(
    String column, {
    String? fieldName,
    dynamic value,
    String? where,
    List<Object>? whereArgs,
    WhereClauseBuilder? clauseBuilder,
    String? groupBy,
    String? having,
    String? orderBy,
    int? pageSize,
    int? pageIndex,
    ModelTransaction? mtn,
  }) async {
    final records = await getManyMapWith(
      columns: [column],
      fieldName: fieldName,
      value: value,
      where: where,
      whereArgs: whereArgs,
      clauseBuilder: clauseBuilder,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      pageIndex: pageIndex,
      pageSize: pageSize,
      mtn: mtn,
    );
    return records.map((record) => record[column] as int).toList();
  }

  /// 优先使用 [where]，然后才是 [clauseBuilder] 中的条件
  (String?, List<Object?>?) createWhere(
    String? where,
    List<Object>? whereArgs,
    WhereClauseBuilder? clauseBuilder,
  ) {
    final List<String> newWhere = [];
    if (where != null) {
      newWhere.add(where);
    }
    final List<Object> newWhereArgs = [];
    if (whereArgs != null && whereArgs.isNotEmpty) {
      newWhereArgs.addAll(whereArgs);
    }
    if (clauseBuilder != null) {
      clauseBuilder(newWhere, newWhereArgs);
    }

    return (newWhere.join('AND'), newWhereArgs);
  }

  /// 执行原生 SQL 语句
  Future<void> execute(
    String sql, {
    List<Object?>? arguments,
    ModelTransaction? mtn,
  }) async {
    await dbService.execute(sql, arguments: arguments, txn: mtn?.txn);
  }

  /// 执行原生 SQL 查询
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, {
    List<Object?>? arguments,
    ModelTransaction? mtn,
  }) async {
    return await dbService.rawQuery(sql, arguments: arguments, txn: mtn?.txn);
  }

  /// 查询记录( 在这里调用 appendWhere)
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
    ModelTransaction? mtn,
  }) async {
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
      txn: mtn?.txn,
    );
  }

  /// 更新符合条件的记录，并返回影响行数；如果提供 [entity] 则会更新修改时间及记录缓存;
  /// [values] 字段及其值
  Future<int> updateWith(
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    T? entity,
    ModelTransaction? mtn,
  }) async {
    if (entity != null) {
      if (!entity.hasRecord()) {
        throw 'Entity has no valid id for $tableName update';
      }
      if (enableUpdatedAt) {
        entity.updatedAt = DateTime.now();
      }
      if (!await beforeUpdate(entity, mtn: mtn)) {
        throw 'Update interrupted by beforeUpdate hook for $tableName';
      }
      if (!await beforeSave(entity, false, mtn: mtn)) {
        // isInsert = false（更新场景）
        throw 'Update interrupted by beforeSave hook for $tableName';
      }
    }

    final updatedRows = await dbService.update(
      tableName,
      values,
      where: appendWhere(where),
      whereArgs: whereArgs,
      txn: mtn?.txn,
    );
    if (mtn == null && smallTable) await _getAllFromDb(mtn: mtn);

    if (entity != null) {
      await afterUpdate(entity, mtn: mtn);
      await afterSave(entity, false, mtn: mtn); // isInsert = false
    }

    debugService.d('Updated $updatedRows records in $tableName');
    return updatedRows;
  }

  /// 更新指定 ID 记录的数据
  Future<int> update(
    T entity, {
    List<String>? columns,
    ModelTransaction? mtn,
  }) async {
    Map<String, dynamic> fieldValues = entity.toJson();
    if (columns != null && columns.isNotEmpty) {
      final keys = fieldValues.keys;
      for (final c in columns) {
        if (!keys.contains(c)) {
          throw 'The column $c is not found in the entity (${keys.toString()})';
        }
      }
      // 过滤指定字段，确保类型为 Map<String, Object?>
      fieldValues = columns.fold<Map<String, dynamic>>(
        {},
        (acc, name) => acc..[name] = fieldValues[name],
      );
    } else {
      if (enableCreatedAt) {
        fieldValues.remove('createdAt');
      }
      if (enableUpdatedAt) {
        fieldValues['updatedAt'] = DateTime.now().toIso8601String();
      }
    }
    fieldValues.remove('id'); // 移除 id，避免更新主键
    if (enableUuid) {
      fieldValues.remove('uuid');
    }
    return updateWith(
      fieldValues.cast<String, Object?>(), // 强制类型转换（确保安全，因 fieldValues 来自实体）
      where: "id=?",
      whereArgs: [entity.id],
      entity: entity,
      mtn: mtn,
    );
  }

  /// 删除符合条件的记录，自动更新缓存
  Future<int> delete({
    String? where,
    List<Object?>? whereArgs,
    T? entity,
    ModelTransaction? mtn,
  }) async {
    if (entity != null) {
      if (!entity.hasRecord()) {
        throw 'The entity must have a record ID when deleting';
      }
      if (!await beforeDelete(
        entity: entity,
        where: where,
        whereArgs: whereArgs,
        mtn: mtn,
      )) {
        throw 'Delete interrupted by beforeDelete hook for $tableName';
      }
      entity.deletedAt = DateTime.now();
    }
    // 2. 执行删除/软删除（不变）
    final deletedCount = enableSoftDelete
        ? await updateWith(
            {'deletedAt': DateTime.now().toIso8601String()},
            where: where ?? '',
            whereArgs: whereArgs ?? [],
            entity: entity,
            mtn: mtn,
          )
        : await dbService.delete(
            tableName,
            where: where,
            whereArgs: whereArgs,
            txn: mtn?.txn,
          );
    // 更新缓存 + 后置钩子
    if (mtn == null && smallTable && deletedCount > 0) {
      await _getAllFromDb(mtn: mtn);
    }
    if (entity != null) {
      await afterDelete(deletedCount, entity: entity, mtn: mtn);
    }
    debugService.d(
      'Deleted $deletedCount records in $tableName',
      args: '=x=x=x=x=x=x=x=x=x==x=x=x=x=x=x=x=x=x==x=x',
      log: true,
    );
    return deletedCount;
  }

  /// 根据指定字段和值删除记录。返回删除操作是否成功。
  Future<int> deleteBy({
    required dynamic value,
    String fieldName = 'id',
    T? entity,
    ModelTransaction? mtn,
  }) async {
    return await delete(
      where: '$fieldName = ?',
      whereArgs: [value],
      entity: entity,
      mtn: mtn,
    );
  }

  /// 根据主键 ID 删除记录。
  Future<int> deleteById(int id, {ModelTransaction? mtn}) async {
    return await deleteBy(fieldName: 'id', value: id, mtn: mtn);
  }

  Future<int> deleteByIds(List<int> ids, {ModelTransaction? mtn}) async {
    if (ids.isEmpty) {
      return 0;
    }
    return await delete(
      where: 'id in (?)',
      whereArgs: [ids.join(',')],
      mtn: mtn,
    );
  }

  /// 根据 uuid 删除记录。
  Future<int> deleteByUuid(String uuid, {ModelTransaction? mtn}) async {
    return await deleteBy(fieldName: 'uuid', value: uuid, mtn: mtn);
  }

  /// 添加记录并返回新记录，已经自动从 [values] 中移除 id 列；
  /// 如果使用缓存，则自动添加到缓存中
  Future<T> insertWith(
    Map<String, Object?> values, {
    ModelTransaction? mtn,
  }) async {
    final entity = fromMap(values);
    return insert(entity, mtn: mtn);
  }

  /// 添加记录并返回新记录，已经自动从 [entity] 中移除 id 列；
  Future<T> insert(T entity, {ModelTransaction? mtn}) async {
    if (enableCreatedAt) {
      entity.createdAt = DateTime.now();
    }
    if (enableUpdatedAt) {
      entity.updatedAt = DateTime.now();
    }

    if (!await beforeInsert(entity, mtn: mtn)) {
      throw 'Insert interrupted by beforeInsert hook for $tableName';
    }
    if (!await beforeSave(entity, true, mtn: mtn)) {
      throw 'Insert interrupted by beforeSave hook for $tableName';
    }
    final data = entity.toJson()..remove('id');
    if (enableUuid) {
      if (tu.assert1.isEmpty(data['uuid'])) {
        throw 'uuid is empty';
      }
    }
    final newId = await dbService.insert(tableName, data, txn: mtn?.txn);
    if (newId <= 0) throw 'Failed to insert record into $tableName';
    entity.id = newId;
    // 获取新插入的记录
    final record = await getById(newId, tryCache: false, mtn: mtn);
    if (record == null) {
      throw 'Failed to get record by id=$newId from $tableName';
    }
    debugService.d('Inserted new record into $tableName with new ID: $newId');

    /// 更新缓存
    if (mtn == null && smallTable) {
      await _getAllFromDb(mtn: mtn);
    }
    // 更新后置钩子
    await afterInsert(record, mtn: mtn);
    await afterSave(record, true, mtn: mtn);
    dprint('insert success: ${record.id}');
    return record;
  }

  /// 批量插入（使用事务），需要手动更新缓存
  Future<List<int>> batchInsert(
    List<T> entities, {
    ModelTransaction? mtn,
    bool callback = false,
  }) async {
    if (entities.isEmpty) return [];
    if (mtn == null) {
      return transaction((mtn) async {
        return _batchInsert(entities, mtn);
      });
    }
    return _batchInsert(entities, mtn);
  }

  Future<List<int>> _batchInsert(
    List<T> entities,
    ModelTransaction mtn, {
    bool callback = false,
  }) async {
    if (entities.isEmpty) return [];

    final ids = <int>[];
    for (final entity in entities) {
      // 复用 beforeInsert/beforeSave 逻辑
      if (!await beforeInsert(entity, mtn: mtn) ||
          !await beforeSave(entity, true, mtn: mtn)) {
        throw 'Batch insert interrupted for entity: ${entity.id}';
      }
      if (enableCreatedAt) entity.createdAt = DateTime.now();
      if (enableUpdatedAt) entity.updatedAt = DateTime.now();
      final data = entity.toJson()..remove('id');
      if (enableUuid && tu.assert1.isEmpty(data['uuid'])) {
        throw 'uuid is empty';
      }
      final id = await mtn.txn.insert(tableName, data);

      ids.add(id);
      entity.id = id; // 回填 ID
      if (callback) {
        await afterInsert(entity, mtn: mtn);
        await afterSave(entity, true, mtn: mtn);
      }
    }
    return ids;
  }

  /// 执行一个事务
  Future<M> transaction<M>(
    Future<M> Function(ModelTransaction) action, {
    bool? exclusive,
  }) async {
    final db = dbService.getDatabase();
    return await db.transaction<M>((txn) async {
      return action(ModelTransaction(txn));
    }, exclusive: exclusive);
  }

  // Future<ModelTransaction> transactionTXN({bool? exclusive}) async {
  //   final db = dbService.getDatabase();
  //   return await db.transaction<ModelTransaction>((txn) async {
  //     return ModelTransaction(txn);
  //   }, exclusive: exclusive);
  // }

  /// 恢复软删除的记录
  Future<int> restore({
    String? where,
    List<Object?>? whereArgs,
    T? entity,
    ModelTransaction? mtn,
  }) async {
    if (!enableSoftDelete) {
      throw 'Soft delete is not enabled for $tableName';
    }
    // 调用前置钩子（复用 beforeSave，isInsert = false）
    if (entity != null && !await beforeSave(entity, false, mtn: mtn)) {
      throw 'Restore interrupted by beforeSave hook for $tableName';
    }
    final updatedRows = await updateWith(
      {'deletedAt': null},
      where: where,
      whereArgs: whereArgs,
      entity: entity,
      mtn: mtn,
    );
    // 调用后置钩子
    if (entity != null) {
      await afterSave(entity, false, mtn: mtn);
    }
    return updatedRows;
  }

  /// 查询已删除的记录（与正常查询区分）
  Future<List<T>> getDeleted({
    String? where,
    List<Object?>? whereArgs,
    ModelTransaction? mtn,
  }) async {
    if (!enableSoftDelete) return [];
    final actualWhere = where == null
        ? 'deletedAt IS NOT NULL'
        : 'deletedAt IS NOT NULL AND $where';
    final maps = await dbService.query(
      tableName,
      where: actualWhere,
      whereArgs: whereArgs,
      txn: mtn?.txn,
    );
    return maps.map((m) => fromMap(m)).toList();
  }

  /// 字段递增
  Future<void> increase(
    int id,
    String field, {
    int value = 1,
    ModelTransaction? mtn,
  }) async {
    final sql = 'UPDATE $tableName SET $field=$field+$value WHERE id=$id';
    await execute(sql, mtn: mtn);
  }

  /// 字段递减
  Future<void> decrease(
    int id,
    String field, {
    int value = 1,
    ModelTransaction? mtn,
  }) async {
    final sql = 'UPDATE $tableName SET $field=$field-$value WHERE id=$id';
    await execute(sql, mtn: mtn);
  }

  // 当收到另一台设备发来的数据时，你不知道它是“新产生的”还是“被修改的”
  Future<void> upsert(T entity, String uuid, {ModelTransaction? mtn}) async {
    // 1. 根据 UUID 检查本地是否存在
    final existing = await getByUuid(uuid, mtn: mtn);
    if (existing == null) {
      await insert(entity, mtn: mtn);
    } else {
      entity.id = existing.id; // 保持本地 ID 不变
      await update(entity, mtn: mtn);
    }
  }
}
