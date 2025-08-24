import 'package:tao996/tao996.dart';

class ModelActionHelper {
  final IDebugMessageService messageService;

  ModelActionHelper(this.messageService);

  void actionWith(
    bool condition, {
    String successMessageText = '操作成功',
    Future<void> Function()? success,
    String errorMessageText = '操作失败',
    Future<void> Function()? error,
    bool showSuccessMessage = true,
  }) {
    if (condition) {
      if (success != null) {
        success();
      } else if (showSuccessMessage) {
        messageService.success(successMessageText);
      }
    } else {
      messageService.error(errorMessageText);
    }
  }

  Future<void> insert(
    Future<IModel> Function() action, {
    Future<void> Function()? success,
  }) async {
    try {
      final result = await action();
      actionWith(
        result.id > 0,
        successMessageText: '插入成功',
        errorMessageText: '插入失败, 请检查数据是否正确',
        success: success,
      );
    } catch (e) {
      messageService.error('插入失败: ${e.toString()}');
    }
  }

  Future<void> insertLastId(
    Future<int> Function() action, {
    Future<void> Function()? success,
  }) async {
    try {
      final result = await action();
      actionWith(
        result > 0,
        successMessageText: '插入成功',
        errorMessageText: '插入失败, 请检查数据是否正确',
        success: success,
      );
    } catch (e) {
      messageService.error('插入失败: ${e.toString()}');
    }
  }

  Future<void> update(
    Future<int> Function() action, {
    int expectedRows = 1,
    Future<void> Function()? success,
  }) async {
    try {
      final rowsAffected = await action();
      actionWith(
        rowsAffected >= expectedRows,
        successMessageText: '更新成功',
        errorMessageText: '更新失败, 请检查数据是否正确',
        success: success,
      );
    } catch (e) {
      messageService.error('更新失败: ${e.toString()}');
    }
  }

  Future<void> delete(
    Future<int> Function() action, {
    int expectedRows = 1,
    Future<void> Function()? success,
  }) async {
    try {
      final rowsAffected = await action();
      actionWith(
        rowsAffected >= expectedRows,
        successMessageText: '删除成功',
        errorMessageText: '删除失败, 请检查数据是否正确',
        success: success,
      );
    } catch (e) {
      messageService.error('删除失败: ${e.toString()}');
    }
  }
}
