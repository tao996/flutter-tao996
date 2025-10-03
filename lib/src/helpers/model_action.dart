import 'package:tao996/tao996.dart';

class ModelAction<T extends IModel> {
  Future<int> Function()? _updateAction;
  Future<T> Function()? _insertAction;
  Future<int> Function()? _insertLastIdAction;
  Future<int> Function()? _deleteAction;

  Future<void> Function(int)? _afterUpdateSuccess;
  Future<void> Function(T)? _afterInsertSuccess;
  Future<void> Function(int)? _afterDeleteSuccess;
  Future<void> Function(int)? _afterLastIdSuccess;

  /// 添加更新操作，并要求 [action] 返回更新记录的数量
  ModelAction addUpdate(Future<int> Function() action) {
    _updateAction = action;
    return this;
  }

  ModelAction afterUpdateSuccess(Future<void> Function(int) callback) {
    _afterUpdateSuccess = callback;
    return this;
  }

  /// 添加插入操作，并要求 [action] 返回模型
  ModelAction addInsert(Future<T> Function() action) {
    _insertAction = action;
    return this;
  }

  ModelAction afterInsertSuccess(Future<void> Function(T) callback) {
    _afterInsertSuccess = callback;
    return this;
  }

  /// 添加插入操作，并要求 [action] 返回最后插入的ID
  ModelAction addInsertLastId(Future<int> Function() action) {
    _insertLastIdAction = action;
    return this;
  }

  ModelAction afterLastIdSuccess(Future<void> Function(int) callback) {
    _afterLastIdSuccess = callback;
    return this;
  }

  /// 添加删除操作，并要求 [action] 返回删除的行数
  ModelAction addDelete(Future<int> Function() action) {
    _deleteAction = action;
    return this;
  }

  ModelAction afterDeleteSuccess(Future<void> Function(int) callback) {
    _afterDeleteSuccess = callback;
    return this;
  }

  Future<void> execute({Future<void> Function()? success}) async {
    if (_insertAction != null) {
      final result = await _insertAction!();
      await _afterInsertSuccess?.call(result);
    } else if (_insertLastIdAction != null) {
      final id = await _insertLastIdAction!();
      if (id > 0) {
        await _afterLastIdSuccess?.call(id);
      } else {
        getIMessageService().error('添加数据失败');
      }
    } else if (_updateAction != null) {
      final result = await _updateAction!();
      if (result > 0) {
        await _afterUpdateSuccess?.call(result);
      } else {
        getIMessageService().error('没有任务记录被更新');
      }
    } else if (_deleteAction != null) {
      final result = await _deleteAction!();
      if (result > 0) {
        await _afterDeleteSuccess?.call(result);
      } else {
        getIMessageService().error('没有任务记录被删除');
      }
    }
    await success?.call();
  }
}
