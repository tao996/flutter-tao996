import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

// enum MAction { insert, update, delete }

/// 使用示例
///
/// ```
/// final MyModelDelegate<User> delegate // 类型需要指定为 User
///   = MyModelDelegate<User>(getUserService());
/// ```
class MyModelDelegate<T extends IModel<T>> {
  IMessageService? _messageService;

  ModelHelper<T>? _service;
  MyModelDelegate<T>? _parentDelegate;
  RxList<T>? _items;
  RxInt? _total;

  ///转换回调, 如果数据库返回的对象和 RxList 里的对象类型不一致时非常有用
  T Function(T)? onDataTransform;
  Future<void> Function(int index)? afterUpdate;
  Future<void> Function(T)? afterInsert;
  Future<void> Function(T, int)? afterDelete;

  /// [delegate] 使用场景 `PageListA -> PageManagerA -> PageEditA`
  MyModelDelegate({
    ModelHelper<T>? service,
    IMessageService? messageService, // 允许测试时注入 Mock
    MyModelDelegate<T>? delegate,
    RxList<T>? items,
    RxInt? total,
    bool autoInit = false,
  }) : _service = service,
       _messageService = messageService {
    _items = items;
    _total = total;
    if (autoInit) {
      _items ??= RxList<T>();
      _total ??= RxInt(0);
    }
    bind(delegate: delegate);
  }

  RxList<T>? get _rootItems => _parentDelegate?._items ?? _items;

  RxInt? get _rootTotal => _parentDelegate?._total ?? _total;

  ModelHelper<T>? get _rootService => _service ?? _parentDelegate?._rootService;

  // 提供一个内部 getter，如果没注入就去取全局单例
  IMessageService get messageService => _messageService ?? getIMessageService();

  // 外部便捷访问 (带安全检查)
  RxList<T> get items {
    if (_rootItems == null) {
      throw Exception(
        'MyModelDelegate: 无法找到可用的 items。请通过 items 属性或 delegate 属性绑定数据源。',
      );
    }
    return _rootItems!;
  }

  RxInt get total {
    if (_rootTotal == null) {
      throw Exception(
        'MyModelDelegate: 获取 total 失败。请通过 total 获取器或 delegate 绑定数据源。',
      );
    }
    return _rootTotal!;
  }

  ModelHelper<T> get service {
    if (_rootService == null) {
      throw Exception(
        'MyModelDelegate: 获取 service 失败。请通过 service 获取器或 delegate 绑定数据源。',
      );
    }
    return _rootService!;
  }

  bool get hasService => _rootService != null;

  void bind({
    ModelHelper<T>? service,
    RxList<T>? items,
    RxInt? total,
    MyModelDelegate<T>? delegate,
    T Function(T)? onDataTransform, // 允许数据转换
    Future<void> Function(int index)? afterUpdate,
    Future<void> Function(T record)? afterInsert,
    Future<void> Function(T oldRecord, int index)? afterDelete,
  }) {
    if (service != null) _service = service;
    if (items != null) _items = items;
    if (total != null) _total = total;
    if (delegate != null) {
      _parentDelegate = delegate;
      // 自动继承父级的核心组件，减少手动 bind 次数
      _service ??= delegate._rootService;
      _messageService ??= delegate.messageService;
    }
    bindCallback(
      onDataTransform: onDataTransform,
      afterUpdate: afterUpdate,
      afterInsert: afterInsert,
      afterDelete: afterDelete,
    );
  }

  void bindCallback({
    T Function(T)? onDataTransform, // 允许数据转换
    Future<void> Function(int index)? afterUpdate,
    Future<void> Function(T record)? afterInsert,
    Future<void> Function(T oldRecord, int index)? afterDelete,
  }) {
    this.afterInsert = afterInsert;
    this.afterUpdate = afterUpdate;
    this.afterDelete = afterDelete;
    this.onDataTransform = onDataTransform;
  }

  void mustHasCallback() {
    if (afterInsert == null && afterUpdate == null && afterDelete == null) {
      throw Exception(
        '请先调用 bindCallback 方法以绑定 afterInsert、afterUpdate、afterDelete',
      );
    }
  }

  void mustHasAfterInsert() {
    if (afterInsert == null) {
      throw Exception('请先调用 bindCallback 方法以绑定 afterInsert');
    }
  }

  void mustHasAfterDelete() {
    if (afterDelete == null) {
      throw Exception('请先调用 bindCallback 方法以绑定 afterDelete');
    }
  }

  void mustHasAfterUpdate() {
    if (afterUpdate == null) {
      throw Exception('请先调用 bindCallback 方法以绑定 afterUpdate');
    }
  }

  /// 内部同步逻辑：支持回调冒泡
  Future<void> _sync({
    required int index,
    T? entity,
    bool unshift = true,
  }) async {
    final rootItems = _rootItems;
    final rootTotal = _rootTotal;
    if (rootItems == null) return;

    if (entity == null) {
      // 删除逻辑
      if (index >= 0 && index < rootItems.length) {
        final removed = rootItems[index];
        rootItems.removeAt(index);
        rootTotal?.value--;

        // 1. 执行当前 delegate 回调
        await afterDelete?.call(removed, index);
        // 2. 改进：可选地通知父 delegate (如果需要链式通知)
        // await _parentDelegate?.afterDelete?.call(removed, index);
      }
    } else {
      final processed = onDataTransform?.call(entity) ?? entity;
      if (index >= 0 && index < rootItems.length) {
        rootItems[index] = processed;
        await afterUpdate?.call(index);
      } else {
        unshift ? rootItems.insert(0, processed) : rootItems.add(processed);
        rootTotal?.value++;
        await afterInsert?.call(processed);
      }
    }
  }

  Future<void> insert(
    T entity, {
    bool showMessage = true,
    bool navBack = true,
    bool unshift = true,
  }) async {
    await save(
      entity: entity,
      index: -1,
      showMessage: showMessage,
      navBack: navBack,
      unshift: unshift,
    );
  }

  Future<void> update(
    T entity,
    int index, {
    bool showMessage = true,
    bool navBack = true,
    bool unshift = true,
  }) async {
    await save(
      entity: entity,
      index: index,
      showMessage: showMessage,
      navBack: navBack,
      unshift: unshift,
    );
  }

  /// 对 [entity] 进行添加或修改操作
  Future<void> save({
    required T entity,
    required int index,
    bool showMessage = true,
    bool navBack = true,
    bool unshift = true,
  }) async {
    if (!hasService) {
      await _sync(index: index, entity: entity, unshift: unshift);
      _onFinalize('save'.tr + 'success'.tr, showMessage, navBack);
      return;
    }

    final action = ModelAction();
    String? message;

    if (index >= 0) {
      action.addUpdate(() => service.update(entity)).afterUpdateSuccess((
        _,
      ) async {
        message = 'save'.tr + 'success'.tr;
        await _sync(index: index, entity: entity, unshift: unshift);
      });
    } else {
      action.addInsert(() => service.insert(entity)).afterInsertSuccess((
        newRecord,
      ) async {
        message = 'add'.tr + 'success'.tr;
        await _sync(index: -1, entity: newRecord as T, unshift: unshift);
      });
    }

    await action.execute(
      success: () async => _onFinalize(message, showMessage, navBack),
    );
  }

  // 抽离公共的收尾逻辑（返回和消息）
  void _onFinalize(String? msg, bool showMessage, bool navBack) {
    if (navBack) goBack();
    if (showMessage && msg != null) {
      messageService.success(msg);
    }
  }

  /// 删除指定索引记录，返回删除的记录数
  Future<int> remoteAt({
    required int index,
    bool deleteConfirm = true,
    String? title,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    return await removeWithId(
      id: items[index].id,
      index: index,
      deleteConfirm: deleteConfirm,
      title: title,
      showMessage: showMessage,
      navBack: navBack,
    );
  }

  // 这里的 remoteAt 和 removeWithId 逻辑基本保持一致，建议在获取 ID 时使用安全访问
  Future<int> removeWithId({
    required int id,
    int? index,
    bool deleteConfirm = true,
    String? title,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    if (deleteConfirm) {
      final ok =
          await messageService.deleteConfirm(title ?? 'record'.tr, () {}) ??
          false;
      if (!ok) return 0;
    }

    // 使用寻根后的 items 进行查找
    final currentItems = items;
    index ??= currentItems.indexWhere((element) => element.id == id);

    if (!hasService) {
      if (index >= 0) {
        await _sync(index: index);
        _onFinalize('delete'.tr + 'success'.tr, showMessage, navBack);
        return 1;
      }
      return 0;
    }

    if (index == -1) return await service.deleteById(id);

    final effect = await service.deleteById(id);
    if (effect > 0) {
      await _sync(index: index);
      _onFinalize('delete'.tr + 'success'.tr, showMessage, navBack);
    } else if (showMessage) {
      messageService.error('noRecordDelete'.tr);
    }
    return effect;
  }

  /// 在详情页/列表页通用的触发器;
  /// [syncDb] 是否同步数据库;
  /// [deleteConfirm] 是否需要确认删除，[title] 删除提示的标题；
  Future<void> trigger(
    T? entity,
    int index, {
    bool syncDb = true,
    bool deleteConfirm = true,
    String? title,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    // 1. 删除模式
    if (entity == null) {
      if (index < 0 || index >= items.length) return;

      bool toDelete = true;
      if (deleteConfirm) {
        toDelete =
            await messageService.deleteConfirm(title ?? 'record'.tr, () {}) ??
            false;
      }

      if (toDelete) {
        if (syncDb) {
          // 这里的 remoteAt 内部会处理同步逻辑
          await remoteAt(
            index: index,
            navBack: navBack,
            showMessage: showMessage,
          );
        } else {
          await _sync(index: index, entity: entity);
          if (navBack) {
            goBack();
          }
        }
      }
      return;
    }

    // 2. 保存/修改模式
    if (syncDb) {
      await save(
        entity: entity,
        index: index,
        navBack: navBack,
        showMessage: showMessage,
      );
    } else {
      await _sync(index: index, entity: entity);

      if (navBack) {
        goBack();
      }
    }
  }
}
