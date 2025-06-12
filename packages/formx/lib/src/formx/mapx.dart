import 'dart:collection';

class Mapx extends MapBase<String, dynamic> {
  Mapx([Map<String, dynamic>? map]) : _map = map ?? <String, dynamic>{};

  final Map<String, dynamic> _map;

  @override
  dynamic operator [](Object? key) {
    // Handle simple case
    if (key is! String || !key.contains('.')) {
      return _map[key];
    }

    // Handle dot notation for nested access
    final parts = key.split('.');
    dynamic current = _map;

    for (var i = 0; i < parts.length; i++) {
      if (current is! Map) return null;

      final part = parts[i];
      if (i == parts.length - 1) {
        return current[part];
      }

      current = current[part];
      if (current == null) return null;
    }

    return null;
  }

  @override
  void operator []=(String key, dynamic value) {
    // Handle simple case
    if (!key.contains('.')) {
      _map[key] = value;
      return;
    }

    // Handle dot notation for nested setting
    final parts = key.split('.');
    dynamic current = _map;

    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];

      // Create intermediate maps as needed
      if (current[part] == null) {
        current[part] = <String, dynamic>{};
      } else if (current[part] is! Map) {
        current[part] = <String, dynamic>{};
      }

      current = current[part];
    }

    current[parts.last] = value;
  }

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  dynamic remove(Object? key) => _map.remove(key);
}
