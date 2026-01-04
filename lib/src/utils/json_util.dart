import 'dart:convert';

import 'package:tao996/tao996.dart';

class JsonMap {
  final IDebugService _debugService = getIDebugService();
  late Map<String, dynamic> _map;
  bool _hasContent = false;

  JsonMap({String? content}) {
    setContent(content);
  }

  /// 返回 content 是否被正确的 decode
  bool setContent(String? content) {
    if (content == null || content.isEmpty) {
      _map = {};
      return false;
    }
    content = content.trim();
    if (content.length < 2) {
      _map = {};
      return false;
    }
    _hasContent = true;
    try {
      _map = jsonDecode(content);
    } catch (error, stackTrace) {
      _debugService.exception(
        error,
        stackTrace,
        errorMessage: "JsonMap.setContent error",
      );
      _map = {};
      return false;
    }
    return true;
  }

  /// 原始数据是否有内容
  bool get hasContent => _hasContent;

  /// JsonDecode 后的数据
  Map<String, dynamic> get map => _map;

  dynamic get(String key) {
    return _map[key];
  }

  void set(String key, dynamic value) {
    _map[key] = value;
  }

  int getInt(String key) {
    return tu.data.getInt(_map[key]);
  }

  String getString(String key) {
    return tu.data.getString(_map[key]);
  }

  bool getBool(String key) {
    return tu.data.getBool(_map[key]);
  }

  double getDouble(String key) {
    return tu.data.getDouble(_map[key]);
  }

  DateTime? getDateTime(String key) {
    return tu.data.getDateTime(_map[key]);
  }
  @override
  String toString() {
    return jsonEncode(_map);
  }
}
