// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';

import '../../formx.dart';
import 'formatters/money_input_enums.dart';

/// Shortcut to select a fiat code.
extension FiatCodeExtension<T> on T Function({
  String? code,
  String? leading,
  String? trailing,
  int? mantissa,
  int? maxLength,
  bool? usePadding,
  Separator? separator,
  void Function(num)? onChanged,
}) {
  T _this(String? code, void Function(num)? onChanged) {
    return this(code: code, onChanged: onChanged);
  }

  T cny({ValueChanged<num>? onChanged}) => _this('CNY', onChanged);
  T usd({ValueChanged<num>? onChanged}) => _this('USD', onChanged);
  T eur({ValueChanged<num>? onChanged}) => _this('EUR', onChanged);
  T jpy({ValueChanged<num>? onChanged}) => _this('JPY', onChanged);
  T gbp({ValueChanged<num>? onChanged}) => _this('GBP', onChanged);
  T krw({ValueChanged<num>? onChanged}) => _this('KRW', onChanged);
  T inr({ValueChanged<num>? onChanged}) => _this('INR', onChanged);
  T cad({ValueChanged<num>? onChanged}) => _this('CAD', onChanged);
  T hkd({ValueChanged<num>? onChanged}) => _this('HKD', onChanged);
  T brl({ValueChanged<num>? onChanged}) => _this('BRL', onChanged);
  T aud({ValueChanged<num>? onChanged}) => _this('AUD', onChanged);
  T twd({ValueChanged<num>? onChanged}) => _this('TWD', onChanged);
  T rub({ValueChanged<num>? onChanged}) => _this('RUB', onChanged);
  T chf({ValueChanged<num>? onChanged}) => _this('CHF', onChanged);
  T mxn({ValueChanged<num>? onChanged}) => _this('MXN', onChanged);
  T sar({ValueChanged<num>? onChanged}) => _this('SAR', onChanged);
  T thb({ValueChanged<num>? onChanged}) => _this('THB', onChanged);
  T aed({ValueChanged<num>? onChanged}) => _this('AED', onChanged);
  T sgd({ValueChanged<num>? onChanged}) => _this('SGD', onChanged);
  T vnd({ValueChanged<num>? onChanged}) => _this('VND', onChanged);
  T idr({ValueChanged<num>? onChanged}) => _this('IDR', onChanged);
  T ils({ValueChanged<num>? onChanged}) => _this('ILS', onChanged);
  T myr({ValueChanged<num>? onChanged}) => _this('MYR', onChanged);
  T sek({ValueChanged<num>? onChanged}) => _this('SEK', onChanged);
  T pln({ValueChanged<num>? onChanged}) => _this('PLN', onChanged);
  T trY({ValueChanged<num>? onChanged}) => _this('TRY', onChanged);
  T clp({ValueChanged<num>? onChanged}) => _this('CLP', onChanged);
  T nok({ValueChanged<num>? onChanged}) => _this('NOK', onChanged);
  T php({ValueChanged<num>? onChanged}) => _this('PHP', onChanged);
  T zar({ValueChanged<num>? onChanged}) => _this('ZAR', onChanged);
  T egp({ValueChanged<num>? onChanged}) => _this('EGP', onChanged);
  T dkk({ValueChanged<num>? onChanged}) => _this('DKK', onChanged);
  T czk({ValueChanged<num>? onChanged}) => _this('CZK', onChanged);
  T nzd({ValueChanged<num>? onChanged}) => _this('NZD', onChanged);
  T qar({ValueChanged<num>? onChanged}) => _this('QAR', onChanged);
  T cop({ValueChanged<num>? onChanged}) => _this('COP', onChanged);
  T mad({ValueChanged<num>? onChanged}) => _this('MAD', onChanged);
  T pkr({ValueChanged<num>? onChanged}) => _this('PKR', onChanged);
  T lbp({ValueChanged<num>? onChanged}) => _this('LBP', onChanged);
  T kwd({ValueChanged<num>? onChanged}) => _this('KWD', onChanged);
  T ron({ValueChanged<num>? onChanged}) => _this('RON', onChanged);
  T ngn({ValueChanged<num>? onChanged}) => _this('NGN', onChanged);
  T ars({ValueChanged<num>? onChanged}) => _this('ARS', onChanged);
  T iqd({ValueChanged<num>? onChanged}) => _this('IQD', onChanged);
  T huf({ValueChanged<num>? onChanged}) => _this('HUF', onChanged);
  T mop({ValueChanged<num>? onChanged}) => _this('MOP', onChanged);
  T pen({ValueChanged<num>? onChanged}) => _this('PEN', onChanged);
  T bgn({ValueChanged<num>? onChanged}) => _this('BGN', onChanged);
  T kzt({ValueChanged<num>? onChanged}) => _this('KZT', onChanged);
  T uah({ValueChanged<num>? onChanged}) => _this('UAH', onChanged);
  T jod({ValueChanged<num>? onChanged}) => _this('JOD', onChanged);
  T omr({ValueChanged<num>? onChanged}) => _this('OMR', onChanged);
  T gtq({ValueChanged<num>? onChanged}) => _this('GTQ', onChanged);
  T bhd({ValueChanged<num>? onChanged}) => _this('BHD', onChanged);
  T dop({ValueChanged<num>? onChanged}) => _this('DOP', onChanged);
  T xof({ValueChanged<num>? onChanged}) => _this('XOF', onChanged);
  T kes({ValueChanged<num>? onChanged}) => _this('KES', onChanged);
  T bob({ValueChanged<num>? onChanged}) => _this('BOB', onChanged);
  T rsd({ValueChanged<num>? onChanged}) => _this('RSD', onChanged);
  T lkr({ValueChanged<num>? onChanged}) => _this('LKR', onChanged);
  T hrk({ValueChanged<num>? onChanged}) => _this('HRK', onChanged);
  T azn({ValueChanged<num>? onChanged}) => _this('AZN', onChanged);
  T aoa({ValueChanged<num>? onChanged}) => _this('AOA', onChanged);
  T hnl({ValueChanged<num>? onChanged}) => _this('HNL', onChanged);
  T byn({ValueChanged<num>? onChanged}) => _this('BYN', onChanged);
  T crc({ValueChanged<num>? onChanged}) => _this('CRC', onChanged);
  T lyd({ValueChanged<num>? onChanged}) => _this('LYD', onChanged);
  T mur({ValueChanged<num>? onChanged}) => _this('MUR', onChanged);
  T isk({ValueChanged<num>? onChanged}) => _this('ISK', onChanged);
  T pyg({ValueChanged<num>? onChanged}) => _this('PYG', onChanged);
  T tzs({ValueChanged<num>? onChanged}) => _this('TZS', onChanged);
  T ttd({ValueChanged<num>? onChanged}) => _this('TTD', onChanged);
  T all({ValueChanged<num>? onChanged}) => _this('ALL', onChanged);
  T cdf({ValueChanged<num>? onChanged}) => _this('CDF', onChanged);
  T gel({ValueChanged<num>? onChanged}) => _this('GEL', onChanged);
  T bnd({ValueChanged<num>? onChanged}) => _this('BND', onChanged);
  T uyu({ValueChanged<num>? onChanged}) => _this('UYU', onChanged);
  T mzn({ValueChanged<num>? onChanged}) => _this('MZN', onChanged);
  T bsd({ValueChanged<num>? onChanged}) => _this('BSD', onChanged);
  T ugx({ValueChanged<num>? onChanged}) => _this('UGX', onChanged);
  T mnt({ValueChanged<num>? onChanged}) => _this('MNT', onChanged);
  T lak({ValueChanged<num>? onChanged}) => _this('LAK', onChanged);
  T sdg({ValueChanged<num>? onChanged}) => _this('SDG', onChanged);
  T bwp({ValueChanged<num>? onChanged}) => _this('BWP', onChanged);
  T nad({ValueChanged<num>? onChanged}) => _this('NAD', onChanged);
  T bam({ValueChanged<num>? onChanged}) => _this('BAM', onChanged);
  T mkd({ValueChanged<num>? onChanged}) => _this('MKD', onChanged);
  T amd({ValueChanged<num>? onChanged}) => _this('AMD', onChanged);
  T mdl({ValueChanged<num>? onChanged}) => _this('MDL', onChanged);
  T xpf({ValueChanged<num>? onChanged}) => _this('XPF', onChanged);
  T jmd({ValueChanged<num>? onChanged}) => _this('JMD', onChanged);
  T nio({ValueChanged<num>? onChanged}) => _this('NIO', onChanged);
  T gnf({ValueChanged<num>? onChanged}) => _this('GNF', onChanged);
  T mga({ValueChanged<num>? onChanged}) => _this('MGA', onChanged);
  T kgs({ValueChanged<num>? onChanged}) => _this('KGS', onChanged);
  T mvr({ValueChanged<num>? onChanged}) => _this('MVR', onChanged);
  T rwf({ValueChanged<num>? onChanged}) => _this('RWF', onChanged);
  T gyd({ValueChanged<num>? onChanged}) => _this('GYD', onChanged);
  T btn({ValueChanged<num>? onChanged}) => _this('BTN', onChanged);
  T cve({ValueChanged<num>? onChanged}) => _this('CVE', onChanged);
  T scr({ValueChanged<num>? onChanged}) => _this('SCR', onChanged);
  T xaf({ValueChanged<num>? onChanged}) => _this('XAF', onChanged);
  T bif({ValueChanged<num>? onChanged}) => _this('BIF', onChanged);
  T szl({ValueChanged<num>? onChanged}) => _this('SZL', onChanged);
  T gmd({ValueChanged<num>? onChanged}) => _this('GMD', onChanged);
  T lrd({ValueChanged<num>? onChanged}) => _this('LRD', onChanged);
  T sll({ValueChanged<num>? onChanged}) => _this('SLL', onChanged);
  T lsl({ValueChanged<num>? onChanged}) => _this('LSL', onChanged);
  T kmf({ValueChanged<num>? onChanged}) => _this('KMF', onChanged);
  T bdt({ValueChanged<num>? onChanged}) => _this('BDT', onChanged);
  T tnd({ValueChanged<num>? onChanged}) => _this('TND', onChanged);
  T zmk({ValueChanged<num>? onChanged}) => _this('ZMK', onChanged);
  T tjs({ValueChanged<num>? onChanged}) => _this('TJS', onChanged);
  T mwk({ValueChanged<num>? onChanged}) => _this('MWK', onChanged);
  T std({ValueChanged<num>? onChanged}) => _this('STD', onChanged);
}

const currencyConfigs = {
  'CNY': {
    'leading': '¥',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'USD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'EUR': {
    'leading': '€',
    'mantissa': 2,
    'separator': ThousandSeparator.Period,
    'usePadding': true,
  },
  'JPY': {
    'leading': '¥',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'GBP': {
    'leading': '£',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'KRW': {
    'leading': '₩',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'INR': {
    'leading': '₹',
    'mantissa': 2,
    'separator': ThousandSeparator.SpaceAndCommaMantissa,
    'usePadding': true,
  },
  'CAD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'HKD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'BRL': {
    'leading': r'R$',
    'mantissa': 2,
    'separator': ThousandSeparator.Period,
    'usePadding': true,
  },
  'AUD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'TWD': {
    'leading': r'NT$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'RUB': {
    'leading': '₽',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'CHF': {
    'leading': 'CHF',
    'mantissa': 2,
    'separator': ThousandSeparator.Period,
    'usePadding': true,
  },
  'MXN': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'SAR': {
    'leading': 'ر.س',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'THB': {
    'leading': '฿',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'AED': {
    'leading': 'د.إ',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'SGD': {
    'leading': r'S$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'VND': {
    'leading': '₫',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'IDR': {
    'leading': 'Rp',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'ILS': {
    'leading': '₪',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MYR': {
    'leading': 'RM',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'SEK': {
    'leading': 'kr',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'PLN': {
    'leading': 'zł',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'TRY': {
    'leading': '₺',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'CLP': {
    'leading': r'$',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'NOK': {
    'leading': 'kr',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'PHP': {
    'leading': '₱',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'ZAR': {
    'leading': 'R',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'EGP': {
    'leading': 'ج.م.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'DKK': {
    'leading': 'kr.',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'CZK': {
    'leading': 'Kč',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'NZD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'QAR': {
    'leading': 'ر.ق',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'COP': {
    'leading': r'$',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'MAD': {
    'leading': 'د.م.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'PKR': {
    'leading': 'Rs',
    'mantissa': 2,
    'separator': ThousandSeparator.SpaceAndCommaMantissa,
    'usePadding': true,
  },
  'LBP': {
    'leading': 'ل.ل',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'KWD': {
    'leading': 'د.ك',
    'mantissa': 3,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'RON': {
    'leading': 'lei',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'NGN': {
    'leading': '₦',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'ARS': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'IQD': {
    'leading': 'ع.د',
    'mantissa': 3,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'HUF': {
    'leading': 'Ft',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MOP': {
    'leading': r'MOP$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'PEN': {
    'leading': 'S/',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BGN': {
    'leading': 'лв.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'KZT': {
    'leading': '₸',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'UAH': {
    'leading': '₴',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'JOD': {
    'leading': 'د.أ',
    'mantissa': 3,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'OMR': {
    'leading': 'ر.ع.',
    'mantissa': 3,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'GTQ': {
    'leading': 'Q',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BHD': {
    'leading': 'د.ب',
    'mantissa': 3,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'DOP': {
    'leading': r'RD$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'XOF': {
    'leading': 'CFA',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'KES': {
    'leading': 'KSh',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BOB': {
    'leading': 'Bs',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'RSD': {
    'leading': 'дин.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'LKR': {
    'leading': 'Rs',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'HRK': {
    'leading': 'kn',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'AZN': {
    'leading': '₼',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'AOA': {
    'leading': 'Kz',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'HNL': {
    'leading': 'L',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BYN': {
    'leading': 'Br',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'CRC': {
    'leading': '₡',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'LYD': {
    'leading': 'ل.م',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MUR': {
    'leading': '₨',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'ISK': {
    'leading': 'kr',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'PYG': {
    'leading': '₲',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'TZS': {
    'leading': 'TSh',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'TTD': {
    'leading': r'TT$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'ALL': {
    'leading': 'L',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'CDF': {
    'leading': 'FC',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'GEL': {
    'leading': '₾',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BND': {
    'leading': r'B$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'UYU': {
    'leading': r'$U',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MZN': {
    'leading': 'MT',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BSD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'UGX': {
    'leading': 'USh',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'MNT': {
    'leading': '₮',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'LAK': {
    'leading': '₭',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'SDG': {
    'leading': 'ج.س.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'BWP': {
    'leading': 'P',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'NAD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'BAM': {
    'leading': 'KM',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MKD': {
    'leading': 'ден.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'AMD': {
    'leading': '֏',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MDL': {
    'leading': 'L',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'XPF': {
    'leading': 'XPF',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'JMD': {
    'leading': r'J$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'NIO': {
    'leading': r'C$',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'GNF': {
    'leading': 'FG',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'MGA': {
    'leading': 'Ar',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'KGS': {
    'leading': 'с',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MVR': {
    'leading': 'Rf',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'RWF': {
    'leading': 'FRw',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'GYD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'BTN': {
    'leading': 'Nu.',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'CVE': {
    'leading': 'Esc',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'SCR': {
    'leading': '₨',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'XAF': {
    'leading': 'FCFA',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'BIF': {
    'leading': 'FBu',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'SZL': {
    'leading': 'E',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'GMD': {
    'leading': 'D',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'LRD': {
    'leading': r'$',
    'mantissa': 2,
    'separator': ThousandSeparator.Comma,
    'usePadding': true,
  },
  'SLL': {
    'leading': 'Le',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'LSL': {
    'leading': 'R',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'KMF': {
    'leading': 'CF',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'BDT': {
    'leading': '৳',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'TND': {
    'leading': 'د.ت',
    'mantissa': 3,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'ZMK': {
    'leading': 'K',
    'mantissa': 0,
    'separator': ThousandSeparator.None,
    'usePadding': false,
  },
  'TJS': {
    'leading': 'SM',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'MWK': {
    'leading': 'K',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
  'STD': {
    'leading': 'Db',
    'mantissa': 2,
    'separator': ThousandSeparator.None,
    'usePadding': true,
  },
};
