import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';

import '../../formx.dart';

/// A set of extensions to sanitize maps.
extension MapSanitizerExtension on Map<String, dynamic> {
  /// Returns a new map with all keys in `camelCase`.
  Map<String, dynamic> get camelCase {
    return deepMap((key, value) => MapEntry(key.camelCase, value));
  }

  /// Returns a new map with all keys in `CONSTANT_CASE`.
  Map<String, dynamic> get constantCase {
    return deepMap((key, value) => MapEntry(key.constantCase, value));
  }

  /// Returns a new map with all keys in `Sentence case`.
  Map<String, dynamic> get sentenceCase {
    return deepMap((key, value) => MapEntry(key.sentenceCase, value));
  }

  /// Returns a new map with all keys in `snake_case`.
  Map<String, dynamic> get snakeCase {
    return deepMap((key, value) => MapEntry(key.snakeCase, value));
  }

  /// Returns a new map with all keys in `dot.case`.
  Map<String, dynamic> get dotCase {
    return deepMap((key, value) => MapEntry(key.dotCase, value));
  }

  /// Returns a new map with all keys in `param-case`.
  Map<String, dynamic> get paramCase {
    return deepMap((key, value) => MapEntry(key.paramCase, value));
  }

  /// Returns a new map with all keys in `path/case`.
  Map<String, dynamic> get pathCase {
    return deepMap((key, value) => MapEntry(key.pathCase, value));
  }

  /// Returns a new map with all keys in `PascalCase`.
  Map<String, dynamic> get pascalCase {
    return deepMap((key, value) => MapEntry(key.pascalCase, value));
  }

  /// Returns a new map with all keys in `Header-Case`.
  Map<String, dynamic> get headerCase {
    return deepMap((key, value) => MapEntry(key.headerCase, value));
  }

  /// Returns a new map with all keys in `Title Case`.
  Map<String, dynamic> get titleCase {
    return deepMap((key, value) => MapEntry(key.titleCase, value));
  }

  /// Returns a new <String, dynamic> map where all nested maps are also mapped.
  Map<String, dynamic> deepMap(
    MapEntry<String, dynamic> Function(String key, dynamic value) convert,
  ) {
    return map((key, value) {
      if (value is Map && value.keys.every((e) => e is String)) {
        return convert(key, value.cast<String, dynamic>().deepMap(convert));
      }
      if (value is List && value.every((e) => e is Map)) {
        return convert(
          key,
          value
              .cast<Map>()
              .map((e) => e.cast<String, dynamic>().deepMap(convert))
              .toList(),
        );
      }
      return convert(key, value);
    }).indented;
  }
}

/// A map extension that is indented when printed.
extension FormxIndentedExtension<K, V> on Map<K, V> {
  /// Converts this [Map] to a indented [String].
  String get indentedText {
    return JsonEncoder.withIndent('  ', (e) => e.toString()).convert(this);
  }

  /// Returns a view of this [Map] that is indented when printed.
  Map<K, V> get indented => IndentedMap(this);

  /// Pairs of the entries of this map.
  List<(K, V)> get pairs => [for (final e in entries) (e.key, e.value)];
}

/// Extension for casting lists.
extension FormxAdaptersExtension<T> on Iterable<T> {
  /// Returns a new [List] with values casted as `Map<String, dynamic>`.
  List<Map<String, dynamic>> castJson() => [
        for (final e in this) Map.castFrom(e as Map),
      ];

  /// Returns a new [List] with values casted as `Map<String, dynamic>`.
  List<R> mapJson<R>(R Function(Map<String, dynamic>) toElement) => [
        for (final e in this) toElement(Map.castFrom(e as Map)),
      ];

  /// Creates a sorted list of the elements of the iterable.
  ///
  /// The elements are ordered by the natural ordering if [ascending] is `true`.
  List<T> orderedBy<R extends Comparable<R>>(
    R Function(T) selector, {
    required bool ascending,
  }) {
    final order = ascending ? 1 : -1;
    return sortedByCompare(selector, (a, b) => a.compareTo(b) * order);
  }
}

/// A list extension that removes all null or empty values.
extension FormxListExtension<T> on List<T> {
  /// Removes all null or empty values from this [List] and nesteds.
  ///
  /// Empty iterables are allowed by default.
  void clean({
    bool nonNulls = true,
    bool nonEmptyMaps = true,
    bool nonEmptyStrings = true,
    bool nonEmptyIterables = false,
  }) {
    var index = 0;
    removeWhere((value) {
      if (value is Map) {
        this[index] = value.cleaned(
          nonNulls: nonNulls,
          nonEmptyMaps: nonEmptyMaps,
          nonEmptyStrings: nonEmptyStrings,
          nonEmptyIterables: nonEmptyIterables,
        ) as T;
      }
      if (value is List) {
        this[index] = value.cleaned(
          nonNulls: nonNulls,
          nonEmptyMaps: nonEmptyMaps,
          nonEmptyStrings: nonEmptyStrings,
          nonEmptyIterables: nonEmptyIterables,
        ) as T;
      }
      return switch (this[index++]) {
        null => nonNulls,
        Map e => e.isEmpty && nonEmptyMaps,
        String e => e.isEmpty && nonEmptyStrings,
        Iterable e => e.isEmpty && nonEmptyIterables,
        _ => false,
      };
    });
  }

  /// Returns a new [List] with all null or empty values removed.
  ///
  /// Empty iterables are allowed by default.
  List<T> cleaned({
    bool nonNulls = true,
    bool nonEmptyMaps = true,
    bool nonEmptyStrings = true,
    bool nonEmptyIterables = false,
  }) {
    final list = List.of(this)
      ..clean(
        nonNulls: nonNulls,
        nonEmptyMaps: nonEmptyMaps,
        nonEmptyStrings: nonEmptyStrings,
        nonEmptyIterables: nonEmptyIterables,
      );
    return list;
  }
}

///
extension FormxNullableMapExtension<K, V> on Map<K, V?> {
  /// Returns a new [Map] with all null values removed.
  Map<K, V> get nonNulls {
    return entries
        .where((e) => e.value != null)
        .map((e) => MapEntry(e.key, e.value as V))
        .toMap();
  }
}

///
extension FormxMapEntriesExtension<K, V> on Iterable<MapEntry<K, V>> {
  /// Returns a new [Map] from this [Iterable] of [MapEntry].
  Map<K, V> toMap() => Map.fromEntries(this);

  /// Returns all [MapEntry.key] from this [Iterable].
  Iterable get keys => map((e) => e.key);

  /// Returns all [MapEntry.value] from this [Iterable].
  Iterable get values => map((e) => e.value);
}

/// A map extension that removes all null or empty values.
extension FormxMapExtension<K, V> on Map<K, V> {
  /// Returns a new [Map] casted as `Map<String, dynamic>`.
  Map<String, dynamic> castJson() => Map.castFrom(this);

  /// Removes all null or empty values from this [Map] and nesteds.
  ///
  /// Empty iterables are allowed by default.
  void clean({
    bool nonNulls = true,
    bool nonEmptyMaps = true,
    bool nonEmptyStrings = true,
    bool nonEmptyIterables = false,
  }) {
    removeWhere((key, value) {
      if (value is Map) {
        this[key] = value.cleaned(
          nonNulls: nonNulls,
          nonEmptyMaps: nonEmptyMaps,
          nonEmptyStrings: nonEmptyStrings,
          nonEmptyIterables: nonEmptyIterables,
        ) as V;
      }
      if (value is List) {
        this[key] = value.cleaned(
          nonNulls: nonNulls,
          nonEmptyMaps: nonEmptyMaps,
          nonEmptyStrings: nonEmptyStrings,
          nonEmptyIterables: nonEmptyIterables,
        ) as V;
      }
      return switch (this[key]) {
        null => nonNulls,
        Map e => e.isEmpty && nonEmptyMaps,
        String e => e.isEmpty && nonEmptyStrings,
        Iterable e => e.isEmpty && nonEmptyIterables,
        _ => false,
      };
    });
  }

  /// Returns a new [Map] with all null or empty values removed.
  Map<K, V> cleaned({
    bool nonNulls = true,
    bool nonEmptyMaps = true,
    bool nonEmptyStrings = true,
    bool nonEmptyIterables = false,
  }) {
    final map = IndentedMap.of(this)
      ..clean(
        nonNulls: nonNulls,
        nonEmptyMaps: nonEmptyMaps,
        nonEmptyStrings: nonEmptyStrings,
        nonEmptyIterables: nonEmptyIterables,
      );
    return map;
  }

  /// Returns a new [List] with only the values that satisfy [test].
  List<V> valuesWhere(bool Function(K key, V value) test) {
    return [
      for (final e in entries)
        if (test(e.key, e.value)) e.value,
    ];
  }

  /// Returns a new [List] with only the keys that satisfy [test].
  List<K> keysWhere(bool Function(K key, V value) test) {
    return [
      for (final e in entries)
        if (test(e.key, e.value)) e.key,
    ];
  }
}

///
extension HexadecimalExtension on String {
  /// Returns `true` if this [String] contains only hexadecimal characters.
  bool get isHexadecimal => RegExp(r'^[0-9a-fA-F]+$').hasMatch(this);

  /// Returns `true` if this [String] is a valid hexadecimal color.
  bool get isHexColor =>
      RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(this);
}

/// A set of extensions to sanitize objects.
extension ObjectExtension on Object {
  /// Returns this as [R].
  R cast<R>() => this as R;

  /// Returns this as [R] if it is [R], otherwise null.
  R? tryCast<R>() => this is R ? this as R : null;
}

///
extension JsonValidatorExtension on String {
  /// Returns `true` if this [String] is a valid JSON.
  bool get isJson {
    try {
      json.decode(this);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// A set of extensions to sanitize objects.
extension ObjectExtensionT<T extends Object> on T {
  /// Returns itself and applies [transform] to it.
  R let<R>(R transform(T it)) => transform(this);
}

/// An indented view of a [Map].
class IndentedMap<K, V> extends MapBase<K, V> {
  /// Creates a [IndentedMap] with this [Map].
  const IndentedMap(this._map);

  /// Creates a new [IndentedMap] of a [Map].
  factory IndentedMap.of(Map<K, V> map) => IndentedMap(Map.of(map));
  final Map<K, V> _map;

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);

  @override
  String toString() {
    return JsonEncoder.withIndent('  ', (e) => e.toString()).convert(_map);
  }
}

///
extension IterableSortedByWithAscending<E> on Iterable<E> {
  /// Returns a new list with all elements sorted according to natural sort
  /// order of the values returned by specified [selector] function.
  ///
  /// The [ascending] parameter controls the order of sorting:
  /// - Defaults to `true`, sorting elements in ascending order.
  /// - Set to `false` to sort elements in descending order.
  ///
  /// To sort by more than one property, `thenBy()` or `thenByDescending()` can
  /// be called afterwards.
  ///
  /// **Note:** The actual sorting is performed when an element is accessed for
  /// the first time.
  // SortedList<E> sortedBy(
  //   Comparable Function(E element) selector, {
  //   bool ascending = true,
  // }) {
  //   return SortedList<E>.withSelector(
  //     this,
  //     selector,
  //     ascending ? 1 : -1,
  //     null,
  //   );
  // }
}
