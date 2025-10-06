import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/scroll_extension.dart';
import 'async_search_base.dart';

/// A search field that builds results based on the [search] function.
class AsyncSearch<T extends Object> extends AsyncSearchBase<T> {
  /// Creates a async [SearchAnchor] field.
  ///
  /// Use [SearchBarTheme] for additional [SearchBar] customization.
  /// Use [SearchViewTheme] for additional [SearchAnchor] customization.
  ///
  const AsyncSearch({
    super.key,
    super.search,
    super.pagedSearch,
    super.onResults,
    super.debounce,
    required super.builder,
    super.viewBuilder = defaultViewBuilder,
    super.loadingBuilder,
    super.emptyBuilder,
    super.errorBuilder,
    super.scrollLoadingBuilder,
    SearchController? super.controller,
  });

  @override
  SearchController? get controller => super.controller as SearchController?;

  /// The default [AsyncSearch] view builder to show the search results.
  static Widget defaultViewBuilder(BuildContext context, Widget child) => child;

  /// Gets the [AsyncSearchState] from the [BuildContext].
  static AsyncSearchState<T> of<T extends Object>(BuildContext context) {
    return context.findAncestorStateOfType()!;
  }

  @override
  State<AsyncSearch<T>> createState() => AsyncSearchState<T>();
}

/// The state of the [AsyncSearch] widget.
class AsyncSearchState<T extends Object> extends State<AsyncSearch<T>> {
  Timer? _timer;
  var _results = <T>[];
  final _pagedResults = <T>[];

  (Object e, StackTrace s)? _error;
  var _completer = Completer<List<T>>();
  final _loading = ValueNotifier(false);
  var _query = '';
  var _selectedText = '';

  late final _controller = widget.controller ?? SearchController();
  var _page = 0;
  final _scrollLoading = ValueNotifier(false);
  var _isLastPage = false;

  ScrollPosition? _position;

  /// The current search query.
  String get query => _query;

  /// Whether the search is loading.
  ValueListenable<bool> get loading => _loading;

  /// Whether the search is paginating.
  ValueListenable<bool> get scrollLoading => _scrollLoading;

  /// The current page of the search.
  int get page => _page;

  /// Whether the search is on the last page.
  bool get isLastPage => _isLastPage;

  /// The error that occurred during the search.
  Object? get error => _error?.$1;

  /// The stack trace of the error that occurred during the search.
  StackTrace? get stackTrace => _error?.$2;

  /// The search results.
  List<T> get results => [..._results, ..._pagedResults];

  void _debounce(VoidCallback fn) {
    _sendResults(_results);

    _error = null;
    _timer?.cancel();
    _timer = Timer(widget.debounce, fn);
    _loading.value = true;
  }

  Future<void> _scrollListener() async {
    final (pagedSearch, position) = (widget.pagedSearch, _position);
    if (pagedSearch == null || position == null) return;

    if (position.isAtMax && !isLastPage && !scrollLoading.value) {
      _scrollLoading.value = true;
      Future(position.animateToMax).ignore();

      final future = pagedSearch(++_page, _selectedText);
      await Future<void>.delayed(widget.debounce);
      final list =
          await future.whenComplete(() => _scrollLoading.value = false);

      if (list.isEmpty) _isLastPage = true;
      _pagedResults.addAll(list);

      widget.onResults?.call(_results + _pagedResults);
    }
  }

  void _sendResults(List<T> results) {
    _loading.value = false;

    final hasEmptyBuilder = widget.emptyBuilder != null && results.isEmpty;
    final hasErrorBuilder = widget.errorBuilder != null && _error != null;
    final showEmptyView = hasEmptyBuilder || hasErrorBuilder;

    _completer.complete(_NeverEmptyList(results, enabled: showEmptyView));
    _completer = Completer<List<T>>();

    widget.onResults?.call(results);
  }

  Future<void> _search(String text) async {
    _query = text;
    try {
      if (widget.search != null) {
        _results = await widget.search!(text);
      } else {
        _isLastPage = false;
        _pagedResults.clear();
        _results = await widget.pagedSearch!(_page = 0, text);
      }
    } catch (e, s) {
      _error = (e, s);
    }
    _sendResults(_results);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _loading.dispose();
    _controller.dispose();
    _scrollLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: _controller,
      viewTrailing: [
        ListenableBuilder(
          listenable: Listenable.merge([loading, _controller]),
          builder: (context, __) {
            return switch (loading.value) {
              true => widget.loadingBuilder(context),
              false => IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _controller.closeView(_selectedText = ''),
                ),
            };
          },
        ),
      ],
      suggestionsBuilder: (context, controller) async {
        if (controller.text.isEmpty || controller.text == _selectedText) {
          _sendResults([]);

          return [];
        }

        _debounce(() => _search(controller.text));

        void select(String text) {
          _selectedText = text;
          controller.closeView(text);
          FocusScope.of(context).unfocus();
        }

        final values = await _completer.future;

        final view = ListenableBuilder(
          listenable: scrollLoading,
          builder: (context, _) {
            _position = Scrollable.of(context).position;
            _position?.addListener(_scrollListener);

            final results = [...values, ..._pagedResults];

            if ((_error, widget.errorBuilder) case ((var e, var s), var fn?)) {
              return fn(context, e, s);
            }
            if ((results.isEmpty, widget.emptyBuilder) case (true, var fn?)) {
              return fn(context);
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final result in results)
                  widget.builder(context, select, result),
                if (scrollLoading.value)
                  widget.scrollLoadingBuilder?.call(context) ??
                      widget.loadingBuilder(context),
              ],
            );
          },
        );

        return [
          Builder(builder: (context) => widget.viewBuilder(context, view)),
        ];
      },
    );
  }
}

class _NeverEmptyList<T> extends ListBase<T> {
  _NeverEmptyList(this._list, {this.enabled = true});
  final List<T> _list;
  final bool enabled;

  @override
  int get length => enabled ? -1 : _list.length;

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) => _list[index] = value;

  @override
  List<T> toList({bool growable = true}) => _list.toList(growable: growable);
}

extension on ScrollPosition {
  bool get isAtMax {
    return pixels >= maxScrollExtent;
  }
}
