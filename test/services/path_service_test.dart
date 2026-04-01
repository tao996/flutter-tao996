import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tao996/src/services/path_service.dart';

// Mock PathProviderPlatform
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String mockPath;

  MockPathProviderPlatform(this.mockPath);

  @override
  Future<String?> getTemporaryPath() async => '$mockPath/temp';

  @override
  Future<String?> getApplicationSupportPath() async => '$mockPath/support';

  @override
  Future<String?> getApplicationDocumentsPath() async => '$mockPath/documents';

  @override
  Future<String?> getApplicationCachePath() async => '$mockPath/cache';

  @override
  Future<String?> getDownloadsPath() async => '$mockPath/downloads';

  @override
  Future<String?> getExternalStoragePath() async => '$mockPath/external';

  @override
  Future<List<String>?> getExternalCachePaths() async => ['$mockPath/extcache'];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => ['$mockPath/extstorage'];
}

void main() {
  group('PathService', () {
    late PathService pathService;
    const testPath = '/test/path';

    setUp(() {
      pathService = PathService();
      PathProviderPlatform.instance = MockPathProviderPlatform(testPath);
    });

    group('getTemporaryDirectoryPath', () {
      test('returns Directory', () async {
        final result = await pathService.getTemporaryDirectoryPath();
        expect(result, isA<Directory>());
      });

      test('returns correct path', () async {
        final result = await pathService.getTemporaryDirectoryPath();
        expect(result.path, equals('$testPath/temp'));
      });
    });

    group('getApplicationDocumentsDirectoryPath', () {
      test('returns Directory', () async {
        final result = await pathService.getApplicationDocumentsDirectoryPath();
        expect(result, isA<Directory>());
      });

      test('returns correct path', () async {
        final result = await pathService.getApplicationDocumentsDirectoryPath();
        expect(result.path, equals('$testPath/documents'));
      });
    });

    group('getApplicationSupportDirectoryPath', () {
      test('returns Directory', () async {
        final result = await pathService.getApplicationSupportDirectoryPath();
        expect(result, isA<Directory>());
      });

      test('returns correct path', () async {
        final result = await pathService.getApplicationSupportDirectoryPath();
        expect(result.path, equals('$testPath/support'));
      });
    });

    group('getApplicationCacheDirectoryPath', () {
      test('returns Directory', () async {
        final result = await pathService.getApplicationCacheDirectoryPath();
        expect(result, isA<Directory>());
      });

      test('returns correct path', () async {
        final result = await pathService.getApplicationCacheDirectoryPath();
        expect(result.path, equals('$testPath/cache'));
      });
    });

    group('getDownloadsDirectoryPath', () {
      test('returns Directory or null', () async {
        final result = await pathService.getDownloadsDirectoryPath();
        expect(result == null || result is Directory, isTrue);
      });

      test('returns correct path when available', () async {
        final result = await pathService.getDownloadsDirectoryPath();
        expect(result?.path, equals('$testPath/downloads'));
      });
    });

    group('homeDir', () {
      test('returns non-empty string', () async {
        final result = await pathService.homeDir();
        expect(result, isNotEmpty);
        expect(result, isA<String>());
      });

      test('returns valid path format', () async {
        final result = await pathService.homeDir();
        // Should not contain null
        expect(result, isNot(contains('null')));
      });
    });
  });
}
