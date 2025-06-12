// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../formx.dart';
import 'mapx.dart';

class Formx {
  Formx({
    this.initialValues = const {},
    FormxOptions? options,
  }) {
    _options = options ?? Formx.options;
    _flatInitials.forEach(setValue);
  }

  /// Global setup for all [Formx] widgets.
  static FormxSetup setup = const FormxSetup();

  /// Global options for all [FormxState] methods.
  static FormxOptions options = const FormxOptions();

  /// The default equality to use in [equals].
  /// Defaults to one-depth collections equality.
  static bool Function(dynamic a, dynamic b) defaultEquals =
      (a, b) => switch ((a, b)) {
            (List a, List b) => listEquals(a, b),
            (Set a, Set b) => setEquals(a, b),
            (Map a, Map b) => mapEquals(a, b),
            _ => a == b,
          };

  /// The equality used for isInitial.
  static bool equals(Object? a, Object? b) => defaultEquals(a, b);

  final Map<String, dynamic> initialValues;
  late final _flatInitials = _flatten(initialValues);
  late final FormxOptions _options;

  // states
  final _keys = <String, FieldKey>{};
  final _fields = <String, FormFieldState>{};

  // queues
  final _toValidate = <String>{};
  final _toChange = <String, dynamic>{};

  /// Sets the value of a form field by flat key path.
  ///
  /// This method only supports flat key operations using dot notation,
  /// e.g: "user.name".
  ///
  /// For setting complete structured/nested data, use the `values` setter instead:
  /// ```dart
  /// form.values = {"user": {"name": "John", "email": "john@example.com"}};
  /// ```
  void setValue(String key, dynamic value) {
    _toChange.remove(key);

    void setField(FormFieldState field) {
      final formattedValue = field.maybeFormat(value);

      if (field.mounted) {
        field.didChange(formattedValue);
      } else {
        field.setValue(formattedValue);
      }
    }

    return switch (_fields[key]) {
      var field? => setField(field),
      _ => _toChange[key] = value,
    };
  }

  Map<String, dynamic> get rawValues {
    final mapx = Mapx();
    for (final (key, field) in _fields.pairs) {
      mapx[key] = field.value;
    }
    for (final (key, value) in _toChange.pairs) {
      mapx[key] = value;
    }
    return mapx;
  }

  Map<String, dynamic> get values {
    final mapx = Mapx();
    for (final (key, field) in _fields.pairs) {
      mapx[key] = field.toValue(options: _options);
    }
    for (final (key, value) in _toChange.pairs) {
      mapx[key] = value;
    }
    return mapx.cleaned(
      nonNulls: _options.nonNulls,
      nonEmptyMaps: _options.nonEmptyMaps,
      nonEmptyStrings: _options.nonEmptyStrings,
      nonEmptyIterables: _options.nonEmptyIterables,
    );
  }

  set values(Map<String, dynamic> map) {
    _flatten(map).forEach(setValue);
  }

  Map<String, String> get errorTexts {
    final map = <String, String>{};
    for (final (key, field) in _fields.pairs) {
      if (field.hasError) {
        map[key] = field.errorText!;
      }
    }
    return map;
  }

  Map<String, dynamic> _flatten(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, dynamic>{};

    for (final e in map.entries) {
      final key = prefix.isEmpty ? e.key : '$prefix.${e.key}';

      if (e.value case Map<String, dynamic> map) {
        result.addAll(_flatten(map, key));
      } else {
        result[key] = e.value;
      }
    }

    return result;
  }

  /// Check if every field is in its initial state.
  bool get isInitial {
    for (final (key, field) in _fields.pairs) {
      if (_flatInitials.containsKey(key)) {
        if (!Formx.equals(field.value, _flatInitials[key])) {
          return false;
        }
      } else if (!field.isInitial) {
        return false;
      }
    }

    return true;
  }

  /// Check if any field has been interacted by the user.
  bool get hasInteractedByUser {
    for (final (key, field) in _fields.pairs) {
      if (_flatInitials.containsKey(key)) {
        if (!Formx.equals(field.value, _flatInitials[key])) {
          return true;
        }
      } else if (field.hasInteractedByUser) {
        return true;
      }
    }

    return false;
  }

  /// Registers a [FieldKey] for the given [key].
  Key key(
    String key, {
    bool? keepMask,
    String? Function(String, TextInputFormatter)? unmasker,
    dynamic Function(dynamic)? adapter,
  }) {
    final fieldKey = _keys[key] ??= FieldKey(
      key,
      keepMask: keepMask,
      unmasker: unmasker,
      adapter: adapter,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final oldField = _fields[key];
      final field = fieldKey.currentState;

      if (field == null) {
        throw Exception('FieldKey $key is not attached to a FormField.');
      }

      // field is already mounted, nothing to do.
      if (oldField == field) return;
      _fields[key] = field;

      if (oldField == null) {
        if (_toChange.containsKey(key)) {
          setValue(key, _toChange.remove(key));
        }
      } else {
        // if both are not null, we need to sync them.
        field.didChange(oldField.value);
      }

      if (_toValidate.remove(key)) {
        if (!field.validate()) _toValidate.add(key);
      }
    });

    return fieldKey;
  }

  bool validate() {
    final invalids = <String>{};

    _flatInitials.keys.forEach(_toValidate.add);

    for (final (key, field) in _fields.pairs) {
      if (field.mounted) {
        _toValidate.remove(key);
        field.validate();
      } else {
        _toValidate.add(key);
      }
      if (!field.isValid) invalids.add(key);
    }

    return invalids.isEmpty;
  }

  void clear() {
    _toValidate.clear();
    _toChange.clear();

    for (final field in _fields.values) {
      field.clear();
    }
  }

  void reset() {
    _toValidate.clear();

    for (final (key, field) in _fields.pairs) {
      final hasInitial = _flatInitials.containsKey(key);
      final value = hasInitial ? _flatInitials[key] : field.widget.initialValue;

      if (field.mounted) {
        field.reset();
        if (hasInitial) field.didChange(value);
      } else {
        setValue(key, value);
      }
    }
    for (final key in _toChange.keys.where(_flatInitials.containsKey)) {
      setValue(key, _flatInitials[key]);
    }
  }

  Map<String, dynamic>? trySubmit({
    FormxOptions? options,
    String? errorMessage,
  }) {
    if (!validate()) {
      return null;
    }

    try {
      return submit(options: options, errorMessage: errorMessage);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> submit({
    FormxOptions? options,
    String? errorMessage,
  }) {
    if (!validate()) {
      throw FormxException(errorTexts, errorMessage);
    }
    if (options == null) {
      return values;
    }

    return values.cleaned(
      nonNulls: options.nonNulls,
      nonEmptyMaps: options.nonEmptyMaps,
      nonEmptyStrings: options.nonEmptyStrings,
      nonEmptyIterables: options.nonEmptyIterables,
    );
  }
}
