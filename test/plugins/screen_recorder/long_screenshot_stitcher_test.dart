import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/screen_recorder/engine/long_screenshot_stitcher.dart';

/// Pseudo-random but deterministic hash-based signal — each position has a
/// unique value, so NCC can reliably identify the exact offset.
double _hash(int i) => ((i * 127 + 71) % 256).toDouble();

void main() {
  group('LongScreenshotStitcher - computeOffsets1D', () {
    test('identifies offset from downward scroll', () {
      const dim = 200;
      const scrollAmount = 30;
      final frame1 = Float32List(dim);
      final frame2 = Float32List(dim);

      for (int i = 0; i < dim; i++) {
        frame1[i] = _hash(i);
      }
      for (int i = 0; i < dim; i++) {
        frame2[i] = (i < dim - scrollAmount)
            ? frame1[i + scrollAmount]
            : _hash(i + 500);
      }

      final result = LongScreenshotStitcher.computeOffsets1D([
        frame1,
        frame2,
      ], dim);

      final offsets = result['offsets'] as List<int>;
      // First offset is always 0
      expect(offsets[0], 0);
      // Subsequent offsets should be positive (monotonically increasing)
      expect(offsets[1], greaterThan(0));
      expect(offsets[1], lessThan(dim));
      // NCC should find a strong match
      expect((result['avgNcc'] as double), greaterThan(0.9));
    });

    test('returns offset 0 for identical frames (no scroll)', () {
      const dim = 100;
      final frame = Float32List(dim);
      for (int i = 0; i < dim; i++) {
        frame[i] = _hash(i);
      }
      final result = LongScreenshotStitcher.computeOffsets1D([
        frame,
        Float32List.fromList(frame.toList()),
      ], dim);

      final offsets = result['offsets'] as List<int>;
      expect(offsets, [0, 0]);
      expect((result['avgNcc'] as double), greaterThan(0.99));
    });

    test('constrains monotonically increasing offsets', () {
      const dim = 100;
      // frame1: regular pattern
      // frame2: content pushed DOWN (user scrolled up — not allowed)
      // This produces a negative raw offset, which gets clamped to 0
      final frame1 = Float32List(dim);
      final frame2 = Float32List(dim);

      for (int i = 0; i < dim; i++) {
        frame1[i] = _hash(i);
        frame2[i] = (i >= 20) ? frame1[i - 20] : _hash(i + 300);
      }

      final result = LongScreenshotStitcher.computeOffsets1D([
        frame1,
        frame2,
      ], dim);

      final offsets = result['offsets'] as List<int>;
      expect(offsets[1], greaterThanOrEqualTo(0));
    });

    test('handles single frame', () {
      final frame = Float32List(50);
      for (int i = 0; i < 50; i++) {
        frame[i] = 128.0;
      }
      final result = LongScreenshotStitcher.computeOffsets1D([frame], 50);

      final offsets = result['offsets'] as List<int>;
      expect(offsets, [0]);
      expect((result['avgNcc'] as double), 0.0);
    });

    test('handles empty projections list', () {
      final result = LongScreenshotStitcher.computeOffsets1D(
        <Float32List>[],
        100,
      );

      final offsets = result['offsets'] as List<int>;
      expect(offsets, isEmpty);
      expect((result['avgNcc'] as double), 0.0);
    });
  });

  group('Auto-detection scoring', () {
    test('column NCC dominates when content scrolls horizontally', () {
      const colDim = 200;
      const rowDim = 100;
      const shift = 40;

      final rowProjs = <Float32List>[Float32List(rowDim), Float32List(rowDim)];
      final colProjs = <Float32List>[Float32List(colDim), Float32List(colDim)];

      // Row projections: uncorrelated noise
      for (int i = 0; i < rowDim; i++) {
        rowProjs[0][i] = _hash(i);
        rowProjs[1][i] = _hash(i + 1000);
      }

      // Column projections: shifted pattern (strong horizontal match)
      for (int i = 0; i < colDim; i++) {
        colProjs[0][i] = _hash(i);
      }
      for (int i = 0; i < colDim; i++) {
        colProjs[1][i] = (i < colDim - shift)
            ? colProjs[0][i + shift]
            : _hash(i + 500);
      }

      final vertResult = LongScreenshotStitcher.computeOffsets1D(
        rowProjs,
        rowDim,
      );
      final horizResult = LongScreenshotStitcher.computeOffsets1D(
        colProjs,
        colDim,
      );

      final horizNcc = horizResult['avgNcc'] as double;
      final vertNcc = vertResult['avgNcc'] as double;

      expect(horizNcc, greaterThan(0.8));
      expect(horizNcc, greaterThan(vertNcc));
    });

    test('row NCC dominates when content scrolls vertically', () {
      const rowDim = 200;
      const colDim = 100;
      const shift = 35;

      final rowProjs = <Float32List>[Float32List(rowDim), Float32List(rowDim)];
      final colProjs = <Float32List>[Float32List(colDim), Float32List(colDim)];

      // Row projections: shifted pattern (strong vertical match)
      for (int i = 0; i < rowDim; i++) {
        rowProjs[0][i] = _hash(i);
      }
      for (int i = 0; i < rowDim; i++) {
        rowProjs[1][i] = (i < rowDim - shift)
            ? rowProjs[0][i + shift]
            : _hash(i + 500);
      }

      // Column projections: uncorrelated noise
      for (int i = 0; i < colDim; i++) {
        colProjs[0][i] = _hash(i);
        colProjs[1][i] = _hash(i + 1000);
      }

      final vertResult = LongScreenshotStitcher.computeOffsets1D(
        rowProjs,
        rowDim,
      );
      final horizResult = LongScreenshotStitcher.computeOffsets1D(
        colProjs,
        colDim,
      );

      final vertNcc = vertResult['avgNcc'] as double;
      final horizNcc = horizResult['avgNcc'] as double;

      expect(vertNcc, greaterThan(0.8));
      expect(vertNcc, greaterThan(horizNcc));
    });
  });
}
