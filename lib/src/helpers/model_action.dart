import 'package:tao996/tao996.dart';

class ModelAction {
  final ModelActionHelper helper = getModelActionHelper();

  Future<void> Function(dynamic)? _successAction;
  Future<int> Function()? _updateAction;
  Future<IModel> Function()? _insertAction;
  Future<int> Function()? _insertLastIdAction;
  Future<int> Function()? _deleteAction;

  ModelAction addSuccess(Future<void> Function(dynamic) action) {
    _successAction = action;
    return this;
  }

  ModelAction addUpdate(Future<int> Function() action) {
    _updateAction = action;
    return this;
  }

  ModelAction addInsert(Future<IModel> Function() action) {
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
    if (_insertAction != null) {
      await helper.insert(_insertAction!, success: _successAction);
    } else if (_insertLastIdAction != null) {
      await helper.insertLastId(
        _insertLastIdAction!,
        success: () async {
          _successAction?.call(null);
        },
      );
    } else if (_updateAction != null) {
      await helper.update(
        _updateAction!,
        success: () async {
          _successAction?.call(null);
        },
      );
    } else if (_deleteAction != null) {
      await helper.delete(
        _deleteAction!,
        success: () async {
          _successAction?.call(null);
        },
      );
    }
  }
}
