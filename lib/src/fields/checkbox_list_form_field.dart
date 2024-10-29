import 'package:flutter/material.dart';

import '../extensions/formx_extension.dart';
import 'widgets/formx_field.dart';

/// A `FormField<List<T>>` that builds a list of [CheckboxListTile].
class CheckboxListFormField<T extends Object> extends FormxField<List<T>> {
  /// Creates a `FormField<List<T>>` that builds a list of [CheckboxListTile].
  ///
  /// The [items] are the list of items to be displayed.
  ///
  /// [title] and [subtitle] callbacks are used to build the [CheckboxListTile].
  ///
  /// If [isExpanded] is `false`, the [CheckboxListTile] will be wrapped in an
  /// [IntrinsicWidth]. Otherwise, it will expand to the full width.
  ///
  /// You can fully customize by using [itemBuilder] and [listBuilder] callback.
  /// A default implementation is provided to all builders.
  ///
  /// Additional customization can be done with the [decoration] and/or [ListTileTheme].
  ///
  const CheckboxListFormField({
    super.key,
    required this.items,
    this.title = _defaultTitle,
    this.subtitle,
    this.isExpanded = false,
    this.isExclusive = false,
    this.itemBuilder = _defaultItemBuilder,
    this.listBuilder = _defaultListBuilder,
    this.controlAffinity = ListTileControlAffinity.leading,
    List<T> super.initialValue = const [],
    super.onChanged,
    super.autofocus,
    super.focusNode,
    super.decoration,
    super.decorator,
    super.autovalidateMode,
    super.validator,
    super.onSaved,
    super.enabled,
    super.restorationId,
  });

  static Widget _defaultTitle(Object item) {
    return Text(Formx.setup.defaultTitle(item));
  }

  static Widget _defaultItemBuilder(state, item, Widget child) => child;
  static Widget _defaultListBuilder(state, List<Widget> children) {
    return Wrap(children: children);
  }

  /// The list of items to be displayed.
  final List<T> items;

  /// The callback to build the title of the [CheckboxListTile].
  final Widget Function(T item)? title;

  /// The callback to build the subtitle of the [CheckboxListTile].
  final Widget Function(T item)? subtitle;

  /// Whether the [CheckboxListTile] should expand to the full width.
  final bool isExpanded;

  /// Whether the [CheckboxListTile] should be exclusive (single selection).
  final bool isExclusive;

  /// The builder that creates each checkbox.
  final Widget Function(
    FormFieldState<List<T>> state,
    T item,
    Widget child,
  ) itemBuilder;

  /// The builder that creates the list of checkboxes.
  final Widget Function(
    FormFieldState<List<T>> state,
    List<Widget> children,
  ) listBuilder;

  /// The alignment of the checkbox.
  final ListTileControlAffinity controlAffinity;

  @override
  Widget build(FormFieldState<List<T>> state) {
    final children = [
      for (final item in items)
        itemBuilder(
          state,
          item,
          CheckboxListTile(
            controlAffinity: controlAffinity,
            title: title?.call(item),
            subtitle: subtitle?.call(item),
            value: state.value?.contains(item) ?? false,
            onChanged: (value) {
              final list = [...?state.value];

              if (isExclusive) {
                state.didChange(value ?? false ? [item] : []);
              } else if (value ?? false) {
                state.didChange(list..add(item));
              } else {
                state.didChange(list..remove(item));
              }

              onChanged?.call(list);
            },
          ),
        ).useIntrinsicWidth(!isExpanded),
    ];

    return listBuilder(state, children);
  }
}

extension on Widget {
  Widget useIntrinsicWidth(bool value) {
    return value ? IntrinsicWidth(child: this) : this;
  }
}
