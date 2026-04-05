// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

enum DelegateAction { insert, update, delete }

/// 使用示例
/// ```
/// final MyModelDelegate<User> delegate // 类型需要指定为 User
///   = MyModelDelegate<User>(getUserService());
/// ```
class MyModelDelegate<T extends IModel<T>> extends AbstractListDelegate<T> {
  final IMessageService? _messageService;
  ModelHelper<T>? _helper;

  MyModelDelegate({
    ModelHelper<T>? helper,
    IMessageService? messageService, // 允许测试时注入 Mock
    MyModelDelegate<T>? delegate,
    super.rxItems, // 要注意 smallTable 的赋值
    super.rxTotal,
    super.autoInit = true,
  }) : _helper = helper,
       _messageService = messageService,
       super(delegate: delegate);

  // 消息服务寻根
  IMessageService get messageService =>
      _messageService ??
      (_parentDelegate as MyModelDelegate<T>?)?.messageService ??
      getIMessageService();

  // 服务类寻根
  ModelHelper<T> get helper =>
      _helper ??
      (_parentDelegate as MyModelDelegate<T>?)?.helper ??
      (throw Exception('MyModelDelegate: 缺少 ModelHelper 服务。'));

  bool get hasHelper =>
      _helper != null ||
      (_parentDelegate as MyModelDelegate<T>?)?.hasHelper == true;

  int getIndexById(int id) {
    return rxItems.value.indexWhere((element) => element.id == id);
  }

  T? getItemById(int id) {
    final index = getIndexById(id);
    return index == -1 ? null : rxItems.value[index];
  }

  T getItemByIndex(int index) {
    if (index < 0 || index >= rxItems.value.length) {
      throw Exception('getItemByIndex: index out of range.');
    }
    return rxItems.value[index];
  }

  @override
  void bind({
    ModelHelper<T>? helper,
    RxList<T>? rxItems,
    RxInt? rxTotal,
    AbstractListDelegate<T>? delegate,
    Future<void> Function(int index)? afterUpdate,
    Future<void> Function(T record)? afterInsert,
    Future<void> Function(T oldRecord, int index)? afterDelete,
    Future<void> Function(DelegateAction action, {T? record, int? index})?
    delegateCallback,
  }) {
    if (helper != null) {
      _helper = helper;
    }
    super.bind(
      rxItems: rxItems,
      rxTotal: rxTotal,
      delegate: delegate,
      afterUpdate: afterUpdate,
      afterInsert: afterInsert,
      afterDelete: afterDelete,
      delegateCallback: delegateCallback,
    );
  }

  /// 插入1条记录到最前面
  Future<void> insert(
    T entity, {
    bool syncDb = true,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    await save(
      entity,
      index: -1,
      syncDb: syncDb,
      showMessage: showMessage,
      navBack: navBack,
      unshift: true,
    );
  }

  /// 追加1条记录，默认不同步数据库
  Future<void> insertItem(
    T entity, {
    bool syncDb = false,
    bool unshift = false,
  }) async {
    await save(
      entity,
      index: -1,
      syncDb: syncDb,
      showMessage: false,
      navBack: false,
      unshift: unshift,
    );
  }

  /// 追加1条记录到最后面
  Future<void> push(
    T entity, {
    bool syncDb = true,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    await save(
      entity,
      index: -1,
      syncDb: syncDb,
      showMessage: showMessage,
      navBack: navBack,
      unshift: false,
    );
  }

  /// 追加1条记录到最末尾，默认不同步数据库
  Future<void> pushItem(T entity, {bool syncDb = false}) async {
    await save(
      entity,
      index: -1,
      syncDb: syncDb,
      showMessage: false,
      navBack: false,
      unshift: false,
    );
  }

  /// 更新1条记录
  Future<void> update(
    T entity, {
    int? index,
    bool syncDb = true,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    await save(
      entity,
      index: index,
      syncDb: syncDb,
      showMessage: showMessage,
      navBack: navBack,
    );
  }

  Future<void> updateItem(T entity, {int? index, bool syncDb = false}) async {
    await save(
      entity,
      index: index,
      syncDb: syncDb,
      showMessage: false,
      navBack: false,
    );
  }

  /// 对 [entity] 进行添加或修改操作
  Future<void> save(
    T entity, {
    int? index,
    bool syncDb = true,
    bool showMessage = true,
    bool navBack = true,
    bool unshift = true,
  }) async {
    if (entity.id > 0) {
      if (index == null) {
        index = getIndexById(entity.id);
        if (index < 0) {
          throw Exception('save: entity not found.');
        }
      }
    }
    if (syncDb == false) {
      await sync(index: index ?? -1, entity: entity, unshift: unshift);
      _onFinalize('save'.tr + 'success'.tr, showMessage, navBack);
      return;
    }
    // 2. 使用 ModelAction 处理数据库事务
    final action = ModelAction();
    String? message;

    if (entity.id > 0) {
      action.addUpdate(() => helper.update(entity)).afterUpdateSuccess((
        _,
      ) async {
        message = 'save'.tr + 'success'.tr;
        await sync(index: index!, entity: entity, unshift: unshift);
      });
    } else {
      action.addInsert(() => helper.insert(entity)).afterInsertSuccess((
        newRecord,
      ) async {
        message = 'add'.tr + 'success'.tr;
        if (helper.smallTable) {
          if (rxItems.indexWhere((item) => item.id == entity.id) != -1) {
            dprint('小表，记录已经被更新到 rxItems 中，跳过 sync');
            return;
          }
        }
        await sync(index: -1, entity: newRecord as T, unshift: unshift);
      });
    }

    await action.execute(
      success: () async => _onFinalize(message, showMessage, navBack),
    );
  }

  Future<void> saveItem(T entity, {int? index, bool syncDb = false}) async {
    await save(
      entity,
      index: index,
      syncDb: syncDb,
      showMessage: false,
      navBack: false,
      unshift: false,
    );
  }

  // 抽离公共的收尾逻辑（返回和消息）
  void _onFinalize(String? msg, bool showMessage, bool navBack) {
    if (navBack) goBack();
    if (showMessage) {
      if (msg != null && msg.isNotEmpty) {
        messageService.success(msg);
      } else {
        messageService.success('success'.tr);
      }
    }
  }

  /// 删除指定索引记录，返回删除的记录数
  Future<int> remoteAt({
    required int index,
    String? title,
    bool syncDb = true,
    bool deleteConfirm = true,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    return await removeWithId(
      id: rxItems[index].id,
      index: index,
      title: title,
      syncDb: syncDb,
      deleteConfirm: deleteConfirm,
      showMessage: showMessage,
      navBack: navBack,
    );
  }

  Future<int> remoteItem({int? index, int? id, bool syncDb = false}) async {
    if (index == null && id == null) {
      throw Exception('index or id must be provided');
    }
    return await removeWithId(
      id: id ?? rxItems[index!].id,
      index: index,
      syncDb: syncDb,
      deleteConfirm: false,
      showMessage: false,
      navBack: false,
    );
  }

  // 这里的 remoteAt 和 removeWithId 逻辑基本保持一致，建议在获取 ID 时使用安全访问
  Future<int> removeWithId({
    required int id,
    int? index,
    String? title,
    bool syncDb = true,
    bool deleteConfirm = true,
    bool showMessage = true,
    bool navBack = true,
  }) async {
    if (deleteConfirm) {
      final ok =
          await messageService.deleteConfirm(title ?? 'record'.tr) ?? false;
      if (!ok) return 0;
    }

    // 使用寻根后的 items 进行查找
    final currentItems = rxItems;
    index ??= currentItems.indexWhere((element) => element.id == id);

    if (!hasHelper || syncDb == false) {
      if (index >= 0) {
        await sync(index: index);
        _onFinalize('delete'.tr + 'success'.tr, showMessage, navBack);
        return 1;
      }
      return 0;
    }

    if (index == -1) {
      return await helper.deleteById(id);
    }

    final effect = await helper.deleteById(id);
    if (effect > 0) {
      if (helper.smallTable) {
        if (-1 == rxItems.indexWhere((item) => item.id == id)) {
          dprint('小表，记录[$id]可能已经被移除了，跳过 sync');
          _onFinalize('delete'.tr + 'success'.tr, showMessage, navBack);
          return effect;
        }
      }
      await sync(index: index);
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
    if (entity == null) {
      if (index < 0 || index >= rxItems.length) {
        throw Exception(
          'MyModelDelegate: index($index) out of range. must in range [0, ${rxItems.length})',
        );
      }

      await removeWithId(
        id: rxItems[index].id,
        index: index,
        syncDb: syncDb,
        deleteConfirm: deleteConfirm,
        title: title,
        showMessage: showMessage,
        navBack: navBack,
      );
    } else {
      await save(
        entity,
        index: index,
        syncDb: syncDb,
        showMessage: showMessage,
        navBack: navBack,
      );
    }
  }
}

class MyListDelegate<T> extends AbstractListDelegate<T> {
  MyListDelegate({
    super.delegate,
    super.rxItems,
    super.rxTotal,
    super.autoInit,
  });

  Future<void> save(T entity, int index, {bool unshift = true}) async {
    await sync(index: index, entity: entity, unshift: unshift);
  }

  /// 添加到最前面
  Future<void> insert(T entity) async {
    await save(entity, -1, unshift: true);
  }

  /// 添加到后面
  Future<void> push(T entity) async {
    await save(entity, -1, unshift: false);
  }

  Future<void> update(T entity, int index) async {
    await save(entity, index);
  }

  Future<void> removeAt(int index) async => await sync(index: index);
}

abstract class AbstractListDelegate<T> {
  AbstractListDelegate<T>? _parentDelegate;
  RxList<T>? _rxItems;
  RxInt? _rxTotal;

  // 回调函数
  Future<void> Function(int index)? afterUpdate;
  Future<void> Function(T record)? afterInsert;
  Future<void> Function(T oldRecord, int index)? afterDelete;
  Future<void> Function(DelegateAction action, {T? record, int? index})?
  delegateCallback;

  AbstractListDelegate({
    AbstractListDelegate<T>? delegate,
    RxList<T>? rxItems,
    RxInt? rxTotal,
    bool autoInit = true,
  }) {
    if (autoInit) {
      rxItems ??= RxList<T>();
      rxTotal ??= RxInt(0);
    }
    bind(rxItems: rxItems, rxTotal: rxTotal, delegate: delegate);
  }

  /// 统一的寻根逻辑;  注意，如果你直接修改 items，则不会触发回调函数
  RxList<T> get rxItems =>
      _parentDelegate?.rxItems ?? _rxItems ?? (throw _err('rxItems'));

  RxInt get rxTotal =>
      _parentDelegate?.rxTotal ?? _rxTotal ?? (throw _err('rxTotal'));

  RxInt? get __rxTotal => _parentDelegate?.rxTotal ?? _rxTotal;

  Exception _err(String name) => Exception('$runtimeType: 无法找到 $name。请绑定数据源。');

  void bind({
    RxList<T>? rxItems,
    RxInt? rxTotal,
    AbstractListDelegate<T>? delegate,
    Future<void> Function(int index)? afterUpdate,
    Future<void> Function(T record)? afterInsert,
    Future<void> Function(T oldRecord, int index)? afterDelete,
    Future<void> Function(DelegateAction action, {T? record, int? index})?
    delegateCallback,
  }) {
    if (rxItems != null) _rxItems = rxItems;
    if (rxTotal != null) _rxTotal = rxTotal;
    if (delegate != null) _parentDelegate = delegate;

    this.afterInsert = afterInsert ?? this.afterInsert;
    this.afterUpdate = afterUpdate ?? this.afterUpdate;
    this.afterDelete = afterDelete ?? this.afterDelete;
    this.delegateCallback = delegateCallback ?? this.delegateCallback;
  }

  /// 核心同步逻辑，同时更新 rxItems 和 rxTotal
  /// 删除: entity == null && index >= 0 触发 afterDelete 和 delegateCallback
  /// 添加: entity != null && index < 0 触发 afterInsert 和 delegateCallback
  /// 修改: entity != null && index >= 0 触发 afterUpdate 和 delegateCallback
  Future<void> sync({
    required int index,
    T? entity,
    bool unshift = true,
  }) async {
    final rootItems = rxItems;
    final rootTotal = __rxTotal;
    if (entity == null) {
      if (index >= 0 && index < rootItems.length) {
        final removed = rootItems.removeAt(index);
        rootTotal?.value--;
        await afterDelete?.call(removed, index);
        await delegateCallback?.call(
          DelegateAction.delete,
          record: removed,
          index: index,
        );
      } else {
        throw Exception(
          'AbstractListDelegate: index($index) out of range. must in range [0, ${rootItems.length})',
        );
      }
    } else {
      if (index >= 0 && index < rootItems.length) {
        rootItems[index] = entity;
        await afterUpdate?.call(index);
        await delegateCallback?.call(
          DelegateAction.update,
          record: entity,
          index: index,
        );
      } else if (index == -1) {
        unshift ? rootItems.insert(0, entity) : rootItems.add(entity);
        rootTotal?.value++;
        await afterInsert?.call(entity);
        await delegateCallback?.call(
          DelegateAction.insert,
          record: entity,
          index: index,
        );
      } else {
        throw Exception(
          'AbstractListDelegate: index($index) out of range. must in range [0, ${rootItems.length})',
        );
      }
    }
  }
}
