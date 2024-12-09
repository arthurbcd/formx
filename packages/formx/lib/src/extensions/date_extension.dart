/// Extension on [DateTime] to add more functionality.
extension FormxDateExtension on DateTime {
  /// Whether this date has passed the given [duration] in time.
  bool hasPassed(Duration duration) {
    return isBefore(DateTime.now().subtract(duration));
  }
}
