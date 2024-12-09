import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

import '../extensions/string_extension.dart';
import 'country_code_extension.dart';
import 'fiat_code_extension.dart';
import 'formatter.dart';
import 'formatters/credit_card_cvc_input_formatter.dart';
import 'formatters/credit_card_expiration_input_formatter.dart';
import 'formatters/credit_card_number_input_formatter.dart';
import 'formatters/currency_input_formatter.dart';
import 'formatters/masked_input_formatter.dart';
import 'formatters/money_input_enums.dart';
import 'formatters/phone_input_formatter.dart';
import 'formatters/pinyin_formatter.dart';
import 'formatters/pos_input_formatter.dart';

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

        for (final mask in masks.sortedBy<num>((e) => e.length)) {
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
  /// Supply a [countryCode] or let the formatter detect it.
  /// Calls [onSelected] with the detected country code.
  ///
  /// Use [CountryCodeExtension] to apply a [countryCode].
  /// Ex: `Formatter().phone.br()`.
  ///
  Formatter phone({
    String? countryCode, // US, BR, etc
    bool endless = false,
    bool autocorrect = true,
    void Function(String? countryCode)? onSelected,
  }) =>
      addFormatter(
        PhoneInputFormatter(
          defaultCountryCode: countryCode,
          allowEndlessPhone: endless,
          shouldCorrectNumber: autocorrect,
          onCountrySelected: onSelected != null
              ? (data) => onSelected(data?.countryCode)
              : null,
        ),
      );

  /// Formats the value as a credit card number.
  ///
  /// It automatically detects the credit card system.
  /// Calls [onSelected] with the detected system.
  ///
  /// Detectable Systems: Visa, Mastercard, Maestro, Amex, MIR, UnionPay,
  /// JCB, Discover, DinersClub, UzCard, HUMO.
  ///
  Formatter creditCard({
    bool useSeparators = true,
    void Function(String? system)? onSelected,
  }) =>
      addFormatter(
        CreditCardNumberInputFormatter(
          useSeparators: useSeparators,
          onCardSystemSelected:
              onSelected != null ? (data) => onSelected(data?.system) : null,
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
  ///
  /// If [code] and [separator] are not provided, the formatter will use
  /// [Separator.commaAndDot] by default.
  ///
  Formatter currency({
    String? code, // USD, BRL, etc
    String? leading,
    String? trailing,
    int? mantissa, // decimal places
    int? maxLength,
    bool? usePadding,
    Separator? separator,
    ValueChanged<num>? onChanged,
  }) {
    V? get<V>(String key) {
      if (currencyConfigs[code]?[key] case V it) return it;
      return null;
    }

    return addFormatter(
      CurrencyInputFormatter(
        thousandSeparator: separator?.thousandSeparator ?? get('separator'),
        mantissaLength: mantissa ?? get('mantissa') ?? 2,
        leadingSymbol: leading ?? get('leading') ?? '',
        trailingSymbol: trailing ?? get('trailing') ?? '',
        useSymbolPadding: usePadding ?? get('padding') ?? false,
        maxTextLength: maxLength,
        onValueChange: onChanged,
      ),
    );
  }

  /// Formats as you would in a point of sale. Ex: 1.000,00.
  Formatter pos({
    Separator separator = Separator.dotAndComma,
    int mantissa = 2, // decimal places
  }) =>
      addFormatter(
        PosInputFormatter(
          decimalSeparator: separator.decimalSeparator,
          thousandsSeparator: separator.thousandsSeparator,
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

/// The separators for [FormatterExtension.currency].
enum Separator {
  /// 1,000,000.00
  commaAndDot(',', '.'),

  /// 1 000 000 00
  space(' '),

  /// 1.000.000,00
  dotAndComma('.', ','),

  /// 100000000. Incompatible w/ [FormatterExtension.pos] -> [dotAndComma].
  none(null),

  /// 1 000 000.00
  spaceAndDot(' ', '.'),

  /// 1 000 000,00
  spaceAndComma(' ', ','),

  /// 1'000.00. Incompatible w/ [FormatterExtension.currency] -> [commaAndDot].
  quoteAndDot("'", '.'),

  /// 1'000,00. Incompatible w/ [FormatterExtension.currency] -> [dotAndComma].
  quoteAndComma("'", ',');

  const Separator(this.thousand, [this.decimal]);

  /// The thousand separator.
  final String? thousand;

  /// The decimal separator.
  final String? decimal;
}

extension on Separator {
  DecimalPosSeparator get decimalSeparator {
    return DecimalPosSeparator.parse(decimal ?? '.');
  }

  ThousandsPosSeparator? get thousandsSeparator {
    return thousand != null ? ThousandsPosSeparator.parse(thousand!) : null;
  }

  ThousandSeparator get thousandSeparator {
    var separator = this;
    if (this == Separator.quoteAndComma) separator = Separator.dotAndComma;
    if (this == Separator.quoteAndDot) separator = Separator.commaAndDot;
    return ThousandSeparator.values[separator.index];
  }
}
