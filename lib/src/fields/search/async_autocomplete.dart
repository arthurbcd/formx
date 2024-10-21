// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';

import '../../extensions/scroll_extension.dart';
import 'async_search_base.dart';

class AsyncAutocomplete<T extends Object> extends AsyncSearchBase<T> {
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
    super.scrollLoadingBuilder,
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
    return TextFormField(
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (_) => onFieldSubmitted(),
    );
  }

  final AutocompleteFieldViewBuilder fieldViewBuilder;

  @override
  State<AsyncAutocomplete<T>> createState() => AsyncAutocompleteState<T>();
}

/// The [State] of the [AsyncAutocomplete].
class AsyncAutocompleteState<T extends Object>
    extends State<AsyncAutocomplete<T>> {
  Timer? timer;
  var _results = <T>[];
  final _pagedResults = <T>[];

  var _completer = Completer<List<T>>();
  final loading = ValueNotifier(false);
  var _selectedText = '';
  late final scrollController = ScrollController()..addListener(scrollListener);
  int page = 0;
  final scrollLoading = ValueNotifier(false);
  bool isLastPage = false;

  void debounce(VoidCallback fn) {
    sendResults(_results);

    timer?.cancel();
    timer = Timer(widget.debounce, fn);
    loading.value = true;
  }

  Future<void> scrollListener() async {
    final (pagedSearch, position) =
        (widget.pagedSearch, scrollController.position);
    if (pagedSearch == null) return;

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

    widget.onResults?.call(results);
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
    scrollController.dispose();
    scrollLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      fieldViewBuilder: widget.fieldViewBuilder,
      displayStringForOption: (_) => _selectedText,
      optionsBuilder: (value) async {
        if (value.text.isEmpty || value.text == _selectedText) {
          sendResults([]);

          return [];
        }
        debounce(() => search(value.text));

        return _completer.future;
      },
      optionsViewBuilder: (context, onSelected, values) {
        void select(T value, String text) {
          this._selectedText = text;
          onSelected(value);

          FocusScope.of(context).unfocus();
        }

        final view = ListenableBuilder(
          listenable: scrollLoading,
          builder: (context, _) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final value in [...values, ..._pagedResults])
                    widget.builder(
                      context,
                      (text) => select(value, text),
                      value,
                    ),
                  if (scrollLoading.value)
                    widget.scrollLoadingBuilder?.call(context) ??
                        widget.loadingBuilder(context),
                ],
              ),
            );
          },
        );

        return widget.viewBuilder(context, view);
      },
    );
  }
}

extension on ScrollPosition {
  bool get isAtMax {
    return pixels >= maxScrollExtent;
  }
}
