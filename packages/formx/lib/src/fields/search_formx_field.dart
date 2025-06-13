import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../formx.dart';

/// A `FormField<T>` that contains a [AsyncAutocomplete] widget.
class SearchFormxField<T extends Object> extends FormField<T> {
  /// Creates a `FormField<T>` on top of a [ListTile] based [AsyncAutocomplete].
  ///
  /// This field builds results based on the [search] function.
  ///
  /// Use [SearchBarThemeData] for additional customization.
  ///
  const SearchFormxField({
    required AsyncSearchCallback<T> this.search,
    this.title = _defaultTitle,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onSelected,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    this.loadingBuilder = AsyncSearchBase.defaultLoadingBuilder,
    this.viewErrorBuilder = AsyncSearchBase.defaultErrorBuilder,
    this.emptyBuilder,
    this.scrollLoadingBuilder,
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
  const SearchFormxField.paged({
    required AsyncPagedSearchCallback<T> search,
    this.title = _defaultTitle,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onSelected,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    this.loadingBuilder = AsyncSearchBase.defaultLoadingBuilder,
    this.viewErrorBuilder = AsyncSearchBase.defaultErrorBuilder,
    this.emptyBuilder,
    this.scrollLoadingBuilder,
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

  /// The callback that is called when the search results are changed.
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
  )? viewErrorBuilder;

  /// The loading builder to show while paging.
  ///
  /// Defaults to [loadingBuilder].
  final WidgetBuilder? scrollLoadingBuilder;

  static Widget _builder<T extends Object>(FormFieldState<T> state) {
    return _AutocompleteFormField(SearchFormFieldState(state));
  }

  static String _defaultTitle(Object item) => Formx.setup.defaultTitle(item);
}

class _AutocompleteFormField<T extends Object> extends StatelessWidget {
  const _AutocompleteFormField(this.state);
  final SearchFormFieldState<T> state;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    return AsyncSearch(
      search: widget.search,
      pagedSearch: widget.pagedSearch,
      onResults: widget.onResults,
      loadingBuilder: widget.loadingBuilder,
      scrollLoadingBuilder: widget.scrollLoadingBuilder,
      debounce: widget.debounce,
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

/// A [FormFieldState] that exposes the [SearchFormxField] instance.
extension type SearchFormFieldState<T extends Object>(FormFieldState<T> state)
    implements FormFieldState<T> {
  @redeclare
  SearchFormxField<T> get widget => state.widget as SearchFormxField<T>;
}
