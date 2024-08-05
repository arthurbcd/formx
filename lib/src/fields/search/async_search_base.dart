import 'dart:async';

import 'package:flutter/material.dart';

/// The base class for async search fields.
abstract class AsyncSearchBase<T extends Object> extends StatefulWidget {
  /// Creates a base class for async search fields.
  const AsyncSearchBase({
    super.key,
    required this.search,
    required this.pagedSearch,
    this.onResults,
    this.debounce = const Duration(milliseconds: 600),
    required this.builder,
    required this.viewBuilder,
    this.loadingBuilder = defaultLoadingBuilder,
    this.scrollLoadingBuilder,
  }) : assert(search != null || pagedSearch != null, 'must set a search');

  /// The default loading builder to show while searching.
  static Widget defaultLoadingBuilder(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  /// The debounce duration to wait before calling each [search] function.
  final Duration debounce;

  /// The search function to call when the user types in the search field.
  final AsyncSearchCallback<T>? search;

  /// The paged search function to call when the user types in the search field.
  final AsyncPagedSearchCallback<T>? pagedSearch;

  /// The builder to show and select each search result.
  final AsyncSearchBuilder<T> builder;

  /// The loading builder to show while searching.
  final WidgetBuilder loadingBuilder;

  /// The loading builder to show while scrolling.
  ///
  /// Defaults to [loadingBuilder].
  final WidgetBuilder? scrollLoadingBuilder;

  /// The view that will hold the search results of [builder].
  final AsyncSearchViewBuilder viewBuilder;

  /// The results of the search.
  final ValueChanged<List<T>>? onResults;
}

/// Signature for returning a list of items based on a [query].
typedef AsyncSearchCallback<T> = Future<List<T>> Function(String query);

/// Signature for returning a list of items based on [query] and current [page].
typedef AsyncPagedSearchCallback<T> = Future<List<T>> Function(
  int page,
  String query,
);

/// Signature for building the search results with [value] selector.
typedef AsyncSearchBuilder<T> = Widget Function(
  BuildContext context,
  void Function(String value) onSelected,
  T value,
);

/// Signature for building the search view with [child] results.
typedef AsyncSearchViewBuilder<T> = Widget Function(
  BuildContext context,
  Widget child,
);
