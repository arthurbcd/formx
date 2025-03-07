import 'package:flutter/material.dart';

import '../formx_state.dart';
import 'search/async_autocomplete.dart';
import 'search/async_search_base.dart';
import 'widgets/formx_field.dart';

/// A `FormField<T>` that contains a [AsyncAutocomplete] widget.
class AutocompleteFormField<T extends Object> extends FormxField<T> {
  /// Creates a `FormField<T>` on top of a [ListTile] based [AsyncAutocomplete].
  ///
  /// This field builds results based on the [search] function.
  const AutocompleteFormField({
    required AsyncSearchCallback<T> this.search,
    this.title = _defaultTitle,
    this.subtitle,
    this.leading,
    this.trailing,
    super.onChanged,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    this.loadingBuilder = AsyncSearchBase.defaultLoadingBuilder,
    this.errorBuilder = AsyncSearchBase.defaultErrorBuilder,
    this.emptyBuilder,
    this.scrollLoadingBuilder,
    super.decoration,
    super.key,
    super.initialValue,
    super.enabled,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.restorationId,
  }) : pagedSearch = null;

  /// Creates a `FormField<T>` on top of a [ListTile] based [AsyncAutocomplete].
  ///
  /// This field builds paged results based on the [search] function.
  const AutocompleteFormField.paged({
    required AsyncPagedSearchCallback<T> search,
    this.title = _defaultTitle,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    this.loadingBuilder = AsyncSearchBase.defaultLoadingBuilder,
    this.errorBuilder = AsyncSearchBase.defaultErrorBuilder,
    this.emptyBuilder,
    this.scrollLoadingBuilder,
    super.key,
    super.autofocus,
    super.autovalidateMode,
    super.decoration,
    super.decorator,
    super.enabled,
    super.focusNode,
    super.forceErrorText,
    super.initialValue,
    super.onChanged,
    super.onSaved,
    super.restorationId,
    super.validator,
  })  : search = null,
        pagedSearch = search;

  static String _defaultTitle(Object item) => Formx.setup.defaultTitle(item);

  /// The search function to call when the user types in the search field.
  final AsyncSearchCallback<T>? search;

  /// The paged search function to call when the user types in the search field.
  final AsyncPagedSearchCallback<T>? pagedSearch;

  /// The title callback is used to build the [ListTile].
  final String Function(T value) title;

  /// The subtitle callback is used to build the [ListTile].
  final Widget Function(T value)? subtitle;

  /// The leading callback is used to build the [ListTile].
  final Widget Function(T value)? leading;

  /// The trailing callback is used to build the [ListTile].
  final Widget Function(T value)? trailing;

  /// The callback that is called when the results are changed.
  final ValueChanged<List<T>>? onResults;

  /// The debounce duration to wait before calling each [search] function.
  final Duration debounce;

  /// The loading builder to show while searching.
  final WidgetBuilder loadingBuilder;

  /// The view builder to show when results are empty. If null, shows nothing.
  final WidgetBuilder? emptyBuilder;

  /// The view builder to show when an error occurs. If null, shows nothing.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )? errorBuilder;

  /// The loading builder to show while paging.
  ///
  /// Defaults to [loadingBuilder].
  final WidgetBuilder? scrollLoadingBuilder;

  @override
  Widget build(FormFieldState<T> state) {
    return AsyncAutocomplete(
      search: search,
      pagedSearch: pagedSearch,
      onResults: onResults,
      loadingBuilder: loadingBuilder,
      scrollLoadingBuilder: scrollLoadingBuilder,
      debounce: debounce,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (state.value != null && controller.text.isEmpty) {
          controller.text = title(state.value!);
        }
        final loading = context
            .findAncestorStateOfType<AsyncAutocompleteState<T>>()!
            .loading;

        return TextFormField(
          controller: controller,
          autofocus: autofocus,
          focusNode: focusNode,
          decoration: decoration?.copyWith(
            suffixIcon: ListenableBuilder(
              listenable: loading,
              builder: (context, child) {
                return loading.value
                    ? loadingBuilder(context)
                    : decoration?.suffix ?? const SizedBox();
              },
            ),
          ),
          validator: (_) => validator?.call(state.value),
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      builder: (_, onSelected, value) {
        return ListTile(
          dense: true,
          title: Text(title(value)),
          subtitle: subtitle?.call(value),
          leading: leading?.call(value),
          trailing: trailing?.call(value),
          onTap: () {
            onSelected(title(value));
            state.didChange(value);
          },
        );
      },
    );
  }

  @override
  Widget buildDecorator(FormxFieldState<T> state, Widget child) => child;
}
