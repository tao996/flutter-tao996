import 'package:get/get.dart';

final RegExp doublePattern = RegExp(r'^[-+]?[0-9]*\.?[0-9]+$');
final RegExp integerPattern = RegExp(r'^[-+]?[0-9]+$');

class AssertUtil {
  const AssertUtil();

  /// check if a string is a integer
  bool isInteger(String? str, {String? title}) {
    final result = str != null && integerPattern.hasMatch(str);
    if (!result && title != null) {
      throw ArgumentError('mustInteger'.trParams({'title': title}));
    }
    return result;
  }

  bool isEmpty(dynamic data) {
    // 1. 处理 null 情况
    if (data == null) {
      return true;
    }

    // 2. 基础类型判断（修复 switch case 语法，兼容 Dart 类型规范）
    if (data is int || data is double) {
      return data == 0;
    }

    if (data is String) {
      return data.trim().isEmpty;
    }

    // 3. 扩展支持常见集合类型（List/Set/Map）
    if (data is List) {
      return data.isEmpty;
    }

    if (data is Set) {
      return data.isEmpty;
    }

    if (data is Map) {
      return data.isEmpty;
    }

    // 4. 支持 Iterable 类型（如 Iterable、Iterator 等）
    if (data is Iterable) {
      return data.isEmpty;
    }

    // 5. 支持 DateTime 等特殊类型（可选，根据业务需求调整）
    if (data is DateTime) {
      return false; // DateTime 不存在 "空" 的概念，返回 false
    }

    // 6. 其他未匹配类型默认返回 false
    return false;
  }
}
