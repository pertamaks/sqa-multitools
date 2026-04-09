import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/unix_state.dart';

part 'unix_provider.g.dart';

@riverpod
class UnixNotifier extends _$UnixNotifier {
  Timer? _ticker;

  @override
  UnixState build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });

    final now = DateTime.now();
    _startTicker();

    return UnixState(
      manualDateTime: now,
      manualTimestampString: (now.millisecondsSinceEpoch ~/ 1000).toString(),
      isLive: true,
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isLive) {
        final now = DateTime.now();
        state = state.copyWith(
          manualDateTime: now,
          manualTimestampString: (now.millisecondsSinceEpoch ~/ 1000)
              .toString(),
        );
      }
    });
  }

  void setDateTime(DateTime dt) {
    state = state.copyWith(
      manualDateTime: dt,
      isLive: false,
      lastInteractionWasDateTime: true,
    );
  }

  void setTimestampString(String ts) {
    state = state.copyWith(
      manualTimestampString: ts,
      isLive: false,
      lastInteractionWasDateTime: false,
    );
  }

  void convert() {
    if (state.lastInteractionWasDateTime) {
      // Convert DT to Unix
      final ts = (state.manualDateTime.millisecondsSinceEpoch ~/ 1000)
          .toString();
      state = state.copyWith(manualTimestampString: ts);
    } else {
      // Convert Unix to DT
      final tsInt = int.tryParse(state.manualTimestampString);
      if (tsInt != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(tsInt * 1000);
        state = state.copyWith(manualDateTime: dt);
      }
    }
  }

  void resetToNow() {
    final now = DateTime.now();
    state = state.copyWith(
      manualDateTime: now,
      manualTimestampString: (now.millisecondsSinceEpoch ~/ 1000).toString(),
      isLive: true,
    );
    _startTicker();
  }

  void toggleLive() {
    if (state.isLive) {
      state = state.copyWith(isLive: false);
    } else {
      resetToNow();
    }
  }
}
