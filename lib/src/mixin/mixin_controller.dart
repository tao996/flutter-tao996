import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

/// 更新记录列表（不需要 IModel）
/// [items] 原有的列表；[record] 新的记录；[index] 索引；[unshift] 是否在头部添加
/// 如果 [record]==null并且 [index]不为0则表示删除
Future<void> syncListState({
  RxList<dynamic>? items,
  required int index,
  dynamic entity,
  RxInt? total,
  bool unshift = true,
}) async {
  // 分支 1：删除逻辑 (Entity 为空)
  if (entity == null) {
    if (index >= 0 && items != null) {
      items.removeAt(index);
      total?.value--;
    }
    return;
  }

  // 分支 2：更新逻辑 (Index 有效)
  if (index >= 0) {
    items?[index] = entity;
  }
  // 分支 3：新增逻辑 (Index 为负)
  else {
    if (items != null) {
      unshift ? items.insert(0, entity) : items.add(entity);
      total?.value++;
    }
  }
}

mixin MixinTao996Controller<T extends IModel> {
  // 是否正在执行
  RxBool isDoing = false.obs;

  /// 是否编辑记录
  RxBool isEdit = false.obs;

  /// 在 [useEntitySave] 和 [useEntityDeleteDirect] 操作之后触发
  /// 通常用于更新记录列表
  Future<void> trigger(dynamic entity, int index) async {}

  /// 添加或修改实体
  /// 根据服务 [service] 对实体 [entity] 进行添加或修改操作；并自动触发 [selfUpdateData] 操作;
  /// [navigateBack] 操作成功之后，是否返回上一个页面
  Future<void> useEntitySave({
    required ModelHelper service,
    required dynamic entity,
    required int index,
    RxList<dynamic>? items,
    RxInt? total,
    bool navigateBack = true,
  }) async {
    final action = ModelAction();
    try {
      isDoing.value = true;
      var message = '';
      if (index >= 0) {
        action
            .addUpdate(() {
              return service.update(entity);
            })
            .afterUpdateSuccess((_) async {
              message = 'save'.tr + 'success'.tr;
              await syncListState(
                items: items,
                index: index,
                entity: entity,
                total: total,
              );
              await trigger(entity, index);
            });
      } else {
        action
            .addInsert(() {
              return service.insert(entity);
            })
            .afterInsertSuccess((newRecord) async {
              message = 'add'.tr + 'success'.tr;
              await syncListState(
                items: items,
                index: -1,
                entity: newRecord,
                total: total,
              );
              await trigger(newRecord, index);
            });
      }

      await action.execute(
        success: () async {
          if (navigateBack) {
            goBack();
          }
          getIMessageService().success(message);
        },
      );
    } catch (e, st) {
      getIDebugService().exception(e, st, errorMessage: e.toString());
    } finally {
      isDoing.value = false;
    }
  }

  /// 删除实体操作
  /// [service] 删除实体的服务类；[id] 待删除记录的 ID；
  /// [items] 记录列表, [index] 待删除的记录在 [items]中的索引；
  ///  如果删除成功，则会触发 [selfUpdateData]；
  /// [navigateBack] 是否返回上一级
  Future<void> useEntityDelete({
    required String title,
    required ModelHelper service,
    required RxList<T> items,
    required int index,
    RxInt? total,
    bool deleteConfirm = true,
    bool navigateBack = true,
  }) async {
    await useEntityDeleteWithId(
      title: title,
      service: service,
      id: items[index].id,
      items: items,
      index: index,
      total: total,
      deleteConfirm: deleteConfirm,
      navigateBack: navigateBack,
    );
  }

  /// 通过 id 来删除记录
  Future<void> useEntityDeleteWithId({
    required String title,
    required ModelHelper service,
    required int id,
    RxList<T>? items,
    required int index,
    RxInt? total,
    bool deleteConfirm = true,
    bool navigateBack = true,
  }) async {
    try {
      if (deleteConfirm) {
        await getIMessageService().deleteConfirm(title, () async {
          await useEntityDeleteDirect(
            service: service,
            index: index,
            items: items,
            total: total,
            id: id,
            navigateBack: navigateBack,
          );
        });
      } else {
        await useEntityDeleteDirect(
          service: service,
          index: index,
          items: items,
          total: total,
          id: id,
          navigateBack: navigateBack,
        );
      }
    } catch (e, st) {
      getIDebugService().exception(e, st, errorMessage: e.toString());
    } finally {
      isDoing.value = false;
    }
  }

  /// 直接删除实体
  /// [service] 删除实体的服务类；[id] 待删除记录的 ID；
  /// [items] 记录列表, [index] 待删除的记录在 [items]中的索引；
  ///  如果删除成功，则会触发 [selfEntityUpdateWith]；
  /// [navigateBack] 是否返回上一级
  Future<void> useEntityDeleteDirect({
    required ModelHelper service,
    required int index,
    required int id,
    RxList<dynamic>? items,
    RxInt? total,
    bool navigateBack = true,
  }) async {
    try {
      isDoing.value = true;
      final effect = await service.deleteById(id);
      if (effect > 0) {
        await syncListState(
          items: items,
          entity: null,
          index: index,
          total: total,
        );
        await trigger(null, index);
        if (navigateBack) {
          goBack();
        }
        getIMessageService().success('delete'.tr + 'success'.tr);
      } else {
        getIMessageService().error('noRecordDelete'.tr); // 没有删除的记录
      }
    } catch (e, st) {
      getIDebugService().exception(e, st, errorMessage: e.toString());
    } finally {
      isDoing.value = false;
    }
  }
}
