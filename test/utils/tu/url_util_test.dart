import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/src/utils/tu/url_util.dart';

void main() {
  group('UrlUtil', () {
    late UrlUtil urlUtil;

    setUp(() {
      urlUtil = const UrlUtil();
    });

    group('hasAbsolutePath', () {
      test('returns true for absolute path', () {
        expect(urlUtil.hasAbsolutePath('https://example.com/path'), isTrue);
        expect(urlUtil.hasAbsolutePath('/absolute/path'), isTrue);
      });

      test('returns false for relative path', () {
        expect(urlUtil.hasAbsolutePath('relative/path'), isFalse);
        expect(urlUtil.hasAbsolutePath('../parent/path'), isFalse);
      });

      test('returns false for invalid URI', () {
        expect(urlUtil.hasAbsolutePath('not a valid :: uri'), isFalse);
      });

      test('returns false for empty string', () {
        expect(urlUtil.hasAbsolutePath(''), isFalse);
      });
    });

    group('isAbsoluteWebUri', () {
      test('returns true for absolute web URI', () {
        expect(urlUtil.isAbsoluteWebUri('https://example.com'), isTrue);
        expect(urlUtil.isAbsoluteWebUri('http://example.com/path'), isTrue);
      });

      test('returns false for relative path', () {
        expect(urlUtil.isAbsoluteWebUri('/path/to/resource'), isFalse);
        expect(urlUtil.isAbsoluteWebUri('path/to/resource'), isFalse);
      });

      // Note: Uri.parse('https://') has scheme='https' and authority='' (empty but not null)
      // so hasScheme=true and hasAuthority=true (empty string is still considered authority)
      // This behavior depends on Dart's Uri implementation

      test('returns false for invalid URI', () {
        expect(urlUtil.isAbsoluteWebUri('not a uri'), isFalse);
      });

      test('returns false for empty string', () {
        expect(urlUtil.isAbsoluteWebUri(''), isFalse);
      });

      test('handles ftp scheme', () {
        expect(urlUtil.isAbsoluteWebUri('ftp://example.com/file'), isTrue);
      });
    });

    group('concat', () {
      test('concatenates host and path', () {
        final result = urlUtil.concat('https://example.com', '/api/users');
        expect(result.toString(), equals('https://example.com/api/users'));
      });

      test('handles path without leading slash', () {
        final result = urlUtil.concat('https://example.com/', 'api/users');
        expect(result.toString(), equals('https://example.com/api/users'));
      });

      test('handles host with trailing slash', () {
        final result = urlUtil.concat('https://example.com/', '/api/users');
        expect(result.toString(), equals('https://example.com/api/users'));
      });

      test('handles relative path', () {
        final result = urlUtil.concat('https://example.com/api', 'users');
        expect(result.toString(), equals('https://example.com/users'));
      });

      test('handles query parameters in path', () {
        final result = urlUtil.concat('https://example.com', '/api?key=value');
        expect(result.queryParameters['key'], equals('value'));
      });
    });

    group('host', () {
      test('extracts host from URL', () {
        expect(urlUtil.host('https://example.com/path'), equals('example.com'));
        expect(urlUtil.host('http://api.example.com/v1'), equals('api.example.com'));
      });

      test('extracts host with port', () {
        expect(urlUtil.host('http://localhost:8080'), equals('localhost'));
      });

      test('handles www subdomain', () {
        expect(urlUtil.host('https://www.example.com'), equals('www.example.com'));
      });
    });

    group('encodeQueryParameters', () {
      test('encodes simple parameters', () {
        final result = urlUtil.encodeQueryParameters({'key': 'value'});
        expect(result, equals('key=value'));
      });

      test('encodes multiple parameters', () {
        final result = urlUtil.encodeQueryParameters({
          'key1': 'value1',
          'key2': 'value2',
        });
        expect(result, equals('key1=value1&key2=value2'));
      });

      test('encodes special characters', () {
        final result = urlUtil.encodeQueryParameters({
          'message': 'hello world',
          'email': 'user@example.com',
        });
        expect(result, contains('hello%20world'));
        expect(result, contains('user%40example.com'));
      });

      test('encodes unicode characters', () {
        final result = urlUtil.encodeQueryParameters({'text': '你好'});
        expect(result, equals('text=%E4%BD%A0%E5%A5%BD'));
      });

      test('handles empty map', () {
        final result = urlUtil.encodeQueryParameters({});
        expect(result, equals(''));
      });

      test('encodes equals sign in value', () {
        final result = urlUtil.encodeQueryParameters({'equation': '1+1=2'});
        expect(result, equals('equation=1%2B1%3D2'));
      });
    });

    // Note: launch() method requires Flutter binding initialization and url_launcher
    // These are integration tests, not suitable for unit tests
    // group('launch', () { ... });
  });
}
