class ArrayUtil {
  const ArrayUtil();

  /// 求交集 (Intersection): 同时存在于两个列表中的元素
  List<T> intersection<T>(List<T> a, List<T> b) {
    return a.toSet().intersection(b.toSet()).toList();
  }

  /// 求并集 (Union): 两个列表的所有元素，会自动去重
  List<T> union<T>(List<T> a, List<T> b) {
    return a.toSet().union(b.toSet()).toList();
  }

  /// 求差集 (Difference): 在 a 中但不在 b 中的元素
  List<T> difference<T>(List<T> a, List<T> b) {
    return a.toSet().difference(b.toSet()).toList();
  }

  List<T> unique<T>(Iterable<T> list) {
    return list.toSet().toList();
  }

  /// 降维 (Flatten): 将多维列表降维为 1D
  List<T> flatten<T>(List<List<T>> list) {
    return list.expand((i) => i).toList();
  }
}
