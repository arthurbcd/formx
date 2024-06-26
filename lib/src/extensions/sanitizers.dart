import 'dart:collection';
import 'dart:convert';

import 'package:recase/recase.dart';

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
}

/// Extension for casting lists.
extension FormxCastListExtension<T> on List<T> {
  /// Returns a new [List] with values casted as `Map<String, dynamic>`.
  List<Map<String, dynamic>> castJson() => [
        for (final item in this) Map.castFrom(item as Map),
      ];

  /// Returns a new [List] with values casted as `Map<String, dynamic>`.
  List<R> mapJson<R>(R Function(Map<String, dynamic>) toElement) {
    return [
      for (final item in this) toElement(Map.castFrom(item as Map)),
    ];
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
}

// TODO(liz): add tests for String.alpha, String.alphaNumeric, String.numeric
/// A set of extensions to sanitize strings.
extension StringSanitizerExtension on String {
  /// Returns the alpha characters of this [String].
  String get alpha => replaceAll(RegExp('[^a-zA-Z]'), '');

  /// Returns the numeric characters of this [String].
  String get numeric => replaceAll(RegExp('[^0-9]'), '');

  /// Returns the alphanumeric characters of this [String].
  String get alphanumeric => replaceAll(RegExp('[^a-zA-Z0-9]'), '');

  /// Extracts only the alpha characters from a string.
  @Deprecated('Use alpha instead.')
  String get onlyAlpha => replaceAll(RegExp('[^0-9]'), '');

  /// Extracts only the numeric characters from a string.
  @Deprecated('Use numeric instead.')
  String get onlyNumeric => replaceAll(RegExp('[^a-zA-Z]'), '');

  /// Extracts only the alphanumeric characters from a string.
  @Deprecated('Use alphanumeric instead.')
  String get onlyAlphanumeric => replaceAll(RegExp('[^a-zA-Z0-9]'), '');
}

/// Extension to enable Object inference casting by type.
extension FormxCastExtension on Object {
  /// Returns this as [T].
  T cast<T>() => this as T;

  /// Returns this as [T] if it is [T], otherwise null.
  T? tryCast<T>() => this is T ? this as T : null;
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
