import 'package:tao996/tao996.dart';

class ModelActionHelper {
  final IDebugMessageService messageService;

  ModelActionHelper(this.messageService);

  void actionWith(
    bool condition, {
    bool showSuccessMessage = true,
    required String successMessageText,
    void Function()? success,
    bool showErrorMessage = true,
    required String errorMessageText,
    void Function()? error,
  }) {
    if (condition) {
      if (success != null) {
        success();
      } else if (showSuccessMessage) {
        messageService.success(successMessageText);
      }
    } else {
      if (error != null) {
        error();
      } else if (showErrorMessage) {
        messageService.error(errorMessageText);
      }
    }
  }

  void insert(
    Future<dynamic> Function() action, {
    void Function()? success,
  }) async {
    try {
      await action();
    } catch (e) {
      messageService.error(e.toString());
    }
  }

  void update(
    Future<int> Function() action, {
    int get = 1,
    void Function()? success,
  }) async {
    try {
      actionWith(
        await action() >= get,
        successMessageText: '更新成功',
        errorMessageText: '更新失败',
        success: success,
      );
    } catch (e) {
      messageService.error(e.toString());
    }
  }

  void delete(
    Future<int> Function() action, {
    int get = 1,
    void Function()? success,
  }) async {
    try {
      actionWith(
        await action() >= get,
        successMessageText: '删除成功',
        errorMessageText: '删除失败',
        success: success,
      );
    } catch (e) {
      messageService.error(e.toString());
    }
  }
}

class ModelAction {
  final ModelActionHelper helper = getModelActionHelper();
  void Function()? _success;
  Future<int> Function()?  _updateAction;
  Future<dynamic> Function()? _insertAction;

  ModelAction addSuccess(void Function()? value) {
    _success = value;
    return this;
  }

  ModelAction addUpdate(Future<int> Function() action) {
    _updateAction = action;
    return this;
  }

  ModelAction addInsert(Future<dynamic> Function() action) {
    _insertAction = action;
    return this;
  }

  ModelAction execute({
    bool insertCondition = false,
    bool updateCondition = false,
  }) {
    if (insertCondition) {
      if (_insertAction != null) {
        helper.insert(_insertAction!, success: _success);
      }
    }
    if (updateCondition) {
      if (_updateAction != null) {
        helper.update(_updateAction!, success: _success);
      }
    }
    return this;
  }
}
