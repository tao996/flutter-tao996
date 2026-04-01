// ignore_for_file: invalid_use_of_protected_member

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tao996/src/services/network_service.dart';

// Note: NetworkService requires Flutter binding initialization and platform channels
// These are simplified unit tests for the logic that can be tested without binding

void main() {
  group('NetworkService Logic Tests', () {
    // Create a mock implementation for testing
    late TestNetworkService networkService;

    setUp(() {
      networkService = TestNetworkService();
    });

    group('isNoNetwork', () {
      test('returns false when connected', () {
        networkService.state.value = [ConnectivityResult.wifi];
        expect(networkService.isNoNetwork, isFalse);
      });

      test('returns true when none', () {
        networkService.state.value = [ConnectivityResult.none];
        expect(networkService.isNoNetwork, isTrue);
      });

      test('handles multiple states', () {
        networkService.state.value = [
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ];
        expect(networkService.isNoNetwork, isTrue);
      });
    });

    group('isMobileNetwork', () {
      test('returns true when mobile', () {
        networkService.state.value = [ConnectivityResult.mobile];
        expect(networkService.isMobileNetwork, isTrue);
      });

      test('returns false when wifi', () {
        networkService.state.value = [ConnectivityResult.wifi];
        expect(networkService.isMobileNetwork, isFalse);
      });

      test('handles multiple states', () {
        networkService.state.value = [
          ConnectivityResult.mobile,
          ConnectivityResult.wifi,
        ];
        expect(networkService.isMobileNetwork, isTrue);
      });
    });

    group('isSpeedNetwork', () {
      test('returns true when wifi', () {
        networkService.state.value = [ConnectivityResult.wifi];
        expect(networkService.isSpeedNetwork, isTrue);
      });

      test('returns true when ethernet', () {
        networkService.state.value = [ConnectivityResult.ethernet];
        expect(networkService.isSpeedNetwork, isTrue);
      });

      test('returns false when mobile', () {
        networkService.state.value = [ConnectivityResult.mobile];
        expect(networkService.isSpeedNetwork, isFalse);
      });

      test('returns false when none', () {
        networkService.state.value = [ConnectivityResult.none];
        expect(networkService.isSpeedNetwork, isFalse);
      });

      test('handles multiple states', () {
        networkService.state.value = [
          ConnectivityResult.mobile,
          ConnectivityResult.wifi,
        ];
        expect(networkService.isSpeedNetwork, isTrue);
      });
    });

    group('state changes', () {
      test('state is a RxList', () {
        expect(networkService.state, isA<RxList<NetworkState>>());
      });

      test('state updates are reactive', () {
        var notificationCount = 0;
        ever(networkService.state, (_) {
          notificationCount++;
        });

        networkService.state.value = [ConnectivityResult.wifi];
        expect(notificationCount, equals(1));

        networkService.state.value = [ConnectivityResult.mobile];
        expect(notificationCount, equals(2));
      });
    });
  });

  group('NetworkState type alias', () {
    test('NetworkState is ConnectivityResult', () {
      NetworkState state = ConnectivityResult.wifi;
      expect(state, equals(ConnectivityResult.wifi));
    });
  });
}

// Test-only implementation that doesn't require platform channels
class TestNetworkService extends INetworkService {
  @override
  RxList<NetworkState> state = RxList<NetworkState>();

  @override
  void dispose() {}

  @override
  bool get isMobileNetwork => state.value.contains(ConnectivityResult.mobile);

  @override
  bool get isNoNetwork => state.value.contains(ConnectivityResult.none);

  @override
  bool get isSpeedNetwork =>
      state.value.contains(ConnectivityResult.wifi) ||
      state.value.contains(ConnectivityResult.ethernet);

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.empty();

  @override
  void onInit({Future<void> Function()? callback}) {}
}
