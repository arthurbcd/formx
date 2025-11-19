import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../extensions/scroll_extension.dart';
import 'async_search_base.dart';

/// An autocomplete field that builds results based on the [search] function.
class AsyncAutocomplete<T extends Object> extends AsyncSearchBase<T> {
  /// Creates an async [Autocomplete] field.
  const AsyncAutocomplete({
    super.key,
    super.debounce,
    super.search,
    super.pagedSearch,
    super.onResults,
    required super.builder,
    super.viewBuilder = defaultViewBuilder,
    this.fieldViewBuilder = defaultFieldViewBuilder,
    super.loadingBuilder,
    super.emptyBuilder,
    super.errorBuilder,
    super.scrollLoadingBuilder,
    super.controller,
    super.enabled,
    super.readOnly,
  });

  /// The default [AsyncAutocomplete] view builder to show the search results.
  static Widget defaultViewBuilder(BuildContext context, Widget child) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: IntrinsicWidth(
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: child,
          ),
        ),
      ),
    );
  }

  /// The default [AsyncAutocomplete] view builder to show the search field.
  static Widget defaultFieldViewBuilder<T extends Object>(
    BuildContext context,
    TextEditingController textEditingController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    final widget = context.findAncestorWidgetOfExactType<AsyncAutocomplete>();
    return TextFormField(
      enabled: widget?.enabled,
      readOnly: widget?.readOnly ?? false,
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (_) => onFieldSubmitted(),
    );
  }

  /// The [AutocompleteFieldViewBuilder] to build the search field.
  final AutocompleteFieldViewBuilder fieldViewBuilder;

  /// Gets the [AsyncAutocompleteState] from the [BuildContext].
  static AsyncAutocompleteState<T> of<T extends Object>(BuildContext context) {
    return context.findAncestorStateOfType()!;
  }

  @override
  State<AsyncAutocomplete<T>> createState() => AsyncAutocompleteState<T>();
}

/// The [State] of the [AsyncAutocomplete].
class AsyncAutocompleteState<T extends Object>
    extends State<AsyncAutocomplete<T>> {
  Timer? _timer;
  var _results = <T>[];
  final _pagedResults = <T>[];

  (Object e, StackTrace s)? _error;
  var _completer = Completer<List<T>>();
  final _loading = ValueNotifier(false);
  var _query = '';
  var _selectedText = '';
  late final _scrollController = ScrollController()
    ..addListener(_scrollListener);
  int _page = 0;
  final _scrollLoading = ValueNotifier(false);
  bool _isLastPage = false;
  final _focus = FocusNode();

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
    final (pagedSearch, position) =
        (widget.pagedSearch, _scrollController.position);
    if (pagedSearch == null) return;

    if (position.isAtMax && !_isLastPage && !scrollLoading.value) {
      _scrollLoading.value = true;
      Future(position.animateToMax).ignore();

      final future = pagedSearch(++_page, _query);
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
    _scrollController.dispose();
    _scrollLoading.dispose();
    super.dispose();
  }

  late final controller = widget.controller ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      focusNode: _focus,
      textEditingController: controller,
      fieldViewBuilder: widget.fieldViewBuilder,
      displayStringForOption: (_) => _selectedText,
      optionsBuilder: (value) async {
        if (value.text.isEmpty || value.text == _selectedText) {
          _sendResults([]);

          return [];
        }
        _debounce(() => _search(value.text));

        return _completer.future;
      },
      optionsViewBuilder: (context, onSelected, values) {
        void select(T value, String text) {
          _selectedText = text;
          onSelected(value);

          FocusScope.of(context).unfocus();
        }

        final view = ListenableBuilder(
          listenable: Listenable.merge([_scrollLoading, _loading]),
          builder: (context, _) {
            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Builder(
                builder: (context) {
                  final results = values.toList() + _pagedResults;

                  if ((_error, widget.errorBuilder)
                      case ((var e, var s), var fn?)) {
                    return fn(context, e, s);
                  }
                  if ((results.isEmpty, widget.emptyBuilder)
                      case (true, var fn?)) {
                    return fn(context);
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final result in results)
                        widget.builder(
                          context,
                          (text) => select(result, text),
                          result,
                        ),
                      if (scrollLoading.value)
                        widget.scrollLoadingBuilder?.call(context) ??
                            widget.loadingBuilder(context),
                    ],
                  );
                },
              ),
            );
          },
        );

        return widget.viewBuilder(context, view);
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
