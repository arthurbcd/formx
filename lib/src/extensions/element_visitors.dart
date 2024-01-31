import 'package:flutter/widgets.dart';

/// A [BuildContext] extension for [Element], [State] and [Widget] visitings.
extension ContextElementExtension on BuildContext {
  /// Returns the first [T] with [filter] below this [BuildContext], or null.
  ///
  /// If [last] is true, then it will return the last [Element] found.
  /// Visiting last is O(N). Limit it with [limit].
  ///
  T? visitElementOrNull<T extends Element>({
    bool last = false,
    bool Function(T element)? filter,
    int limit = 10,
    VoidCallback? onLimit,
  }) {
    T? found;
    var count = 0;

    void visit(Element element) {
      if (element is T) {
        if (filter?.call(element) ?? true) {
          found = element;
          if (!last) return;
        }
      }
      if (count++ < limit) {
        element.visitChildren(visit);
      } else {
        onLimit?.call();
      }
    }

    visitChildElements(visit);
    return found;
  }

  /// Returns the first [T] with [filter] below this [BuildContext].
  ///
  /// If [last] is true, then it will return the last [Element] found.
  /// Visiting last is O(N). Limit it with [limit].
  ///
  T visitElement<T extends Element>({
    bool last = false,
    bool Function(T element)? filter,
    String? assertType,
    int limit = 10,
  }) {
    final list = <T>[];
    final element = visitElementOrNull<T>(
      last: last,
      limit: limit,
      onLimit: () {
        assert(false, 'No ${assertType ?? T} found. Limit of $limit reached.');
      },
      filter: (element) {
        list.add(element);
        return filter?.call(element) ?? true;
      },
    );
    final extra = list.isNotEmpty ? 'Found $list.' : '';
    assert(element != null, 'No ${assertType ?? T} at this context. $extra');
    return element!;
  }

  /// Returns the first [T] with [filter] below this [BuildContext], or null.
  ///
  /// If [last] is true, then it will return the last [Widget] found.
  /// Visiting last is O(N). Limit it with [limit].
  ///
  T? visitWidgetOrNull<T extends Widget>({
    bool last = false,
    bool Function(T widget)? filter,
    int limit = 10,
    VoidCallback? onLimit,
  }) {
    bool filterByT(Element e) =>
        e.widget is T && (filter?.call(e.widget as T) ?? true);

    return visitElementOrNull(
      last: last,
      limit: limit,
      onLimit: onLimit,
      filter: filterByT,
    )?.widget as T?;
  }

  /// Returns the first [T] with [filter] below this [BuildContext].
  ///
  /// If [last] is true, then it will return the last [Widget] found.
  /// Visiting last is O(N). Limit it with [limit].
  ///
  T visitWidget<T extends Widget>({
    bool last = false,
    bool Function(T widget)? filter,
    String? assertType,
    int limit = 10,
  }) {
    final list = <T>[];
    final widget = visitWidgetOrNull<T>(
      last: last,
      limit: limit,
      onLimit: () {
        assert(false, 'No ${assertType ?? T} found. Limit of $limit reached.');
      },
      filter: (widget) {
        list.add(widget);
        return filter?.call(widget) ?? true;
      },
    );
    final extra = list.isNotEmpty ? 'Found $list.' : '';
    assert(widget != null, 'No ${assertType ?? T} at this context. $extra');
    return widget!;
  }

  /// Returns the first [T] with [filter] below this [BuildContext], or null.
  ///
  /// If [last] is true, then it will return the last [State] found.
  /// Visiting last is O(N). Limit it with [limit].
  ///
  T? visitStateOrNull<T extends State>({
    bool last = false,
    bool Function(T state)? filter,
    int limit = 10,
    VoidCallback? onLimit,
  }) {
    bool filterByT(StatefulElement e) =>
        e.state is T && (filter?.call(e.state as T) ?? true);

    return visitElementOrNull(
      last: last,
      limit: limit,
      onLimit: onLimit,
      filter: filterByT,
    )?.state as T?;
  }

  /// Returns the first [T] with [filter] below this [BuildContext].
  ///
  /// If [last] is true, then it will return the last [State] found.
  /// Visiting last is O(N). Limit it with [limit].
  ///
  /// The [assertType], replaces [T] on assert messages.
  T visitState<T extends State>({
    bool last = false,
    bool Function(T state)? filter,
    String? assertType,
    int limit = 10,
  }) {
    final list = <T>[];
    final state = visitStateOrNull<T>(
      last: last,
      limit: limit,
      onLimit: () {
        assert(false, 'No ${assertType ?? T} found. Limit of $limit reached.');
      },
      filter: (state) {
        list.add(state);
        return filter?.call(state) ?? true;
      },
    );
    final extra = list.isNotEmpty ? 'Found $list.' : '';
    assert(state != null, 'No ${assertType ?? T} at this context. $extra');
    return state!;
  }
}
