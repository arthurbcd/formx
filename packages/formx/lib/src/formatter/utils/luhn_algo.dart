// ignore_for_file: type=lint, argument_type_not_assignable, return_of_invalid_type_from_closure, invalid_assignment
/// Implementation of th Luhn algorithm
/// https://en.wikipedia.org/wiki/Luhn_algorithm
bool checkNumberByLuhn({
  required String number,
}) {
  final cardNumbers = number.split('');
  int numDigits = cardNumbers.length;

  int sum = 0;
  bool isSecond = false;
  for (int i = numDigits - 1; i >= 0; i--) {
    int d = int.parse(cardNumbers[i]);

    if (isSecond == true) {
      d = d * 2;
    }

    sum += d ~/ 10;
    sum += d % 10;

    isSecond = !isSecond;
  }
  return (sum % 10 == 0);
}
