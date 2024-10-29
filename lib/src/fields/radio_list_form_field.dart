// ignore_for_file: inference_failure_on_untyped_parameter

import 'package:flutter/material.dart';

import '../../formx.dart';
import 'widgets/formx_field.dart';

/// A `FormField<T>` that builds a list of [RadioListTile].
class RadioListFormField<T extends Object> extends FormxField<T> {
  /// Creates a `FormField<T>` that builds a list of [RadioListTile].
  ///
  /// The [items] are the list of items to be displayed.
  ///
  /// [title] and [subtitle] callbacks are used to build the [RadioListTile].
  ///
  /// If [isExpanded] is `false`, the [RadioListTile] will be wrapped in an
  /// [IntrinsicWidth]. Otherwise, it will expand to the full width.
  ///
  /// You can fully customize by using [itemBuilder] and [listBuilder] callback.
  /// A default implementation is provided to all builders.
  ///
  /// Additional customization can be done with the [decoration] and/or [ListTileTheme].
  ///
  const RadioListFormField({
    super.key,
    required this.items,
    this.title = _defaultTitle,
    this.subtitle,
    super.onChanged,
    super.autofocus,
    super.focusNode,
    super.forceErrorText,
    this.isExpanded = false,
    super.decoration,
    super.decorator,
    this.itemBuilder = _defaultItemBuilder,
    this.listBuilder = _defaultListBuilder,
    this.controlAffinity = ListTileControlAffinity.leading,
    super.initialValue,
    super.autovalidateMode,
    super.validator,
    super.onSaved,
    super.enabled,
    super.restorationId,
  });

  // Default implementations
  static Widget _defaultTitle(Object item) {
    return Text(Formx.setup.defaultTitle(item));
  }

  static Widget _defaultItemBuilder(state, item, Widget child) => child;
  static Widget _defaultListBuilder(state, List<Widget> children) {
    return Wrap(children: children);
  }

  /// The list of items to be displayed.
  final List<T> items;

  /// The callback to build the title of the [RadioListTile].
  final Widget Function(T item)? title;

  /// The callback to build the subtitle of the [RadioListTile].
  final Widget Function(T item)? subtitle;

  /// Whether the [RadioListTile] should expand to the full width.
  final bool isExpanded;

  /// The builder that creates each checkbox.
  final Widget Function(
    FormFieldState<T> state,
    T item,
    Widget child,
  ) itemBuilder;

  /// The builder that creates the list of checkboxes.
  final Widget Function(
    FormFieldState<T> state,
    List<Widget> children,
  ) listBuilder;

  /// The alignment of the checkbox.
  final ListTileControlAffinity controlAffinity;

  @override
  Widget build(FormFieldState<T> state) {
    final children = [
      for (final item in items)
        itemBuilder(
          state,
          item,
          RadioListTile(
            value: item,
            groupValue: state.value,
            title: title?.call(item),
            subtitle: subtitle?.call(item),
            controlAffinity: controlAffinity,
            onChanged: state.didChange,
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
