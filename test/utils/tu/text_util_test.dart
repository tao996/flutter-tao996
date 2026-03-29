import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/text_util.dart';

void main() {
  group('TextUtil', () {
    late TextUtil textUtil;

    setUp(() {
      textUtil = const TextUtil();
    });

    group('getTagsList', () {
      test('splits tags by comma', () {
        expect(
          textUtil.getTagsList('tag1,tag2,tag3'),
          equals(['tag1', 'tag2', 'tag3']),
        );
      });

      test('filters empty strings', () {
        expect(
          textUtil.getTagsList('tag1,,tag2,,,tag3'),
          equals(['tag1', 'tag2', 'tag3']),
        );
      });

      test('returns empty list for empty string', () {
        expect(textUtil.getTagsList(''), equals([]));
      });
    });

    group('formatTags', () {
      test('formats list for saving with delimiters', () {
        expect(
          textUtil.formatTags(listInput: ['tag1', 'tag2'], isSave: true),
          equals(',tag1,tag2,'),
        );
      });

      test('formats list without save delimiters', () {
        expect(
          textUtil.formatTags(listInput: ['tag1', 'tag2'], isSave: false),
          equals('tag1,tag2'),
        );
      });

      test('formats string input', () {
        expect(
          textUtil.formatTags(input: ',tag1,tag2,', isSave: true),
          equals(',tag1,tag2,'),
        );
      });

      test('filters empty tags', () {
        expect(
          textUtil.formatTags(listInput: ['tag1', '', 'tag2'], isSave: true),
          equals(',tag1,tag2,'),
        );
      });

      test('returns empty string for empty input', () {
        expect(textUtil.formatTags(listInput: [], isSave: true), equals(''));
      });

      test('throws when both inputs are null', () {
        expect(() => textUtil.formatTags(), throwsA(isA<ArgumentError>()));
      });
    });

    group('merge', () {
      test('merges non-null strings with separator', () {
        expect(textUtil.merge('-', 'a', 'b', 'c'), equals('a-b-c'));
      });

      test('ignores null values', () {
        expect(textUtil.merge('-', 'a', null, 'b', null, 'c'), equals('a-b-c'));
      });

      test('ignores empty strings', () {
        expect(textUtil.merge('-', 'a', '', 'b', ''), equals('a-b'));
      });

      test('returns single value when only one non-null', () {
        expect(textUtil.merge('-', 'a', null, null), equals('a'));
      });

      // Note: merge method parameters are non-nullable String type
      // Skipping null tests as they would be compile-time errors in null-safe Dart

      test('handles up to 16 parameters', () {
        expect(
          textUtil.merge(
            ',',
            'a',
            'b',
            'c',
            'd',
            'e',
            'f',
            'g',
            'h',
            'i',
            'j',
            'k',
            'l',
            'm',
            'n',
            'o',
            'p',
          ),
          equals('a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p'),
        );
      });
    });

    group('textLength', () {
      test('counts ASCII characters as half width', () {
        expect(textUtil.textLength('abc'), equals(2)); // ceil(3/2)
      });

      test('counts Chinese characters as full width', () {
        expect(textUtil.textLength('你好'), equals(2));
      });

      test('handles mixed content', () {
        // 'Hello' = 5 half-width = 3, '世界' = 2 full-width, total = 5
        expect(textUtil.textLength('Hello世界'), equals(5));
      });

      test('handles spaces and punctuation', () {
        expect(textUtil.textLength('Hello, World!'), equals(7)); // ceil(13/2)
      });

      test('handles empty string', () {
        expect(textUtil.textLength(''), equals(0));
      });

      test('handles numbers', () {
        expect(textUtil.textLength('12345'), equals(3)); // ceil(5/2)
      });
    });

    group('maxLength', () {
      test('finds maximum text length', () {
        expect(textUtil.maxLength(['a', 'ab', 'abc']), equals(2));
      });

      test('handles empty list', () {
        expect(textUtil.maxLength([]), equals(0));
      });

      test('handles mixed Chinese and English', () {
        expect(
          textUtil.maxLength(['Hi', '你好', 'Hello World']),
          equals(6),
        ); // "Hello World" = ceil(11/2) = 6
      });
    });

    group('trimRight', () {
      test('removes matching suffix', () {
        expect(textUtil.trimRight('hello.txt', '.txt'), equals('hello'));
      });

      test('returns original if no match', () {
        expect(textUtil.trimRight('hello.txt', '.pdf'), equals('hello.txt'));
      });

      test('handles empty trim', () {
        expect(textUtil.trimRight('hello', ''), equals('hello'));
      });
    });

    group('trimLeft', () {
      test('removes matching prefix', () {
        expect(textUtil.trimLeft('/home/user', '/home'), equals('/user'));
      });

      test('returns original if no match', () {
        expect(textUtil.trimLeft('/home/user', '/root'), equals('/home/user'));
      });

      test('handles empty trim', () {
        expect(textUtil.trimLeft('hello', ''), equals('hello'));
      });
    });

    group('decode', () {
      test('decodes UTF-8 bytes', () {
        final bytes = utf8.encode('Hello World');
        expect(textUtil.decode(bytes), equals('Hello World'));
      });

      test('decodes UTF-8 Chinese', () {
        final bytes = utf8.encode('你好世界');
        expect(textUtil.decode(bytes), equals('你好世界'));
      });

      test('decodes empty bytes', () {
        expect(textUtil.decode([]), equals(''));
      });

      test('decodes UTF-16 LE', () {
        // UTF-16 LE BOM: 0xFF 0xFE
        final bytes = [0xFF, 0xFE, 0x48, 0x00, 0x65, 0x00, 0x6C, 0x00];
        expect(textUtil.decode(bytes), equals('Hel'));
      });

      test('decodes Latin1 for invalid UTF-8', () {
        // Invalid UTF-8 sequence, falls back to Latin1
        final bytes = [0x80, 0x81, 0x82];
        expect(textUtil.decode(bytes), isNotEmpty);
      });
    });

    group('kTagSeparator', () {
      test('is comma', () {
        expect(TextUtil.kTagSeparator, equals(','));
      });
    });
  });
}
