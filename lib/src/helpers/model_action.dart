import 'package:tao996/tao996.dart';

enum IModelAction { insert, insertLastId, update, delete }

class IModelActionResult {
  final IModelAction name;
  final dynamic data;

  IModelActionResult(this.name, {this.data});
}

class ModelAction<T extends IModel> {
  Future<void> Function(IModelActionResult)? _successAction;
  Future<int> Function()? _updateAction;
  Future<T> Function()? _insertAction;
  Future<int> Function()? _insertLastIdAction;
  Future<int> Function()? _deleteAction;

  ModelAction addSuccess(Future<void> Function(IModelActionResult) action) {
    _successAction = action;
    return this;
  }

  ModelAction addUpdate(Future<int> Function() action) {
    _updateAction = action;
    return this;
  }

  ModelAction addInsert(Future<T> Function() action) {
    _insertAction = action;
    return this;
  }

  ModelAction addInsertLastId(Future<int> Function() action) {
    _insertLastIdAction = action;
    return this;
  }

  ModelAction addDelete(Future<int> Function() action) {
    _deleteAction = action;
    return this;
  }

  Future<void> execute() async {
    try {
      if (_insertAction != null) {
        final result = await _insertAction!();
        await _successAction?.call(
          IModelActionResult(IModelAction.insert, data: result),
        );
      } else if (_insertLastIdAction != null) {
        final id = await _insertLastIdAction!();
        if (id > 0) {
          await _successAction?.call(
            IModelActionResult(IModelAction.insertLastId, data: id),
          );
        } else {
          getIMessageService().error('添加数据失败');
        }
      } else if (_updateAction != null) {
        final result = await _updateAction!();
        if (result > 0) {
          await _successAction?.call(IModelActionResult(IModelAction.update));
        } else {
          getIMessageService().error('没有任务记录被更新');
        }
      } else if (_deleteAction != null) {
        final result = await _deleteAction!();
        if (result > 0) {
          await _successAction?.call(IModelActionResult(IModelAction.delete));
        } else {
          getIMessageService().error('没有任务记录被删除');
        }
      }
    } catch (e, st) {
      getIDebugService().exception(e, st, errorMessage: e.toString());
    }
  }
}
