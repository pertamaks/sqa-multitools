import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:sqa_multitools/core/window/display_utils.dart';

void main() {
  group('DisplayUtils', () {
    test('getPrimaryDisplay finds display at (0,0)', () {
      final primary = Display(
        id: 1,
        name: 'Primary Display',
        size: const Size(1920, 1200),
        visiblePosition: Offset.zero,
        visibleSize: const Size(1920, 1200),
        scaleFactor: 1.25,
      );
      final secondary = Display(
        id: 2,
        name: 'Secondary Display',
        size: const Size(1920, 1080),
        visiblePosition: const Offset(1920, 0),
        visibleSize: const Size(1920, 1080),
        scaleFactor: 1.0,
      );

      final found = DisplayUtils.getPrimaryDisplay([secondary, primary]);
      expect(found.id, equals(1));
    });

    test('getDisplayFlutterBounds normalizes secondary display size relative to primary scale factor', () {
      final primary = Display(
        id: 1,
        name: 'Primary Display (125%)',
        size: const Size(1920, 1200),
        visiblePosition: Offset.zero,
        visibleSize: const Size(1920, 1200),
        scaleFactor: 1.25,
      );
      final secondary = Display(
        id: 2,
        name: 'Secondary Display (100%)',
        size: const Size(1920, 1080),
        visiblePosition: const Offset(1920, 0),
        visibleSize: const Size(1920, 1080),
        scaleFactor: 1.0,
      );

      final displays = [primary, secondary];

      final primaryBounds = DisplayUtils.getDisplayFlutterBounds(
        primary,
        allDisplays: displays,
      );
      expect(primaryBounds, equals(const Rect.fromLTWH(0, 0, 1920, 1200)));

      final secondaryBounds = DisplayUtils.getDisplayFlutterBounds(
        secondary,
        allDisplays: displays,
      );
      // Secondary has 1.0 scale vs primary 1.25 scale => 1920 * (1.0 / 1.25) = 1536, 1080 * (1.0 / 1.25) = 864
      expect(secondaryBounds.left, equals(1920));
      expect(secondaryBounds.top, equals(0));
      expect(secondaryBounds.width, equals(1536.0));
      expect(secondaryBounds.height, equals(864.0));
    });
  });
}
