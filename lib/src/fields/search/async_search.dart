import 'dart:async';

import 'package:flutter/material.dart';

import '../../extensions/scroll_extension.dart';
import 'async_search_base.dart';

/// An async search field that builds results based on the [search] function.
class AsyncSearch<T extends Object> extends AsyncSearchBase<T> {
  /// Creates a base class for async search fields.
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
    super.scrollLoadingBuilder,
  });

  /// The default [AsyncSearch] view builder to show the search results.
  static Widget defaultViewBuilder(BuildContext context, Widget child) => child;

  @override
  State<AsyncSearch<T>> createState() => _AsyncSearchState<T>();
}

class _AsyncSearchState<T extends Object> extends State<AsyncSearch<T>> {
  Timer? timer;
  var _results = <T>[];
  final _pagedResults = <T>[];

  var _completer = Completer<List<T>>();
  final loading = ValueNotifier(false);
  var _selectedText = '';
  final controller = SearchController();

  int page = 0;
  final scrollLoading = ValueNotifier(false);
  bool isLastPage = false;

  ScrollPosition? position;

  void debounce(VoidCallback fn) {
    sendResults(_results);

    timer?.cancel();
    timer = Timer(widget.debounce, fn);
    loading.value = true;
  }

  void scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      position?.animateTo(
        position!.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  Future<void> scrollListener() async {
    final (pagedSearch, position) = (widget.pagedSearch, this.position);
    if (pagedSearch == null || position == null) return;

    if (position.isAtMax && !isLastPage && !scrollLoading.value) {
      scrollLoading.value = true;
      Future(position.animateToMax).ignore();

      final future = pagedSearch(++page, _selectedText);
      await Future<void>.delayed(widget.debounce);
      final list = await future.whenComplete(() => scrollLoading.value = false);

      if (list.isEmpty) isLastPage = true;
      _pagedResults.addAll(list);

      widget.onResults?.call(_results + _pagedResults);
    }
  }

  void sendResults(List<T> results) {
    loading.value = false;

    _completer.complete(results);
    _completer = Completer<List<T>>();

    widget.onResults?.call(results + _pagedResults);
  }

  Future<void> search(String text) async {
    if (widget.search != null) {
      _results = await widget.search!(text);
    } else {
      isLastPage = false;
      _pagedResults.clear();
      _results = await widget.pagedSearch!(page = 0, text);
    }
    sendResults(_results);
  }

  @override
  void dispose() {
    timer?.cancel();
    loading.dispose();
    controller.dispose();
    scrollLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: controller,
      viewTrailing: [
        ListenableBuilder(
          listenable: Listenable.merge([loading, controller]),
          builder: (context, __) {
            return switch (loading.value) {
              true => widget.loadingBuilder(context),
              false => IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.closeView(_selectedText = ''),
                ),
            };
          },
        ),
      ],
      suggestionsBuilder: (context, controller) async {
        if (controller.text.isEmpty || controller.text == _selectedText) {
          sendResults([]);

          return [];
        }

        debounce(() => search(controller.text));

        void select(String text) {
          _selectedText = text;
          controller.closeView(text);
          FocusScope.of(context).unfocus();
        }

        final values = await _completer.future;

        final view = ListenableBuilder(
          listenable: scrollLoading,
          builder: (context, _) {
            position = Scrollable.of(context).position;
            position?.addListener(scrollListener);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final value in [...values, ..._pagedResults])
                  widget.builder(context, select, value),
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

extension on ScrollPosition {
  bool get isAtMax {
    return pixels >= maxScrollExtent;
  }
}
