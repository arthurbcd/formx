// ignore_for_file: type=lint, argument_type_not_assignable, return_of_invalid_type_from_closure, invalid_assignment
extension IntExtension on int {
  int subtractClamping(
    int subtract, {
    int minValue = 0,
    int maxValue = 999999999,
  }) {
    return (this - subtract).clamp(
      minValue,
      maxValue,
    );
  }
}
