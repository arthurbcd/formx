// ignore_for_file: type=lint, argument_type_not_assignable, return_of_invalid_type_from_closure, invalid_assignment

String? enumToString(dynamic enumValue) {
  if (enumValue == null) return null;
  return enumValue.toString().split('.')[1];
}

T? enumFromString<T>(List<T> enumValues, String? value) {
  if (value == null) return null;

  return enumValues.singleWhereOrNull(
    (enumItem) => enumToString(enumItem) == value,
  );
}

extension<T> on Iterable<T> {
  T? singleWhereOrNull(bool Function(T element) test) {
    T? result;
    var found = false;
    for (var element in this) {
      if (test(element)) {
        if (!found) {
          result = element;
          found = true;
        } else {
          return null;
        }
      }
    }
    return result;
  }
}
