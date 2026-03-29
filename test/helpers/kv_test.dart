import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tao996/tao996.dart';

void main() {
  group('KV', () {
    test('can be created with label and value', () {
      final kv = KV<String>(label: 'Name', value: 'Alice');
      expect(kv.label, equals('Name'));
      expect(kv.value, equals('Alice'));
    });

    test('can be created with icon', () {
      final kv = KV<String>(
        label: 'Settings',
        value: 'settings',
        icon: const Icon(Icons.settings),
      );
      expect(kv.icon, isA<Icon>());
    });

    test('icon returns Icon widget when icon is set', () {
      final kv = KV<String>(
        label: 'Settings',
        value: 'settings',
        icon: const Icon(Icons.settings),
      );
      expect(kv.icon, isA<Icon>());
    });

    test('icon returns null when icon is not set', () {
      final kv = KV<String>(label: 'Name', value: 'Alice');
      expect(kv.icon, isNull);
    });

    test('can be used with different types', () {
      final kvInt = KV<int>(label: 'Age', value: 30);
      expect(kvInt.value, equals(30));

      final kvDouble = KV<double>(label: 'Price', value: 99.99);
      expect(kvDouble.value, equals(99.99));

      final kvBool = KV<bool>(label: 'Active', value: true);
      expect(kvBool.value, isTrue);
    });

    test('can be used in list', () {
      final list = [
        KV<String>(label: 'Option 1', value: 'opt1'),
        KV<String>(label: 'Option 2', value: 'opt2'),
        KV<String>(label: 'Option 3', value: 'opt3'),
      ];

      expect(list.length, equals(3));
      expect(list[0].label, equals('Option 1'));
      expect(list[2].value, equals('opt3'));
    });

    // Note: KV class does not implement operator ==, so equality comparison
    // uses identity comparison by default
  });
}
