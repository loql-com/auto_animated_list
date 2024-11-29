// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:ui';

import 'package:auto_animated_list/auto_animated_list.dart';
import 'package:flutter/material.dart';

extension ListControllerExtension on ListController {
  /// Like [animateToItem], but animates in the closest [Scrollable] ancestor
  /// of the given [context].
  ///
  /// If https://github.com/superlistapp/super_sliver_list/issues/74 gets
  /// resolved, we won't need this method anymore.
  ///
  /// This is adapted from `package:super_sliver_list/src/animate_to_item.dart
  TickerFuture animateToItemInScrollable(
    BuildContext context, {
    required int index,
    required double alignment,
    required Duration Function(double estimatedDistance) duration,
    required Curve Function(double estimatedDistance) curve,
    Rect? rect,
  }) {
    final scrollable = Scrollable.of(context);
    final position = scrollable.position;
    final start = position.pixels;

    final estimatedTarget = getOffsetToReveal(
      index,
      alignment,
      rect: rect,
    );
    final estimatedDistance = (estimatedTarget - start).abs();
    final controller = AnimationController(
      vsync: position.context.vsync,
      duration: duration(estimatedDistance),
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve(estimatedDistance),
    );
    animation.addListener(() {
      final value = animation.value;
      var targetPosition = getOffsetToReveal(
        index,
        alignment,
        rect: rect,
      );
      if (value < 1.0) {
        // Clamp position during animation to prevent overscroll.
        targetPosition = targetPosition.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
      }
      final jumpPosition = lerpDouble(start, targetPosition, value)!;
      if ((jumpPosition <= position.minScrollExtent &&
              position.pixels == position.minScrollExtent) ||
          (jumpPosition >= position.maxScrollExtent &&
              position.pixels == position.maxScrollExtent)) {
        // Do not jump when already at the edge. This prevents scrollbar handle artifacts.
        return;
      }
      position.jumpTo(jumpPosition);
    });
    return controller.forward();
  }
}
