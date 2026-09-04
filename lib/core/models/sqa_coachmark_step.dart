import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the tooltip card appears relative to the highlighted target widget.
enum CoachmarkContentAlign {
  /// Card appears above the target.
  top,

  /// Card appears below the target.
  bottom,

  /// Card appears to the left of the target.
  left,

  /// Card appears to the right of the target.
  right,
}

/// A single step in a coachmark tour.
///
/// Each step highlights a specific widget (via [targetKey]) and shows a tooltip
/// card with a [title] and [description].
///
/// The optional [beforeStepAction] is an async callback that runs **before** the
/// spotlight is drawn. Use it to drive UI state (scroll, tab switch, navigate)
/// so the target widget is visible and rendered when the spotlight appears.
class SqaCoachmarkStep {
  /// A [GlobalKey] pointing to the widget to highlight.
  final GlobalKey targetKey;

  /// Short heading shown in the tooltip card (e.g. "Your Plugin Bar").
  final String title;

  /// Supporting description shown below the title (max ~2 sentences).
  final String description;

  /// Where the tooltip card is positioned relative to the target widget.
  final CoachmarkContentAlign contentAlign;

  /// An optional async action run *before* the spotlight renders.
  ///
  /// Typical uses:
  /// - `scrollController.animateTo(...)`
  /// - `tabController.animateTo(...)`
  /// - `ref.read(navigationServiceProvider).togglePlugin(...)`
  ///
  /// The coachmark engine awaits this future, then waits for a post-frame
  /// callback before computing the target bounding box.
  final Future<void> Function(WidgetRef ref)? beforeStepAction;

  const SqaCoachmarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.contentAlign = CoachmarkContentAlign.bottom,
    this.beforeStepAction,
  });
}
