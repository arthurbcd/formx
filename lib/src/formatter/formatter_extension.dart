import 'dart:math' as math;

import 'package:dartx/dartx.dart' hide IterableSortedBy;
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_cvc_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_expiration_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/pinyin_formatter.dart';
import 'package:flutter_multi_formatter/formatters/pos_input_formatter.dart';

import '../extensions/sanitizers.dart';
import '../extensions/string_extension.dart';
import 'country_code_extension.dart';
import 'fiat_code_extension.dart';
import 'formatter.dart';

/// The [Formatter] extension modifiers.
extension FormatterExtension on Formatter {
  /// Limits the text length to [length].
  Formatter maxLength(int length) =>
      addFormatter(LengthLimitingTextInputFormatter(length));

  /// Allows the [pattern].
  Formatter allow(Pattern pattern) =>
      addFormatter(FilteringTextInputFormatter.allow(pattern));

  /// Denies the [pattern].
  Formatter deny(Pattern pattern) =>
      addFormatter(FilteringTextInputFormatter.deny(pattern));

  /// Allows only letters/ponctuations.
  Formatter alpha() => allow(RegExp(r'\p{L}|\p{P}', unicode: true));

  /// Allows only numbers.
  Formatter numeric() => allow(RegExp(r'\d'));

  /// Allows only letters/ponctuations and numbers.
  Formatter alphanumeric() => allow(RegExp(r'\p{L}|\p{P}|\d'));

  /// Denies the addition of new lines.
  Formatter singleLine() => deny('\n');

  /// Formats the [TextEditingValue] with [format].
  Formatter onFormat(TextInputFormatFunction format) =>
      addFormatter(TextInputFormatter.withFunction(format));

  /// Formats the [TextEditingValue.text] with [format].
  ///
  /// - [allowAccenting]. if `true`, the formatter will allow accenting
  /// characters before formatting with [format].
  Formatter onText(
    String format(String old, String text), {
    bool allowAccenting = false,
  }) =>
      onFormat((old, value) {
        if (allowAccenting && value.isAccenting) return value;

        final text = format(old.text, value.text);
        final selection = TextSelection.collapsed(
          offset: math.min(value.selection.extentOffset, text.length),
        );
        return TextEditingValue(text: text, selection: selection);
      });

  /// Formats the value to lower case.
  Formatter lowerCase() =>
      onText((_, text) => text.toLowerCase(), allowAccenting: true);

  /// Formats the value to upper case.
  Formatter upperCase() =>
      onText((_, text) => text.toUpperCase(), allowAccenting: true);

  /// Formats the value to capitalize the sentence.
  Formatter capitalize() =>
      onText((_, text) => text.capitalize(), allowAccenting: true);

  /// Formats the value to capitalize the words.
  Formatter capitalizeWords() =>
      onText((_, text) => text.capitalizeWords(), allowAccenting: true);

  /// Formats the value according to the provided [mask].
  Formatter mask(String mask, {RegExp? allow}) =>
      addFormatter(MaskedInputFormatter(mask, allowedCharMatcher: allow));

  /// Formats according to the provided chained [masks].
  ///
  /// The [masks] are length sorted and the first one that fits is used.
  Formatter masks(List<String> masks) => onFormat((old, value) {
        TextInputFormatter? formatter;

        for (final mask in masks.sortedBy((e) => e.length)) {
          formatter = MaskedInputFormatter(mask);
          if (value.text.length <= mask.length) break;
        }

        return formatter?.formatEditUpdate(old, value) ?? value;
      });

  /// Formats the value as a cpf.
  Formatter cpf() => mask('000.000.000-00');

  /// Formats the value as a cnpj.
  Formatter cnpj() => mask('00.000.000/0000-00');

  /// Formats the value as a cpf or cnpj.
  Formatter cpfCnpj() => masks(['000.000.000-00', '00.000.000/0000-00']);

  /// Formats the value as a phone number.
  ///
  /// Use [CountryCodeExtension] to apply a country [code].
  /// Ex: `Formatter().phone.br()`.
  Formatter phone({
    String? code, // US, BR, etc
    bool endless = false,
    bool autocorrect = true,
    void Function(PhoneCountryData? data)? onSelected,
  }) =>
      addFormatter(
        PhoneInputFormatter(
          defaultCountryCode: code,
          allowEndlessPhone: endless,
          shouldCorrectNumber: autocorrect,
          onCountrySelected: onSelected,
        ),
      );

  /// Formats the value as a credit card number.
  Formatter creditCard({
    bool useSeparators = true,
    void Function(CardSystemData? data)? onSelected,
  }) =>
      addFormatter(
        CreditCardNumberInputFormatter(
          useSeparators: useSeparators,
          onCardSystemSelected: onSelected,
        ),
      );

  /// Formats the value as a credit card cvc.
  Formatter cvc({
    bool isAmericanExpress = false,
  }) =>
      addFormatter(
        CreditCardCvcInputFormatter(isAmericanExpress: isAmericanExpress),
      );

  /// Formats the value as a credit card expiration date.
  Formatter expirationDate() =>
      addFormatter(CreditCardExpirationDateFormatter());

  /// Formats the value in a currency format.
  Formatter currency({
    String? code,
    String? leading,
    String? trailing,
    int? mantissa,
    int? maxLength,
    bool? usePadding,
    ThousandSeparator? separator,
    ValueChanged<num>? onChanged,
  }) {
    V? get<V>(String key) {
      if (currencyConfigs[code]?[key] case V it) return it;
      return null;
    }

    return addFormatter(
      CurrencyInputFormatter(
        thousandSeparator:
            separator ?? get('separator') ?? ThousandSeparator.Comma,
        mantissaLength: mantissa ?? get('mantissa') ?? 2,
        leadingSymbol: leading ?? get('leading') ?? '',
        trailingSymbol: trailing ?? get('trailing') ?? '',
        useSymbolPadding: usePadding ?? get('padding') ?? false,
        maxTextLength: maxLength,
        onValueChange: onChanged,
      ),
    );
  }

  /// Formats as you would in a point of sale. Ex: 1.000,00
  Formatter pos({
    DecimalPosSeparator decimalSeparator = DecimalPosSeparator.dot,
    ThousandsPosSeparator? thousandsSeparator,
    int mantissa = 2,
  }) =>
      addFormatter(
        PosInputFormatter(
          decimalSeparator: decimalSeparator,
          thousandsSeparator: thousandsSeparator,
          mantissaLength: mantissa,
        ),
      );

  /// Formats chinese pinyin characters to have a space between them.
  Formatter pinyin({String? replacementForSpace}) =>
      addFormatter(PinyinFormatter(replacementForSpace: replacementForSpace));
}

/// TextEditingValue extension utilities.
extension FormxTextEditingValueExtension on TextEditingValue {
  /// Returns the text that was just added to the [TextEditingValue].
  String? get addedText {
    if (!composing.isValid) return null;
    return text.substring(composing.start, composing.end);
  }

  /// Returns `true` if the user just added a ponctuation,
  /// usually used to accent the next character.
  bool get isAccenting {
    if (addedText case var it? when it.length == 1) {
      return RegExp(r'\p{P}', unicode: true).hasMatch(it);
    }
    return false;
  }
}
