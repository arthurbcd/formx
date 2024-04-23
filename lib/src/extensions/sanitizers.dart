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
      return convert(key, value);
    });
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

  /// Removes all null or empty values from this [Map] and nesteds.
  void clean() {
    // ignore: avoid_types_on_closure_parameters
    removeWhere((key, Object? value) {
      if (value is Map) value.clean();

      return value == null || value.isEmpty;
    });
  }
}

extension on Object {
  bool get isEmpty {
    if (this case Iterable e) return e.isEmpty;
    if (this case String e) return e.isEmpty;
    if (this case Map e) return e.isEmpty;
    return false;
  }
}

/// Extension to enable Object inference casting by type.
extension FormxCastExtension on Object? {
  /// Returns this as [T].
  T cast<T>() => this as T;

  /// Returns this as [T] if it is [T], otherwise null.
  T? tryCast<T>() => this is T ? this as T : null;
}

/// An indented view of a [Map].
class IndentedMap<K, V> extends MapBase<K, V> {
  /// Creates a new [IndentedMap] from a [Map].
  const IndentedMap(this._map);
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
