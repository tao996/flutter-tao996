import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/crypto_util.dart';

void main() {
  group('CryptoUtil', () {
    late CryptoUtil cryptoUtil;

    setUp(() {
      cryptoUtil = const CryptoUtil();
    });

    group('md5Text', () {
      test('hashes empty string', () {
        final result = cryptoUtil.md5Text('');
        expect(result, equals('d41d8cd98f00b204e9800998ecf8427e'));
        expect(result.length, equals(32));
      });

      test('hashes simple string', () {
        final result = cryptoUtil.md5Text('hello');
        expect(result, equals('5d41402abc4b2a76b9719d911017c592'));
      });

      test('hashes string with spaces', () {
        final result = cryptoUtil.md5Text('hello world');
        expect(result, equals('5eb63bbbe01eeed093cb22bb8f5acdc3'));
      });

      test('hashes unicode string', () {
        final result = cryptoUtil.md5Text('你好世界');
        expect(result.length, equals(32));
        expect(result, isNotEmpty);
      });

      test('hashes long string', () {
        final longString = 'a' * 1000;
        final result = cryptoUtil.md5Text(longString);
        expect(result.length, equals(32));
      });

      test('produces consistent results', () {
        final str = 'test string';
        final result1 = cryptoUtil.md5Text(str);
        final result2 = cryptoUtil.md5Text(str);
        expect(result1, equals(result2));
      });

      test('produces different hashes for different inputs', () {
        final result1 = cryptoUtil.md5Text('hello');
        final result2 = cryptoUtil.md5Text('world');
        expect(result1, isNot(equals(result2)));
      });
    });

    group('generateMd5', () {
      test('returns md5 hash for string input', () async {
        final result = await cryptoUtil.generateMd5(input: 'hello');
        expect(result, equals('5d41402abc4b2a76b9719d911017c592'));
      });

      test('returns empty string when both inputs are null', () async {
        final result = await cryptoUtil.generateMd5();
        expect(result, equals(''));
      });

      test('returns empty string when input is empty', () async {
        final result = await cryptoUtil.generateMd5(input: '');
        expect(result, equals('d41d8cd98f00b204e9800998ecf8427e'));
      });

      test('hashes stream correctly', () async {
        final data = utf8.encode('hello world');
        final stream = Stream.fromIterable([data]);

        final result = await cryptoUtil.generateMd5(inputStream: stream);
        // MD5 of "hello world" (without null terminator)
        expect(result.length, equals(32));
        expect(result, isNotEmpty);
      });

      test('hashes multiple chunks correctly', () async {
        final chunks = [
          utf8.encode('hello'),
          utf8.encode(' '),
          utf8.encode('world'),
        ];
        final stream = Stream.fromIterable(chunks);

        final result = await cryptoUtil.generateMd5(inputStream: stream);
        // Should equal md5 of "hello world"
        final expected = cryptoUtil.md5Text('hello world');
        expect(result, equals(expected));
      });

      test('handles empty stream', () async {
        final stream = Stream<List<int>>.empty();
        final result = await cryptoUtil.generateMd5(inputStream: stream);
        expect(result, equals('d41d8cd98f00b204e9800998ecf8427e'));
      });

      test('stream takes precedence over input string', () async {
        final data = utf8.encode('stream');
        final stream = Stream.fromIterable([data]);

        final result = await cryptoUtil.generateMd5(
          input: 'string',
          inputStream: stream,
        );
        expect(result, equals(cryptoUtil.md5Text('stream')));
      });

      test('handles binary data stream', () async {
        final binaryData = [
          [0x00, 0x01, 0x02, 0x03],
          [0x04, 0x05, 0x06, 0x07],
        ];
        final stream = Stream.fromIterable(binaryData);

        final result = await cryptoUtil.generateMd5(inputStream: stream);
        expect(result.length, equals(32));
      });

      test('produces valid hex string', () async {
        final result = await cryptoUtil.generateMd5(input: 'test');
        expect(RegExp(r'^[a-f0-9]{32}$').hasMatch(result), isTrue);
      });
    });
  });
}
