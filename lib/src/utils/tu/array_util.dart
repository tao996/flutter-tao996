class ArrayUtil {
  const ArrayUtil();

  /// 求交集 (Intersection): 同时存在于两个列表中的元素
  List<T> intersection<T>(List<T> a, List<T> b) {
    return a.toSet().intersection(b.toSet()).toList();
  }

  /// 批量对比 (Batch Compare): 批量对比两个列表的元素，并返回插入、删除、更新的元素
  ///
  /// [compare]: 比较函数，返回 true 表示两个元素相等
  ///
  /// [insertion]: 新增元素列表，在 [b] 中存在，但不在 [a] 中
  ///
  /// [deletion]: 删除元素列表, 在 [a] 中存在，但不在 [b] 中
  ///
  /// [update]: 更新元素列表, 在 [a] 中存在，[b] 中存在，取的是 [b] 中的新元素
  void deepCompare<T>(
    List<T> a,
    List<T> b,
    bool Function(T a, T b) compare,
    void Function(List<T> items) insertion,
    void Function(List<T> items) deletion,
    void Function(List<T> items) update,
  ) {
    final List<T> insertions = [];
    final List<T> deletions = [];
    final List<T> updates = [];

    // 用于标记 b 中已被匹配的元素（避免重复匹配）
    final List<bool> matchedInB = List.filled(b.length, false);

    // 第一步：找出需要删除和更新的元素
    for (final itemA in a) {
      bool found = false;

      for (int i = 0; i < b.length; i++) {
        if (!matchedInB[i] && compare(itemA, b[i])) {
          // 匹配成功
          found = true;
          matchedInB[i] = true;
          updates.add(b[i]);
          break;
        }
      }

      if (!found) {
        // 在 b 中未找到匹配，需要删除
        deletions.add(itemA);
      }
    }

    // 第二步：找出需要新增的元素（b 中未被匹配的元素）
    for (int i = 0; i < b.length; i++) {
      if (!matchedInB[i]) {
        insertions.add(b[i]);
      }
    }

    // 执行回调
    insertion(insertions);
    deletion(deletions);
    update(updates);
  }

  /// 交集
  List<T> deepIntersection<T>(
    List<T> a,
    List<T> b,
    bool Function(T a, T b) compare,
  ) {
    final result = <T>[];

    for (final itemA in a) {
      // 检查 itemA 是否在 b 中存在匹配项，且尚未被添加到结果中
      bool found = false;
      for (final itemB in b) {
        if (compare(itemA, itemB)) {
          // 确保结果列表中还没有通过相同规则匹配到此元素
          bool alreadyInResult = false;
          for (final resItem in result) {
            if (compare(resItem, itemA)) {
              alreadyInResult = true;
              break;
            }
          }
          if (!alreadyInResult) {
            result.add(itemA);
          }
          found = true;
          break; // 找到第一个匹配即可跳出内层循环
        }
      }
      if (!found) {
        // 可选：可以在这里处理未找到的情况，当前逻辑无需额外操作
      }
    }

    return result;
  }

  /// 求并集 (Union): 两个列表的所有元素，会自动去重
  List<T> union<T>(List<T> a, List<T> b) {
    return a.toSet().union(b.toSet()).toList();
  }

  /// 求差集 (Difference): 在 [a] 中存在，但 [b] 中不存在的元素
  List<T> difference<T>(List<T> a, List<T> b) {
    return a.toSet().difference(b.toSet()).toList();
  }

  /// 深层差集 (Deep Difference): 返回在 [a] 中存在，但在 [b] 中不存在的元素
  ///
  /// [compare]: 比较函数，返回 true 表示两个元素相等
  ///
  /// 注意：结果列表会自动去重，避免重复元素
  List<T> deepDifference<T>(
    List<T> a,
    List<T> b,
    bool Function(T a, T b) compare,
  ) {
    final result = <T>[];

    // 标记 b 中已经被匹配的元素（可选，用于优化）
    final matchedInB = List<bool>.filled(b.length, false);

    for (final itemA in a) {
      bool found = false;

      for (int i = 0; i < b.length; i++) {
        if (!matchedInB[i] && compare(itemA, b[i])) {
          found = true;
          matchedInB[i] = true;
          break;
        }
      }

      // 如果在 b 中没找到，则添加到结果中
      if (!found) {
        // 去重：检查结果中是否已经存在相同的元素（根据 compare 规则）
        bool alreadyInResult = false;
        for (final resItem in result) {
          if (compare(resItem, itemA)) {
            alreadyInResult = true;
            break;
          }
        }

        if (!alreadyInResult) {
          result.add(itemA);
        }
      }
    }

    return result;
  }

  List<T> unique<T>(Iterable<T> list) {
    return list.toSet().toList();
  }

  /// 降维 (Flatten): 将多维列表降维为 1D
  List<T> flatten<T>(List<List<T>> list) {
    return list.expand((i) => i).toList();
  }
}
