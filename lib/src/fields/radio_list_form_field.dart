// ignore_for_file: inference_failure_on_untyped_parameter

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../formx.dart';

/// A `FormField<T>` that builds a list of [RadioListTile].
class RadioListFormField<T extends Object> extends FormField<T> {
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
    this.onChanged,
    this.isExpanded = false,
    this.decoration = const InputDecoration(),
    this.itemBuilder = _defaultItemBuilder,
    this.listBuilder = _defaultListBuilder,
    this.controlAffinity = ListTileControlAffinity.leading,
    super.initialValue,
    super.autovalidateMode,
    super.validator,
    super.onSaved,
    super.enabled,
    super.restorationId,
  }) : super(builder: _builder);

  // Default implementations
  static Widget _defaultTitle(Object item) {
    return Text(Formx.options.defaultTitle(item));
  }

  static Widget _defaultItemBuilder(state, item, Widget child) => child;
  static Widget _defaultListBuilder(state, List<Widget> children) {
    return Wrap(children: children);
  }

  static Widget _builder<T extends Object>(FormFieldState<T> state) {
    return _RadioListFormField<T>(RadioListFormFieldState(state));
  }

  /// The decoration to show around the [RadioListTile]s.
  final InputDecoration? decoration;

  /// The list of items to be displayed.
  final List<T> items;

  /// The callback to build the title of the [RadioListTile].
  final Widget Function(T item)? title;

  /// The callback to build the subtitle of the [RadioListTile].
  final Widget Function(T item)? subtitle;

  /// The callback that is called when the value changes.
  final ValueChanged<T?>? onChanged;

  /// Whether the [RadioListTile] should expand to the full width.
  final bool isExpanded;

  /// The builder that creates each checkbox.
  final Widget Function(
    RadioListFormFieldState<T> state,
    T item,
    Widget child,
  ) itemBuilder;

  /// The builder that creates the list of checkboxes.
  final Widget Function(
    RadioListFormFieldState<T> state,
    List<Widget> children,
  ) listBuilder;

  /// The alignment of the checkbox.
  final ListTileControlAffinity controlAffinity;
}

class _RadioListFormField<T extends Object> extends StatelessWidget {
  const _RadioListFormField(this.state);
  final RadioListFormFieldState<T> state;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final children = [
      for (final item in widget.items)
        widget
            .itemBuilder(
              state,
              item,
              RadioListTile(
                value: item,
                groupValue: state.value,
                title: widget.title?.call(item),
                subtitle: widget.subtitle?.call(item),
                controlAffinity: widget.controlAffinity,
                onChanged: (value) {
                  state.didChange(value);
                  widget.onChanged?.call(value);
                },
              ),
            )
            .useIntrinsicWidth(!widget.isExpanded),
    ];

    var child = widget.listBuilder(state, children);

    if (widget.decoration case var decoration?) {
      // TODO(art): verify the need to manage isFocused & isHovering, etc.
      child = InputDecorator(
        decoration: decoration.copyWith(errorText: state.errorText),
        child: child,
      );
    }

    return child;
  }
}

/// The state of a [RadioListFormField].
extension type RadioListFormFieldState<T extends Object>(
    FormFieldState<T> state) implements FormFieldState<T> {
  /// The [RadioListFormField] of this [FormFieldState].
  @redeclare
  RadioListFormField<T> get widget => state.widget as RadioListFormField<T>;
}

extension on Widget {
  Widget useIntrinsicWidth(bool value) {
    return value ? IntrinsicWidth(child: this) : this;
  }
}
