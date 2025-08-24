import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/tao996.dart';
// Import the file containing the CastUtil class

// Helper class for testing
class MyObject {
  final String name;
  final int value;

  MyObject(this.name, this.value);

  // Method to convert the object to a map
  Map<String, dynamic> toData() {
    return {
      'name': name,
      'value': value,
    };
  }

  // Factory constructor to create an object from a map
  factory MyObject.fromData(Map<String, dynamic> data) {
    return MyObject(data['name'] as String, data['value'] as int);
  }

  // Override equality for testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MyObject &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}

void main() {
  group('CastUtil', () {
    // Test data
    final MyObject obj1 = MyObject('test1', 1);
    final MyObject obj2 = MyObject('test2', 2);
    final MyObject obj3 = MyObject('test3', 3);

    // -------------------------------------------------------------------------
    // castList<T> and castListFromData<T>
    // -------------------------------------------------------------------------
    group('castList and castListFromData', () {
      test('should correctly cast a List of objects to a List of maps', () {
        final List<MyObject> originalList = [obj1, obj2];
        final List<Map<String, dynamic>> result = CastUtil.castList(
          originalList,
              (obj) => obj.toData(),
        );

        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 2);
        expect(result[0]['name'], 'test1');
        expect(result[0]['value'], 1);
      });

      test('should correctly cast a List of maps back to a List of objects', () {
        final dynamic data = [
          {'name': 'test1', 'value': 1},
          {'name': 'test2', 'value': 2},
        ];
        final List<MyObject> result = CastUtil.castListFromData(
          data,
              (map) => MyObject.fromData(map),
        );

        expect(result, isA<List<MyObject>>());
        expect(result.length, 2);
        expect(result[0], equals(obj1));
        expect(result[1], equals(obj2));
      });

      test('should throw ArgumentError if data is not a List', () {
        expect(
              () => CastUtil.castListFromData('not a list', (map) => MyObject.fromData(map)),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError if list elements are not Maps', () {
        final dynamic data = ['invalid_element', 123];
        expect(
              () => CastUtil.castListFromData(data, (map) => MyObject.fromData(map)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // -------------------------------------------------------------------------
    // castMap<T> and castMapFromData<T>
    // -------------------------------------------------------------------------
    group('castMap and castMapFromData', () {
      test('should correctly cast a Map of objects to a Map of maps', () {
        final Map<String, MyObject> originalMap = {'one': obj1, 'two': obj2};
        final Map<String, dynamic> result = CastUtil.castMap(
          originalMap,
              (obj) => obj.toData(),
        );

        expect(result, isA<Map<String, dynamic>>());
        expect(result.keys.length, 2);
        expect(result['one']['name'], 'test1');
        expect(result['two']['value'], 2);
      });

      test('should correctly cast a Map of maps back to a Map of objects', () {
        final dynamic data = {
          'one': {'name': 'test1', 'value': 1},
          'two': {'name': 'test2', 'value': 2},
        };
        final Map<String, MyObject> result = CastUtil.castMapFromData(
          data,
              (map) => MyObject.fromData(map),
        );

        expect(result, isA<Map<String, MyObject>>());
        expect(result.keys.length, 2);
        expect(result['one'], equals(obj1));
        expect(result['two'], equals(obj2));
      });

      test('should throw ArgumentError if data is not a Map', () {
        expect(
              () => CastUtil.castMapFromData('not a map', (map) => MyObject.fromData(map)),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError if map values are not Maps', () {
        final dynamic data = {'one': 'invalid_value', 'two': 123};
        expect(
              () => CastUtil.castMapFromData(data, (map) => MyObject.fromData(map)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // -------------------------------------------------------------------------
    // Basic type list conversion
    // -------------------------------------------------------------------------
    group('Basic type list conversion', () {
      test('should correctly cast List<dynamic> to List<int>', () {
        final dynamic data = [1, 2, 3];
        final List<int> result = CastUtil.castIntListFromData(data);
        expect(result, equals([1, 2, 3]));
        expect(result, isA<List<int>>());
      });

      test('should correctly cast List<dynamic> to List<double>', () {
        final dynamic data = [1.0, 2.0, 3.0];
        final List<double> result = CastUtil.castDoubleListFromData(data);
        expect(result, equals([1.0, 2.0, 3.0]));
        expect(result, isA<List<double>>());
      });

      test('should correctly cast List<dynamic> to List<String>', () {
        final dynamic data = ['a', 'b', 'c'];
        final List<String> result = CastUtil.castStringListFromData(data);
        expect(result, equals(['a', 'b', 'c']));
        expect(result, isA<List<String>>());
      });

      test('should throw ArgumentError for invalid basic list type', () {
        final dynamic data = 'not a list';
        expect(() => CastUtil.castIntListFromData(data), throwsA(isA<ArgumentError>()));
        expect(() => CastUtil.castDoubleListFromData(data), throwsA(isA<ArgumentError>()));
        expect(() => CastUtil.castStringListFromData(data), throwsA(isA<ArgumentError>()));
      });

      test('should throw runtime error for mixed basic list types', () {
        // .cast() method will throw a runtime error when accessing the incorrect type
        final dynamic data = [1, 'a', 3];
        expect(() => CastUtil.castIntListFromData(data), throwsA(isA<TypeError>()));
      });
    });
  });
}