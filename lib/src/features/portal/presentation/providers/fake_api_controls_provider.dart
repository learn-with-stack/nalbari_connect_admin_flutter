import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final fakeApiControlsProvider = StateNotifierProvider<FakeApiControlsController, FakeApiControls>((ref) {
  return FakeApiControlsController();
});

enum FakeApiFailureMode { none, offline, serverError }

class FakeApiControls {
  const FakeApiControls({
    this.failureMode = FakeApiFailureMode.none,
    this.latencyMs = 650,
  });

  final FakeApiFailureMode failureMode;
  final int latencyMs;

  FakeApiControls copyWith({
    FakeApiFailureMode? failureMode,
    int? latencyMs,
  }) {
    return FakeApiControls(
      failureMode: failureMode ?? this.failureMode,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }
}

class FakeApiControlsController extends StateNotifier<FakeApiControls> {
  FakeApiControlsController() : super(const FakeApiControls());

  void setFailureMode(FakeApiFailureMode mode) {
    state = state.copyWith(failureMode: mode);
  }
}

class FakeApiException implements Exception {
  const FakeApiException(this.message, {required this.reason});

  final String message;
  final String reason;

  @override
  String toString() => '$message\nReason: $reason';
}
