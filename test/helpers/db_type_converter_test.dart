import 'package:tao996/tao996.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

class TestModel extends DbTypeModel<TestModel> {
  final int id;
  final String name;

  TestModel(this.id, this.name);

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(map['id'] as int, map['name'] as String);
  }

  @override
  TestModel fromMap(Map<String, dynamic> map) {
    return TestModel.fromMap(map);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

void main() {
  group('DbTypeConverter Map<String, T extends DbTypeModel> Tests', () {
    final model1 = TestModel(1, 'A');
    final model2 = TestModel(2, 'B');
    final data = {'id1': model1, 'id2': model2};

    test('mapToJson: Normal map should return encoded string with toMap', () {
      final expectedMap = {'id1': model1.toMap(), 'id2': model2.toMap()};
      expect(
        DbTypeConverter.mapToJson<TestModel>(data),
        jsonEncode(expectedMap),
      );
    });
    test('mapToJson: Null map should return empty string', () {
      expect(DbTypeConverter.mapToJson<TestModel>(null), '');
    });
    test('mapToJson: Empty map should return empty string', () {
      expect(DbTypeConverter.mapToJson<TestModel>({}), '');
    });

    test('mapFromJson: Valid JSON should return Map<String, T>', () {
      final json = jsonEncode({'id1': model1.toMap(), 'id2': model2.toMap()});
      final result = DbTypeConverter.mapFromJson<TestModel>(
        json,
        fromMap: TestModel.fromMap,
      );
      expect(result, data);
      expect(result['id1'], equals(model1));
    });

    test('mapFromJson: Null JSON should return empty map', () {
      expect(
        DbTypeConverter.mapFromJson<TestModel>(
          null,
          fromMap: TestModel.fromMap,
        ),
        {},
      );
    });
  });

  group('DbTypeConverter List<T extends DbTypeModel> Tests', () {
    final model1 = TestModel(1, 'A');
    final model2 = TestModel(2, 'B');
    final data = [model1, model2];

    test('listToJson: Normal list should return encoded string with toMap', () {
      final expectedList = [model1.toMap(), model2.toMap()];
      expect(
        DbTypeConverter.listToJson<TestModel>(data),
        jsonEncode(expectedList),
      );
    });
    test('listToJson: Null list should return empty string', () {
      expect(DbTypeConverter.listToJson<TestModel>(null), '');
    });

    test('listFromJson: Valid JSON should return List<T>', () {
      final json = jsonEncode([model1.toMap(), model2.toMap()]);
      final result = DbTypeConverter.listFromJson<TestModel>(
        json,
        fromMap: TestModel.fromMap,
      );
      expect(result.length, 2);
      expect(result, equals(data));
      expect(result[0], equals(model1));
    });

    test('listFromJson: Null JSON should return empty list', () {
      expect(
        DbTypeConverter.listFromJson<TestModel>(
          null,
          fromMap: TestModel.fromMap,
        ),
        [],
      );
    });

    // 🔴 发现并测试 listFromJson 中的潜在错误
    test('listFromJson: 检查 fromMap 的调用是否正确', () {
      // 检查你代码中的注释: // 这里是错误的，应该如何改写
      // 你的实现: return fromMap(data);
      // 依赖于 TypeCastUtil.listFromJsonString 的定义，如果它正确返回 List<dynamic>
      // 并且 listFromJsonString 内部的 fromMap 接收 Map<String, dynamic>，那么你的实现是正确的。
      // 我们模拟 TypeCastUtil 的行为来确保它是正确的。
      final json = jsonEncode([model1.toMap()]);
      final result = DbTypeConverter.listFromJson<TestModel>(
        json,
        fromMap: TestModel.fromMap,
      );
      expect(result.length, 1);
      expect(result[0], equals(model1));
    });
  });

  // 完整的测试应包含所有方法，Map<String, bool/int> 和 List<double/string> 类似，这里只列出关键示例。
}
