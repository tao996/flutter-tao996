import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/data_util.dart';

void main() {
  group('DataUtil', () {
    late DataUtil dataUtil;

    setUp(() {
      dataUtil = const DataUtil();
    });

    group('getBool', () {
      test('returns true for boolean true', () {
        expect(dataUtil.getBool(true), isTrue);
      });

      test('returns false for boolean false', () {
        expect(dataUtil.getBool(false), isFalse);
      });

      test('returns false for null', () {
        expect(dataUtil.getBool(null), isFalse);
      });

      test('returns false for empty string', () {
        expect(dataUtil.getBool(''), isFalse);
      });

      test('returns true for positive numbers', () {
        expect(dataUtil.getBool(1), isTrue);
        expect(dataUtil.getBool(0.1), isTrue);
      });

      test('returns false for zero and negative', () {
        expect(dataUtil.getBool(0), isFalse);
        expect(dataUtil.getBool(-1), isFalse);
      });

      // Note: Invalid input triggers debug service which requires GetIt initialization
      // Skipping this test in unit test environment

      group('with textCompare', () {
        test('recognizes string true values', () {
          expect(dataUtil.getBool('1', textCompare: true), isTrue);
          expect(dataUtil.getBool('true', textCompare: true), isTrue);
          expect(dataUtil.getBool('t', textCompare: true), isTrue);
          expect(dataUtil.getBool('T', textCompare: true), isTrue);
          expect(dataUtil.getBool('ON', textCompare: true), isTrue);
          expect(dataUtil.getBool('on', textCompare: true), isTrue);
        });

        test('recognizes string false values', () {
          expect(dataUtil.getBool('0', textCompare: true), isFalse);
          expect(dataUtil.getBool('false', textCompare: true), isFalse);
          expect(dataUtil.getBool('f', textCompare: true), isFalse);
          expect(dataUtil.getBool('F', textCompare: true), isFalse);
          expect(dataUtil.getBool('OFF', textCompare: true), isFalse);
          expect(dataUtil.getBool('off', textCompare: true), isFalse);
        });

        // Note: Unrecognized strings trigger debug service which requires GetIt initialization
        // Skipping this test in unit test environment
      });
    });

    group('getInt', () {
      test('returns int value', () {
        expect(dataUtil.getInt(42), equals(42));
      });

      test('returns default for null', () {
        expect(dataUtil.getInt(null), equals(0));
        expect(dataUtil.getInt(null, defaultValue: -1), equals(-1));
      });

      test('returns default for empty string', () {
        expect(dataUtil.getInt(''), equals(0));
      });

      test('parses string to int', () {
        expect(dataUtil.getInt('42'), equals(42));
        expect(dataUtil.getInt('-10'), equals(-10));
      });

      test('converts double to int', () {
        expect(dataUtil.getInt(3.14), equals(3));
        expect(dataUtil.getInt(3.99), equals(3));
      });

      test('returns default for invalid string', () {
        expect(dataUtil.getInt('abc'), equals(0));
      });
    });

    group('getDouble', () {
      test('returns double value', () {
        expect(dataUtil.getDouble(3.14), equals(3.14));
      });

      test('returns default for null', () {
        expect(dataUtil.getDouble(null), equals(0.0));
        expect(dataUtil.getDouble(null, defaultValue: -1.5), equals(-1.5));
      });

      test('returns default for empty string', () {
        expect(dataUtil.getDouble(''), equals(0.0));
      });

      test('parses string to double', () {
        expect(dataUtil.getDouble('3.14'), equals(3.14));
        expect(dataUtil.getDouble('-2.5'), equals(-2.5));
      });

      test('converts int to double', () {
        expect(dataUtil.getDouble(42), equals(42.0));
      });

      test('returns default for invalid string', () {
        expect(dataUtil.getDouble('abc'), equals(0.0));
      });
    });

    group('tryGetDouble', () {
      test('returns double for valid input', () {
        expect(dataUtil.tryGetDouble('3.14'), equals(3.14));
      });

      test('returns null for null', () {
        expect(dataUtil.tryGetDouble(null), isNull);
      });

      test('returns null for empty string', () {
        expect(dataUtil.tryGetDouble(''), isNull);
      });
    });

    group('getString', () {
      test('returns string value', () {
        expect(dataUtil.getString('hello'), equals('hello'));
      });

      test('returns default for null', () {
        expect(dataUtil.getString(null), equals(''));
        expect(dataUtil.getString(null, defaultValue: 'N/A'), equals('N/A'));
      });

      test('converts other types to string', () {
        expect(dataUtil.getString(42), equals('42'));
        expect(dataUtil.getString(true), equals('true'));
        expect(dataUtil.getString(3.14), equals('3.14'));
      });
    });

    group('getDateTime', () {
      test('parses date string', () {
        final result = dataUtil.getDateTime('2025-05-22');
        expect(result, isNotNull);
        expect(result!.year, equals(2025));
      });

      test('returns default for null', () {
        final defaultDate = DateTime(2000, 1, 1);
        expect(dataUtil.getDateTime(null, defaultValue: defaultDate),
            equals(defaultDate));
      });

      test('returns null for empty string', () {
        expect(dataUtil.getDateTime(''), isNull);
      });

      // Note: Invalid date triggers debug service which requires GetIt initialization
      // Skipping this test in unit test environment
    });

    group('getList', () {
      test('converts list of maps', () {
        final data = [
          {'name': 'Alice', 'age': 30},
          {'name': 'Bob', 'age': 25},
        ];

        final result = dataUtil.getList(
          data,
          (json) => Person(name: json['name'] as String, age: json['age'] as int),
        );

        expect(result, isNotNull);
        expect(result!.length, equals(2));
        expect(result[0].name, equals('Alice'));
        expect(result[1].age, equals(25));
      });

      test('returns default for null', () {
        final defaultList = [Person(name: 'Default', age: 0)];
        final result = dataUtil.getList(
          null,
          (json) => Person(name: json['name'] as String, age: json['age'] as int),
          defaultValue: defaultList,
        );
        expect(result, equals(defaultList));
      });

      test('returns default for empty string', () {
        final result = dataUtil.getList(
          '',
          (json) => Person(name: json['name'] as String, age: json['age'] as int),
        );
        expect(result, isNull);
      });
    });

    group('firstValue', () {
      test('returns first existing key value', () {
        final json = {'a': 1, 'b': 2, 'c': 3};
        expect(dataUtil.firstValue(json, ['x', 'y', 'b', 'a']), equals(2));
      });

      test('returns null when no key exists', () {
        final json = {'a': 1};
        expect(dataUtil.firstValue(json, ['x', 'y', 'z']), isNull);
      });

      test('returns value for first matching key', () {
        final json = {'a': 1, 'b': 2};
        expect(dataUtil.firstValue(json, ['a', 'b']), equals(1));
      });
    });

    group('getIntFromBool', () {
      test('converts true to 1', () {
        expect(dataUtil.getIntFromBool(true), equals(1));
      });

      test('converts false to 0', () {
        expect(dataUtil.getIntFromBool(false), equals(0));
      });
    });

    group('getBoolFromInt', () {
      test('converts 1 to true', () {
        expect(dataUtil.getBoolFromInt(1), isTrue);
      });

      test('converts 0 to false', () {
        expect(dataUtil.getBoolFromInt(0), isFalse);
      });

      test('converts other values to false', () {
        expect(dataUtil.getBoolFromInt(2), isFalse);
        expect(dataUtil.getBoolFromInt(-1), isFalse);
      });
    });

    group('hasMatch', () {
      test('matches pattern correctly', () {
        expect(dataUtil.hasMatch('hello123', r'\d+'), isTrue);
        expect(dataUtil.hasMatch('hello', r'\d+'), isFalse);
      });

      test('handles empty string', () {
        expect(dataUtil.hasMatch('', r'.*'), isTrue);
      });
    });

    group('getAllMatches', () {
      test('returns all matches', () {
        final result = dataUtil.getAllMatches(r'\d+', 'abc123def456ghi789');
        expect(result, equals(['123', '456', '789']));
      });

      test('returns empty list when no matches', () {
        final result = dataUtil.getAllMatches(r'\d+', 'abcdef');
        expect(result, isEmpty);
      });
    });

    group('getFirstMatch', () {
      test('returns first match', () {
        expect(dataUtil.getFirstMatch(r'\d+', 'abc123def456'), equals('123'));
      });

      test('returns null when no match', () {
        expect(dataUtil.getFirstMatch(r'\d+', 'abcdef'), isNull);
      });
    });

    group('isValidUserInputRegexPattern', () {
      test('validates raw string patterns', () {
        expect(dataUtil.isValidUserInputRegexPattern(r'r"pattern"'), isTrue);
        expect(dataUtil.isValidUserInputRegexPattern("r'pattern'"), isTrue);
      });

      test('returns false for regular strings', () {
        expect(dataUtil.isValidUserInputRegexPattern('pattern'), isFalse);
        expect(dataUtil.isValidUserInputRegexPattern('"pattern"'), isFalse);
      });
    });

    group('getUserInputRegexPattern', () {
      test('extracts pattern from raw string', () {
        expect(dataUtil.getUserInputRegexPattern(r'r"hello"'), equals('hello'));
        expect(dataUtil.getUserInputRegexPattern("r'hello'"), equals('hello'));
      });

      test('trims whitespace', () {
        expect(dataUtil.getUserInputRegexPattern('  hello  '), equals('hello'));
      });

      test('returns cleaned for non-raw strings', () {
        expect(dataUtil.getUserInputRegexPattern('hello'), equals('hello'));
      });
    });

    group('getType', () {
      test('returns runtime type', () {
        expect(dataUtil.getType(42), equals(int));
        expect(dataUtil.getType('hello'), equals(String));
        expect(dataUtil.getType(3.14), equals(double));
      });
    });

    group('copy', () {
      test('creates deep copy of object', () {
        final original = {'a': 1, 'b': [1, 2, 3]};
        final copy = dataUtil.copy(original);

        expect(copy, equals(original));
        expect(identical(copy, original), isFalse);
      });
    });

    group('cloneNestedMap', () {
      test('clones nested map', () {
        final source = {
          'key1': {'sub1': 'value1'},
          'key2': {'sub2': 'value2'},
        };
        final clone = dataUtil.cloneNestedMap(source);

        expect(clone, equals(source));
        expect(identical(clone, source), isFalse);
        expect(identical(clone['key1'], source['key1']), isFalse);
      });
    });

    group('cloneMap', () {
      test('clones simple map', () {
        final source = {'a': 1, 'b': 2};
        final clone = dataUtil.cloneMap<int>(source);

        expect(clone, equals(source));
        expect(identical(clone, source), isFalse);
      });

      test('clones nested map recursively', () {
        final source = {
          'a': {'nested': 'value'},
          'b': 2,
        };
        final clone = dataUtil.cloneMap<dynamic>(source);

        expect(clone, equals(source));
        expect(identical(clone['a'], source['a']), isFalse);
      });
    });

    group('jsonString', () {
      test('encodes object to JSON', () {
        final data = {'name': 'Alice', 'age': 30};
        final json = dataUtil.jsonString(data);
        expect(json, contains('Alice'));
        expect(json, contains('30'));
      });

      test('encodes DateTime to ISO8601', () {
        final date = DateTime(2025, 5, 22, 13, 4, 30);
        final json = dataUtil.jsonString({'date': date});
        expect(json, contains('2025-05-22T13:04:30'));
      });
    });

    group('getUint8List', () {
      test('returns Uint8List as-is', () {
        final data = Uint8List.fromList([1, 2, 3]);
        expect(dataUtil.getUint8List(data), equals(data));
      });

      test('converts ByteData', () {
        final byteData = ByteData(3);
        byteData.setUint8(0, 1);
        byteData.setUint8(1, 2);
        byteData.setUint8(2, 3);
        final result = dataUtil.getUint8List(byteData);
        expect(result, equals(Uint8List.fromList([1, 2, 3])));
      });

      test('converts String to UTF-8 bytes', () {
        final result = dataUtil.getUint8List('Hello');
        expect(result, equals(Uint8List.fromList([72, 101, 108, 108, 111])));
      });

      test('converts List<int>', () {
        final result = dataUtil.getUint8List([1, 2, 3]);
        expect(result, equals(Uint8List.fromList([1, 2, 3])));
      });

      test('returns null for unsupported types', () {
        expect(dataUtil.getUint8List(42), isNull);
        expect(dataUtil.getUint8List(null), isNull);
      });
    });
  });
}

// Helper class for testing
class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.name == name && other.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}
