import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/helpers/db_type_converter.dart';

void main() {
  group('JsonColorConverter', () {
    const converter = JsonColorConverter();

    test('converts Color to int', () {
      const color = Colors.red;
      final result = converter.toJson(color);
      expect(result, equals(color.toARGB32()));
    });

    test('converts int to Color', () {
      const argb = 0xFFFF0000; // Red
      final result = converter.fromJson(argb);
      expect(result, equals(const Color(0xFFFF0000)));
    });
  });

  group('JsonBoolConverter', () {
    const converter = JsonBoolConverter();

    test('converts true to 1', () {
      expect(converter.toJson(true), equals(1));
    });

    test('converts false to 0', () {
      expect(converter.toJson(false), equals(0));
    });

    test('converts 1 to true', () {
      expect(converter.fromJson(1), isTrue);
    });

    test('converts 0 to false', () {
      expect(converter.fromJson(0), isFalse);
    });
  });

  group('JsonDatetimeConverter', () {
    const converter = JsonDatetimeConverter();

    test('converts DateTime to ISO8601 string', () {
      final dateTime = DateTime(2025, 5, 22, 13, 30, 0);
      final result = converter.toJson(dateTime);
      expect(result, equals('2025-05-22T13:30:00.000'));
    });

    test('converts null to empty string', () {
      expect(converter.toJson(null), equals(''));
    });

    test('converts ISO8601 string to DateTime', () {
      final result = converter.fromJson('2025-05-22T13:30:00.000');
      expect(result, equals(DateTime(2025, 5, 22, 13, 30, 0)));
    });

    test('converts null string to null', () {
      expect(converter.fromJson(null), isNull);
    });

    test('converts empty string to null', () {
      expect(converter.fromJson(''), isNull);
    });

    test('handles invalid date string gracefully', () {
      expect(converter.fromJson('invalid'), isNull);
    });
  });

  group('JsonMapStringStringConverter', () {
    const converter = JsonMapStringStringConverter();

    test('converts Map to JSON string', () {
      final map = {'key1': 'value1', 'key2': 'value2'};
      final result = converter.toJson(map);
      expect(result, isA<String>());
      expect(jsonDecode(result), equals(map));
    });

    test('converts null to empty map JSON', () {
      expect(converter.toJson(null), equals('{}'));
    });

    test('converts JSON string to Map', () {
      const jsonStr = '{"key1":"value1","key2":"value2"}';
      final result = converter.fromJson(jsonStr);
      expect(result, equals({'key1': 'value1', 'key2': 'value2'}));
    });

    test('converts null to empty map', () {
      expect(converter.fromJson(null), equals({}));
    });

    test('converts empty string to empty map', () {
      expect(converter.fromJson(''), equals({}));
    });
  });

  group('JsonMapStringBoolConverter', () {
    const converter = JsonMapStringBoolConverter();

    test('converts Map<String, bool> to JSON string', () {
      final map = {'active': true, 'deleted': false};
      final result = converter.toJson(map);
      expect(jsonDecode(result), equals({'active': true, 'deleted': false}));
    });

    test('converts JSON string to Map<String, bool>', () {
      const jsonStr = '{"active":true,"deleted":false}';
      final result = converter.fromJson(jsonStr);
      expect(result, equals({'active': true, 'deleted': false}));
    });
  });

  group('JsonMapStringIntConverter', () {
    const converter = JsonMapStringIntConverter();

    test('converts Map<String, int> to JSON string', () {
      final map = {'count': 10, 'total': 100};
      final result = converter.toJson(map);
      expect(jsonDecode(result), equals({'count': 10, 'total': 100}));
    });

    test('converts JSON string to Map<String, int>', () {
      const jsonStr = '{"count":10,"total":100}';
      final result = converter.fromJson(jsonStr);
      expect(result, equals({'count': 10, 'total': 100}));
    });
  });

  group('JsonMapStringDoubleConverter', () {
    const converter = JsonMapStringDoubleConverter();

    test('converts Map<String, double> to JSON string', () {
      final map = {'price': 9.99, 'tax': 0.08};
      final result = converter.toJson(map);
      expect(jsonDecode(result), equals({'price': 9.99, 'tax': 0.08}));
    });

    test('converts JSON string to Map<String, double>', () {
      const jsonStr = '{"price":9.99,"tax":0.08}';
      final result = converter.fromJson(jsonStr);
      expect(result, equals({'price': 9.99, 'tax': 0.08}));
    });
  });

  group('JsonNestedMapStringConverter', () {
    const converter = JsonNestedMapStringConverter();

    test('converts nested Map to JSON string', () {
      final map = {
        'section1': {'key1': 'value1'},
        'section2': {'key2': 'value2'},
      };
      final result = converter.toJson(map);
      final decoded = jsonDecode(result);
      expect(decoded['section1']['key1'], equals('value1'));
    });

    test('converts JSON string to nested Map', () {
      const jsonStr = '{"section1":{"key1":"value1"},"section2":{"key2":"value2"}}';
      final result = converter.fromJson(jsonStr);
      expect(result['section1']?['key1'], equals('value1'));
      expect(result['section2']?['key2'], equals('value2'));
    });

    test('returns empty map for empty string', () {
      expect(converter.fromJson(''), equals({}));
    });

    test('returns empty map for invalid JSON', () {
      expect(converter.fromJson('invalid'), equals({}));
    });
  });

  group('JsonListIntConverter', () {
    const converter = JsonListIntConverter();

    test('converts List<int> to JSON string', () {
      final list = [1, 2, 3, 4, 5];
      final result = converter.toJson(list);
      expect(jsonDecode(result), equals([1, 2, 3, 4, 5]));
    });

    test('converts null to empty array string', () {
      expect(converter.toJson(null), equals('[]'));
    });

    test('converts JSON string to List<int>', () {
      const jsonStr = '[1,2,3,4,5]';
      final result = converter.fromJson(jsonStr);
      expect(result, equals([1, 2, 3, 4, 5]));
    });

    test('handles null input', () {
      expect(converter.fromJson(null), isEmpty);
    });

    test('handles empty string', () {
      expect(converter.fromJson(''), isEmpty);
    });

    test('handles "null" string', () {
      expect(converter.fromJson('null'), isEmpty);
    });

    test('handles "[]" string', () {
      expect(converter.fromJson('[]'), isEmpty);
    });

    test('handles mixed types in list', () {
      const jsonStr = '[1,"2",3]';
      final result = converter.fromJson(jsonStr);
      expect(result, equals([1, 2, 3]));
    });
  });

  group('JsonListDoubleConverter', () {
    const converter = JsonListDoubleConverter();

    test('converts List<double> to JSON string', () {
      final list = [1.5, 2.5, 3.5];
      final result = converter.toJson(list);
      expect(jsonDecode(result), equals([1.5, 2.5, 3.5]));
    });

    test('converts JSON string to List<double>', () {
      const jsonStr = '[1.5,2.5,3.5]';
      final result = converter.fromJson(jsonStr);
      expect(result, equals([1.5, 2.5, 3.5]));
    });

    test('converts int to double in list', () {
      const jsonStr = '[1,2,3]';
      final result = converter.fromJson(jsonStr);
      expect(result, equals([1.0, 2.0, 3.0]));
    });
  });

  group('JsonListStringConverter', () {
    const converter = JsonListStringConverter();

    test('converts List<String> to JSON string', () {
      final list = ['a', 'b', 'c'];
      final result = converter.toJson(list);
      expect(jsonDecode(result), equals(['a', 'b', 'c']));
    });

    test('converts JSON string to List<String>', () {
      const jsonStr = '["a","b","c"]';
      final result = converter.fromJson(jsonStr);
      expect(result, equals(['a', 'b', 'c']));
    });

    test('converts non-strings to strings', () {
      const jsonStr = '[1,2.5,true]';
      final result = converter.fromJson(jsonStr);
      expect(result, equals(['1', '2.5', 'true']));
    });
  });

  group('JsonRectConverter', () {
    const converter = JsonRectConverter();

    test('converts Rect to JSON string', () {
      final rect = Rect.fromLTWH(10, 20, 100, 200);
      final result = converter.toJson(rect);
      final decoded = jsonDecode(result);
      expect(decoded['l'], equals(10));
      expect(decoded['t'], equals(20));
      expect(decoded['w'], equals(100));
      expect(decoded['h'], equals(200));
    });

    test('converts JSON string to Rect', () {
      const jsonStr = '{"l":10,"t":20,"w":100,"h":200}';
      final result = converter.fromJson(jsonStr);
      expect(result.left, equals(10));
      expect(result.top, equals(20));
      expect(result.width, equals(100));
      expect(result.height, equals(200));
    });

    test('returns Rect.zero for empty string', () {
      expect(converter.fromJson(''), equals(Rect.zero));
    });
  });

  group('JsonSizeConverter', () {
    const converter = JsonSizeConverter();

    test('converts Size to JSON string', () {
      const size = Size(100, 50);
      final result = converter.toJson(size);
      final decoded = jsonDecode(result);
      expect(decoded['w'], equals(100));
      expect(decoded['h'], equals(50));
    });

    test('converts JSON string to Size', () {
      const jsonStr = '{"w":100,"h":50}';
      final result = converter.fromJson(jsonStr);
      expect(result.width, equals(100));
      expect(result.height, equals(50));
    });

    test('returns Size.zero for empty string', () {
      expect(converter.fromJson(''), equals(Size.zero));
    });
  });

  group('JsonOffsetConverter', () {
    const converter = JsonOffsetConverter();

    test('converts Offset to JSON string', () {
      const offset = Offset(10, 20);
      final result = converter.toJson(offset);
      final decoded = jsonDecode(result);
      expect(decoded['x'], equals(10));
      expect(decoded['y'], equals(20));
    });

    test('converts JSON string to Offset', () {
      const jsonStr = '{"x":10,"y":20}';
      final result = converter.fromJson(jsonStr);
      expect(result.dx, equals(10));
      expect(result.dy, equals(20));
    });

    test('returns Offset.zero for empty string', () {
      expect(converter.fromJson(''), equals(Offset.zero));
    });
  });

  group('JsonEdgeInsetsConverter', () {
    const converter = JsonEdgeInsetsConverter();

    test('converts EdgeInsets to JSON string', () {
      const insets = EdgeInsets.fromLTRB(10, 20, 30, 40);
      final result = converter.toJson(insets);
      expect(jsonDecode(result), equals([10, 20, 30, 40]));
    });

    test('converts JSON string to EdgeInsets', () {
      const jsonStr = '[10,20,30,40]';
      final result = converter.fromJson(jsonStr);
      expect(result.left, equals(10));
      expect(result.top, equals(20));
      expect(result.right, equals(30));
      expect(result.bottom, equals(40));
    });

    test('returns EdgeInsets.zero for empty string', () {
      expect(converter.fromJson(''), equals(EdgeInsets.zero));
    });
  });

  group('JsonBoxShadowConverter', () {
    const converter = JsonBoxShadowConverter();

    test('converts BoxShadow to JSON string', () {
      const shadow = BoxShadow(
        color: Colors.black,
        offset: Offset(2, 2),
        blurRadius: 4,
        spreadRadius: 1,
      );
      final result = converter.toJson(shadow);
      final decoded = jsonDecode(result);
      expect(decoded['color'], equals(Colors.black.toARGB32()));
      expect(decoded['dx'], equals(2));
      expect(decoded['dy'], equals(2));
      expect(decoded['blur'], equals(4));
      expect(decoded['spread'], equals(1));
    });

    test('converts JSON string to BoxShadow', () {
      final colorValue = Colors.red.toARGB32();
      final jsonStr = '{"color":$colorValue,"dx":2,"dy":2,"blur":4,"spread":1}';
      final result = converter.fromJson(jsonStr);
      expect(result.color.value, equals(Colors.red.value));
      expect(result.offset, equals(const Offset(2, 2)));
      expect(result.blurRadius, equals(4));
      expect(result.spreadRadius, equals(1));
    });

    test('returns default BoxShadow for empty string', () {
      final result = converter.fromJson('');
      expect(result, equals(const BoxShadow()));
    });

    test('returns default BoxShadow for invalid JSON', () {
      final result = converter.fromJson('invalid');
      expect(result, equals(const BoxShadow()));
    });
  });

  group('JsonFontWeightConverter', () {
    const converter = JsonFontWeightConverter();

    test('converts FontWeight to int index', () {
      // ignore: deprecated_member_use
      expect(converter.toJson(FontWeight.normal), equals(FontWeight.normal.index));
      // ignore: deprecated_member_use
      expect(converter.toJson(FontWeight.bold), equals(FontWeight.bold.index));
    });

    test('converts int index to FontWeight', () {
      // FontWeight.values: [w100, w200, w300, w400(normal), w500, w600, w700(bold), w800, w900]
      expect(converter.fromJson(2), equals(FontWeight.w300));
      expect(converter.fromJson(3), equals(FontWeight.w400)); // normal
      expect(converter.fromJson(6), equals(FontWeight.w700)); // bold
    });
  });

  group('JsonBoxFitConverter', () {
    const converter = JsonBoxFitConverter();

    test('converts BoxFit to name string', () {
      expect(converter.toJson(BoxFit.cover), equals('cover'));
      expect(converter.toJson(BoxFit.contain), equals('contain'));
    });

    test('converts name string to BoxFit', () {
      expect(converter.fromJson('cover'), equals(BoxFit.cover));
      expect(converter.fromJson('contain'), equals(BoxFit.contain));
      expect(converter.fromJson('fill'), equals(BoxFit.fill));
    });
  });

  group('DbTypeConverter', () {
    group('mapToJson / mapFromJson', () {
      // Note: These methods require DbTypeModel<T> which needs concrete implementations
      // Testing the basic behavior with mock models would be complex
      // The existing db_type_converter_test.dart already tests these methods
    });

    group('listToJson / listFromJson', () {
      // Similar to above, requires DbTypeModel<T> implementations
    });

    group('fromJson / toJson', () {
      test('fromJson converts Map to model using factory', () {
        final data = {'name': 'Test', 'value': 42};
        final result = DbTypeConverter.fromJson<Map<String, dynamic>>(
          data,
          (json) => json,
        );
        expect(result, equals(data));
      });

      test('fromJson converts JSON string to model', () {
        const jsonStr = '{"name":"Test","value":42}';
        final result = DbTypeConverter.fromJson<Map<String, dynamic>>(
          jsonStr,
          (json) => json,
        );
        expect(result['name'], equals('Test'));
        expect(result['value'], equals(42));
      });

      test('fromJson returns null for null input', () {
        final result = DbTypeConverter.fromJson<Map<String, dynamic>?>(
          null,
          (json) => json,
        );
        expect(result, isNull);
      });

      test('toJson converts model to JSON string', () {
        final model = _TestModel(name: 'Test', value: 42);
        final result = DbTypeConverter.toJson(model);
        expect(jsonDecode(result), equals({'name': 'Test', 'value': 42}));
      });

      test('toJson returns empty string for null', () {
        expect(DbTypeConverter.toJson(null), equals(''));
      });
    });
  });
}

// Helper class for testing
class _TestModel {
  final String name;
  final int value;

  _TestModel({required this.name, required this.value});

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}