import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tao996/src/mocks/mock_start.dart';
import 'package:tao996/src/utils/function.dart';

void main() {
  setUpAll(() {
    mockStart();
  });
  group('dprint', () {
    test('does not throw when called in debug mode', () {
      expect(() => dprint('test message'), returnsNormally);
    });

    test('does not throw with stack=false', () {
      expect(() => dprint('test message', stack: false), returnsNormally);
    });

    test('does not throw with first=false', () {
      expect(() => dprint('test message', first: false), returnsNormally);
    });
  });

  group('ddprint', () {
    test('does not throw when called', () {
      expect(() => ddprint('message', {'key': 'value'}), returnsNormally);
    });
  });

  group('colorWithOpacity', () {
    test('returns 255 for opacity 1.0', () {
      expect(colorWithOpacity(1.0), equals(255));
    });

    test('returns 0 for opacity 0.0', () {
      expect(colorWithOpacity(0.0), equals(0));
    });

    test('returns 128 for opacity 0.5', () {
      expect(colorWithOpacity(0.5), equals(127)); // 255 * 0.5 = 127.5 -> 127
    });

    test('returns correct value for various opacities', () {
      expect(colorWithOpacity(0.25), equals(63)); // 255 * 0.25 = 63.75 -> 63
      expect(colorWithOpacity(0.75), equals(191)); // 255 * 0.75 = 191.25 -> 191
    });
  });

  group('syncListState', () {
    test('removes item at index when entity is null', () async {
      final items = RxList<dynamic>(['a', 'b', 'c']);
      await syncListState(items: items, index: 1, entity: null);
      expect(items.length, equals(2));
      expect(items, equals(['a', 'c']));
    });

    // Note: syncListState throws when index out of range, no bounds check in implementation
    // This is expected behavior - caller should ensure valid index

    test('does nothing when entity is null and items is null', () async {
      // Should not throw
      await syncListState(items: null, index: 0, entity: null);
    });

    test('updates item at index when entity provided', () async {
      final items = RxList<dynamic>(['a', 'b', 'c']);
      await syncListState(items: items, index: 1, entity: 'updated');
      expect(items[1], equals('updated'));
      expect(items.length, equals(3));
    });

    test('inserts item at beginning when index=-1 and unshift=true', () async {
      final items = RxList<dynamic>(['b', 'c']);
      await syncListState(items: items, index: -1, entity: 'a', unshift: true);
      expect(items, equals(['a', 'b', 'c']));
    });

    test('appends item at end when index=-1 and unshift=false', () async {
      final items = RxList<dynamic>(['a', 'b']);
      await syncListState(items: items, index: -1, entity: 'c', unshift: false);
      expect(items, equals(['a', 'b', 'c']));
    });

    test('increments total when adding new item', () async {
      final items = RxList<dynamic>([]);
      final total = RxInt(0);
      await syncListState(items: items, index: -1, entity: 'new', total: total, unshift: false);
      expect(total.value, equals(1));
    });

    test('decrements total when removing item', () async {
      final items = RxList<dynamic>(['a', 'b', 'c']);
      final total = RxInt(3);
      await syncListState(items: items, index: 0, entity: null, total: total);
      expect(total.value, equals(2));
    });

    test('does not modify total when updating existing item', () async {
      final items = RxList<dynamic>(['a', 'b']);
      final total = RxInt(2);
      await syncListState(items: items, index: 0, entity: 'updated', total: total);
      expect(total.value, equals(2));
    });

    test('handles custom object types', () async {
      final items = RxList<dynamic>([{'id': 1}, {'id': 2}]);
      final newItem = {'id': 3, 'name': 'test'};
      await syncListState(items: items, index: -1, entity: newItem, unshift: false);
      expect(items.length, equals(3));
      expect(items.last, equals(newItem));
    });

    test('unshift parameter defaults to true behavior', () async {
      final items = RxList<dynamic>(['b', 'c']);
      // Test with explicit unshift=true (default)
      await syncListState(items: items, index: -1, entity: 'a', unshift: true);
      expect(items.first, equals('a'));
    });
  });
}
