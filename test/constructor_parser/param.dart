// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/foundation.dart';

@immutable
abstract class Param {
  const Param({
    required this.type,
    this.isRequired = true,
  });

  /// Ignores nullability of the type
  final String type;
  final bool isRequired;

  bool get isNullable => type.endsWith('?');

  String get typeName {
    if (isNullable) return type.substring(0, type.length - 1);
    return type;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Param &&
        other.isRequired == isRequired &&
        other.type == type;
  }

  @override
  int get hashCode {
    return isRequired.hashCode ^ type.hashCode;
  }

  @override
  String toString() {
    return 'Param(type: $type, isNullable: $isNullable, isRequired: $isRequired)';
  }
}

@immutable
class NamedParam extends Param {
  const NamedParam({
    required super.type,
    required this.named,
    super.isRequired = false,
  });
  final Symbol named;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NamedParam && other.named == named && super == other;
  }

  @override
  int get hashCode => named.hashCode ^ super.hashCode;
}

@immutable
class PositionalParam extends Param {
  const PositionalParam({
    required super.type,
    required super.isRequired,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PositionalParam && super == other;
  }

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
