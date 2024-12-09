import 'package:flutter/widgets.dart';

/// Extensions for [ScrollPosition].
extension FormxScrollExtension on ScrollPosition {
  /// Scrolls the view to the [maxScrollExtent].
  Future<void> animateToMax({
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.fastOutSlowIn,
  }) async {
    await animateTo(maxScrollExtent, duration: duration, curve: curve);
  }

  /// Scrolls the view to the [minScrollExtent].
  Future<void> animateToMin({
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.fastOutSlowIn,
  }) async {
    await animateTo(minScrollExtent, duration: duration, curve: curve);
  }
}
