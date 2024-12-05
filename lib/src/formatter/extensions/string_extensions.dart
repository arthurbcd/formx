// ignore_for_file: type=lint, argument_type_not_assignable, return_of_invalid_type_from_closure, invalid_assignment

import '../formatters/credit_card_number_input_formatter.dart';
import '../formatters/phone_input_enums.dart';
import '../formatters/phone_input_formatter.dart';

extension StringExtension on String {
  String removeCharAt(int charIndex) {
    final charList = split('').toList();
    charList.removeAt(charIndex);
    return charList.join('');
  }

  String toPhoneNumber({
    InvalidPhoneAction invalidPhoneAction = InvalidPhoneAction.ShowUnformatted,
    bool allowEndlessPhone = false,
    String? defaultMask,
    String? defaultCountryCode,
  }) {
    return formatAsPhoneNumber(
          this,
          allowEndlessPhone: allowEndlessPhone,
          defaultCountryCode: defaultCountryCode,
          defaultMask: defaultMask,
          invalidPhoneAction: invalidPhoneAction,
        ) ??
        this;
  }

  String toCardNumber() {
    return formatAsCardNumber(this);
  }

  bool isValidCardNumber({
    bool checkLength = false,
    bool useLuhnAlgo = true,
  }) {
    return isCardNumberValid(
      cardNumber: this,
      useLuhnAlgo: useLuhnAlgo,
      checkLength: checkLength,
    );
  }
}
