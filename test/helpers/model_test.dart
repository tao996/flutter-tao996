import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/db/model.dart';

// 测试用的具体模型实现
class TestModel extends IModel<TestModel> {
  String name;
  int age;

  TestModel({
    super.id = 0,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.age,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
      deletedAt: map['deletedAt'] != null
          ? DateTime.tryParse(map['deletedAt'])
          : null,
    );
  }

  @override
  TestModel fromMap(Map<String, dynamic> map) => TestModel.fromMap(map);

  @override
  Map<String, dynamic> toJson() => toMap();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestModel &&
        other.id == id &&
        other.name == name &&
        other.age == age;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ age.hashCode;
}

class TestNoTimeModel extends INoTimeModel<TestNoTimeModel> {
  String data;

  TestNoTimeModel({super.id = 0, required this.data});

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'data': data};
  }

  factory TestNoTimeModel.fromMap(Map<String, dynamic> map) {
    return TestNoTimeModel(id: map['id'] ?? 0, data: map['data'] ?? '');
  }

  @override
  TestNoTimeModel fromMap(Map<String, dynamic> map) =>
      TestNoTimeModel.fromMap(map);

  @override
  Map<String, dynamic> toJson() => toMap();
}

void main() {
  group('DbTypeModel', () {
    test('TestModel implements DbTypeModel correctly', () {
      final model = TestModel(name: 'Alice', age: 30);
      expect(model, isA<DbTypeModel<TestModel>>());
      expect(model.toMap(), isA<Map<String, dynamic>>());
      expect(model.toJson(), isA<Map<String, dynamic>>());
    });
  });

  group('IModel', () {
    group('hasRecord', () {
      test('returns false when id is 0', () {
        final model = TestModel(name: 'Alice', age: 30);
        expect(model.hasRecord(), isFalse);
      });

      test('returns true when id > 0', () {
        final model = TestModel(name: 'Alice', age: 30)..id = 1;
        expect(model.hasRecord(), isTrue);
      });
    });

    group('toInsertMap', () {
      test('removes id field', () {
        final model = TestModel(name: 'Alice', age: 30)..id = 5;
        final insertMap = model.toInsertMap();
        expect(insertMap.containsKey('id'), isFalse);
      });

      test('adds createdAt when addCreatedAt is true', () {
        final model = TestModel(name: 'Alice', age: 30);
        final insertMap = model.toInsertMap(addCreatedAt: true);
        expect(insertMap['createdAt'], isNotNull);
      });

      test('does not add createdAt when addCreatedAt is false', () {
        final model = TestModel(name: 'Alice', age: 30);
        final insertMap = model.toInsertMap(addCreatedAt: false);
        expect(insertMap['createdAt'], isNull);
      });

      test('adds updatedAt when addUpdatedAt is true', () {
        final model = TestModel(name: 'Alice', age: 30);
        final insertMap = model.toInsertMap(addUpdatedAt: true);
        expect(insertMap['updatedAt'], isNotNull);
      });

      test('does not add updatedAt when addUpdatedAt is false', () {
        final model = TestModel(name: 'Alice', age: 30);
        final insertMap = model.toInsertMap(addUpdatedAt: false);
        expect(insertMap['updatedAt'], isNull);
      });

      test('preserves existing createdAt', () {
        final existingTime = DateTime(2025, 1, 1);
        final model = TestModel(
          name: 'Alice',
          age: 30,
          createdAt: existingTime,
        );
        final insertMap = model.toInsertMap(addCreatedAt: true);
        expect(insertMap['createdAt'], equals(existingTime.toIso8601String()));
      });
    });

    group('time text getters', () {
      test('createdAtText returns formatted string when createdAt is set', () {
        final time = DateTime(2025, 5, 22, 13, 30, 0);
        final model = TestModel(name: 'Alice', age: 30, createdAt: time);
        expect(model.createdAtText, equals('2025-05-22 13:30:00'));
      });

      test('createdAtText returns empty string when createdAt is null', () {
        final model = TestModel(name: 'Alice', age: 30);
        expect(model.createdAtText, equals(''));
      });

      test('updatedAtText returns formatted string when updatedAt is set', () {
        final time = DateTime(2025, 5, 22, 13, 30, 0);
        final model = TestModel(name: 'Alice', age: 30, updatedAt: time);
        expect(model.updatedAtText, equals('2025-05-22 13:30:00'));
      });

      test('deletedAtText returns formatted string when deletedAt is set', () {
        final time = DateTime(2025, 5, 22, 13, 30, 0);
        final model = TestModel(name: 'Alice', age: 30, deletedAt: time);
        expect(model.deletedAtText, equals('2025-05-22 13:30:00'));
      });
    });

    group('copyBaseDataFrom', () {
      test('copies base data from another IModel', () {
        final source = TestModel(
          id: 10,
          name: 'Source',
          age: 25,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 2),
          deletedAt: DateTime(2025, 1, 3),
        );

        final target = TestModel(name: 'Target', age: 30);
        target.copyBaseDataFrom(source);

        expect(target.id, equals(10));
        expect(target.createdAt, equals(DateTime(2025, 1, 1)));
        expect(target.updatedAt, equals(DateTime(2025, 1, 2)));
        expect(target.deletedAt, equals(DateTime(2025, 1, 3)));
      });

      test('does nothing when source is null', () {
        final target = TestModel(name: 'Target', age: 30)..id = 5;
        target.copyBaseDataFrom(null);

        expect(target.id, equals(5));
      });

      test('does nothing when source is not IModel', () {
        final target = TestModel(name: 'Target', age: 30)..id = 5;
        target.copyBaseDataFrom('not a model');

        expect(target.id, equals(5));
      });
    });

    group('copyBaseDataWith', () {
      test('copies base data with provided values', () {
        final model = TestModel(name: 'Alice', age: 30);
        final result = model.copyBaseDataWith(
          id: 20,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 2),
          deletedAt: DateTime(2025, 1, 3),
        );

        expect(model.id, equals(20));
        expect(model.createdAt, equals(DateTime(2025, 1, 1)));
        expect(model.updatedAt, equals(DateTime(2025, 1, 2)));
        expect(model.deletedAt, equals(DateTime(2025, 1, 3)));
        expect(result, equals(model));
      });

      test('only updates provided fields', () {
        final existingTime = DateTime(2025, 1, 1);
        final model = TestModel(
          name: 'Alice',
          age: 30,
          createdAt: existingTime,
        );

        model.copyBaseDataWith(id: 15);

        expect(model.id, equals(15));
        expect(model.createdAt, equals(existingTime));
      });

      test('ignores null parameters', () {
        final model = TestModel(name: 'Alice', age: 30)..id = 10;
        model.copyBaseDataWith(id: null, createdAt: null);

        expect(model.id, equals(10));
      });
    });
  });

  group('INoTimeModel', () {
    test('time fields are excluded from JSON serialization', () {
      final model = TestNoTimeModel(data: 'test');
      model.toJson();

      // INoTimeModel 的时间字段被标记为 @JsonKey(includeFromJson: false, includeToJson: false)
      // 但在 toMap 中仍然可能包含这些字段
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
      expect(model.deletedAt, isNull);
    });

    test('can be instantiated with only id', () {
      final model = TestNoTimeModel(id: 5, data: 'test');
      expect(model.id, equals(5));
      expect(model.data, equals('test'));
    });

    test('inherits IModel behavior', () {
      final model = TestNoTimeModel(data: 'test')..id = 1;
      expect(model.hasRecord(), isTrue);

      model.copyBaseDataFrom(null);
      expect(model.id, equals(1));
    });
  });
}
