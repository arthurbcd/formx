/// [Comparable] extension methods.
extension FormxComparableExtension<T extends Comparable<T>> on T {
  /// Whether this value is less than [other].
  bool operator <(T other) => compareTo(other) < 0;

  /// Whether this value is less than or equal to [other].
  bool operator <=(T other) => compareTo(other) <= 0;

  /// Whether this value is greater than [other].
  bool operator >(T other) => compareTo(other) > 0;

  /// Whether this value is greater than or equal to [other].
  bool operator >=(T other) => compareTo(other) >= 0;

  /// Returns true when between [a] and [b]. You can set [inclusive] to false
  /// to exclude [a] and [b].
  ///
  /// Works with any [Comparable] type. E.g. `DateTime`, `int`, `String`, etc.
  ///
  /// Example:
  /// - `3.isBetween(1, 5)` -> `true`.
  /// - `3.isBetween(1, 3)` -> `true`.
  /// - `3.isBetween(1, 3, inclusive: false)` -> `false`.
  bool isBetween(T a, T b, {bool inclusive = true}) {
    return switch ((a <= b, inclusive)) {
      (true, true) => a <= this && this <= b,
      (false, true) => b <= this && this <= a,
      (true, false) => a < this && this < b,
      (false, false) => b < this && this < a,
    };
  }

  /// Returns true if within range [a] (inclusive) to [b] (exclusive).
  ///
  /// Works with any [Comparable] type. E.g. `DateTime`, `int`, `String`, etc.
  ///
  /// Example:
  /// - `3.inRange(1, 5)` -> `true`.
  /// - `3.inRange(1, 3)` -> `false`.
  bool inRange(T a, T b) {
    return switch (a <= b) {
      true => a <= this && this < b,
      false => b <= this && this < a,
    };
  }

  /// Whether this value is before [other].
  bool isBefore(T other) => this < other;

  /// Whether this value is after [other].
  bool isAfter(T other) => this > other;

  /// Returns this [Comparable] clamped to be between [lowerLimit]-[upperLimit].
  /// The range must be valid: [lowerLimit] <= [upperLimit].
  T clamp(T lowerLimit, T upperLimit) {
    if (lowerLimit > upperLimit) {
      throw ArgumentError.value(
        lowerLimit,
        'lowerLimit',
        '$lowerLimit is not less than or equal to upperLimit $upperLimit.',
      );
    }
    if (this < lowerLimit) return lowerLimit;
    if (this > upperLimit) return upperLimit;
    return this;
  }
}
