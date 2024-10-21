import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../extensions/formx_extension.dart';
import 'search/async_autocomplete.dart';
import 'search/async_search_base.dart';

/// A `FormField<T>` that contains a [AsyncAutocomplete] widget.
class AutocompleteFormField<T extends Object> extends FormField<T> {
  /// Creates a `FormField<T>` on top of a [ListTile] based [AsyncAutocomplete].
  ///
  /// This field builds results based on the [search] function.
  const AutocompleteFormField({
    required AsyncSearchCallback<T> this.search,
    this.title = _defaultTitle,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onSelected,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    this.loadingBuilder = AsyncSearchBase.defaultLoadingBuilder,
    this.scrollLoadingBuilder,
    this.decoration = const InputDecoration(),
    super.key,
    super.initialValue,
    super.enabled,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.restorationId,
  })  : pagedSearch = null,
        super(builder: _builder);

  /// Creates a `FormField<T>` on top of a [ListTile] based [AsyncAutocomplete].
  ///
  /// This field builds paged results based on the [search] function.
  const AutocompleteFormField.paged({
    required AsyncPagedSearchCallback<T> search,
    this.title = _defaultTitle,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onSelected,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    this.loadingBuilder = AsyncSearchBase.defaultLoadingBuilder,
    this.scrollLoadingBuilder,
    this.decoration = const InputDecoration(),
    super.key,
    super.initialValue,
    super.enabled,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.restorationId,
  })  : search = null,
        pagedSearch = search,
        super(builder: _builder);

  static String _defaultTitle(Object item) => Formx.setup.defaultTitle(item);

  /// The search function to call when the user types in the search field.
  final AsyncSearchCallback<T>? search;

  /// The paged search function to call when the user types in the search field.
  final AsyncPagedSearchCallback<T>? pagedSearch;

  /// The title callback is used to build the [ListTile].
  final String Function(T value) title;

  /// The subtitle callback is used to build the [ListTile].
  final String Function(T value)? subtitle;

  /// The leading callback is used to build the [ListTile].
  final Widget Function(T value)? leading;

  /// The trailing callback is used to build the [ListTile].
  final Widget Function(T value)? trailing;

  /// The callback that is called when the value is selected.
  final ValueChanged<T?>? onSelected;

  /// The callback that is called when the results are changed.
  final ValueChanged<List<T>>? onResults;

  /// The debounce duration to wait before calling each [search] function.
  final Duration debounce;

  /// The decoration to show in the internal [TextFormField].
  final InputDecoration? decoration;

  /// The loading builder to show while searching.
  final WidgetBuilder loadingBuilder;

  /// The loading builder to show while paging.
  ///
  /// Defaults to [loadingBuilder].
  final WidgetBuilder? scrollLoadingBuilder;

  static Widget _builder<T extends Object>(FormFieldState<T> state) {
    return _AutocompleteFormField(AutocompleteFormFieldState(state));
  }
}

class _AutocompleteFormField<T extends Object> extends StatefulWidget {
  const _AutocompleteFormField(this.state);
  final AutocompleteFormFieldState<T> state;

  @override
  State<_AutocompleteFormField<T>> createState() =>
      _AutocompleteFormFieldState<T>();
}

class _AutocompleteFormFieldState<T extends Object>
    extends State<_AutocompleteFormField<T>> {
  TextEditingController? controller;

  final asyncKey = GlobalKey<AsyncAutocompleteState<T>>();

  @override
  Widget build(BuildContext context) {
    final state = this.widget.state;
    final widget = state.widget;

    return AsyncAutocomplete(
      key: asyncKey,
      search: widget.search,
      pagedSearch: widget.pagedSearch,
      onResults: widget.onResults,
      loadingBuilder: widget.loadingBuilder,
      scrollLoadingBuilder: widget.scrollLoadingBuilder,
      debounce: widget.debounce,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (this.controller == null && state.value != null) {
          this.controller ??= controller..text = widget.title(state.value!);
        }
        final asyncState = asyncKey.currentState!;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: widget.decoration?.copyWith(
            suffixIcon: ListenableBuilder(
              listenable: asyncState.loading,
              builder: (context, child) {
                return asyncState.loading.value
                    ? widget.loadingBuilder(context)
                    : widget.decoration?.suffix ?? const SizedBox();
              },
            ),
          ),
          validator: (_) => widget.validator?.call(state.value),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      builder: (_, onSelected, value) {
        return ListTile(
          dense: true,
          title: Text(widget.title(value)),
          subtitle: switch (widget.subtitle) {
            null => null,
            var subtitle => Text(subtitle(value)),
          },
          leading: widget.leading?.call(value),
          trailing: widget.trailing?.call(value),
          onTap: () {
            onSelected(widget.title(value));

            state.didChange(value);
            widget.onSelected?.call(value);
          },
        );
      },
    );
  }
}

/// A [FormFieldState] that exposes the [AutocompleteFormField] instance.
extension type AutocompleteFormFieldState<T extends Object>(
    FormFieldState<T> state) implements FormFieldState<T> {
  @redeclare
  AutocompleteFormField<T> get widget =>
      state.widget as AutocompleteFormField<T>;
}
