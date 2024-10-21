import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../extensions/formx_extension.dart';

/// A `FormField<List<T>>` that builds a list of [CheckboxListTile].
class CheckboxListFormField<T extends Object> extends FormField<List<T>> {
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
    this.onChanged,
    this.isExpanded = false,
    this.isExclusive = false,
    this.decoration = const InputDecoration(),
    this.itemBuilder = _defaultItemBuilder,
    this.listBuilder = _defaultListBuilder,
    this.controlAffinity = ListTileControlAffinity.leading,
    super.initialValue = const [],
    super.autovalidateMode,
    super.validator,
    super.onSaved,
    super.enabled,
    super.restorationId,
  }) : super(builder: _builder);

  static Widget _defaultTitle(Object item) {
    return Text(Formx.setup.defaultTitle(item));
  }

  static Widget _defaultItemBuilder(state, item, Widget child) => child;
  static Widget _defaultListBuilder(state, List<Widget> children) {
    return Wrap(children: children);
  }

  static Widget _builder<T extends Object>(FormFieldState<List<T>> state) {
    return _CheckboxListFormField<T>(CheckboxListFormFieldState(state));
  }

  /// The decoration to show around the [CheckboxListTile]s.
  final InputDecoration? decoration;

  /// The list of items to be displayed.
  final List<T> items;

  /// The callback to build the title of the [CheckboxListTile].
  final Widget Function(T item)? title;

  /// The callback to build the subtitle of the [CheckboxListTile].
  final Widget Function(T item)? subtitle;

  /// The callback that is called when the value changes.
  final ValueChanged<List<T>>? onChanged;

  /// Whether the [CheckboxListTile] should expand to the full width.
  final bool isExpanded;

  /// Whether the [CheckboxListTile] should be exclusive (single selection).
  final bool isExclusive;

  /// The builder that creates each checkbox.
  final Widget Function(
    CheckboxListFormFieldState<T> state,
    T item,
    Widget child,
  ) itemBuilder;

  /// The builder that creates the list of checkboxes.
  final Widget Function(
    CheckboxListFormFieldState<T> state,
    List<Widget> children,
  ) listBuilder;

  /// The alignment of the checkbox.
  final ListTileControlAffinity controlAffinity;
}

class _CheckboxListFormField<T extends Object> extends StatelessWidget {
  const _CheckboxListFormField(this.state);
  final CheckboxListFormFieldState<T> state;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final children = [
      for (final item in widget.items)
        widget
            .itemBuilder(
              state,
              item,
              CheckboxListTile(
                controlAffinity: widget.controlAffinity,
                title: widget.title?.call(item),
                subtitle: widget.subtitle?.call(item),
                value: state.value?.contains(item) ?? false,
                onChanged: (value) {
                  final list = [...?state.value];

                  if (widget.isExclusive) {
                    state.didChange(value ?? false ? [item] : []);
                  } else if (value ?? false) {
                    state.didChange(list..add(item));
                  } else {
                    state.didChange(list..remove(item));
                  }

                  widget.onChanged?.call(list);
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

/// The state of a [CheckboxListFormField].
extension type CheckboxListFormFieldState<T extends Object>(
    FormFieldState<List<T>> state) implements FormFieldState<List<T>> {
  /// The [CheckboxListFormField] of this [FormFieldState].
  @redeclare
  CheckboxListFormField<T> get widget =>
      state.widget as CheckboxListFormField<T>;
}

extension on Widget {
  Widget useIntrinsicWidth(bool value) {
    return value ? IntrinsicWidth(child: this) : this;
  }
}
