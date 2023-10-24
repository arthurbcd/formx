import 'param.dart';

/// Inspired by Flutterando's auto_injector library.
class Constructor {
  Constructor(this.constructor, {this.ignorePrivateTypes = true}) {
    _params.addAll(_parse());
  }
  final Function constructor;
  final List<Param> _params = [];
  final bool ignorePrivateTypes;

  List<Param> get params => _params.where((e) {
        if (ignorePrivateTypes && e.type.startsWith('_')) {
          return false;
        }
        return true;
      }).toList();

  List<NamedParam> get namedParams => params.whereType<NamedParam>().toList();

  List<PositionalParam> get positionalParams =>
      params.whereType<PositionalParam>().toList();

  List<Param> _parse() {
    final params = <Param>[];

    final constructorString = constructor.toString();

    if (constructorString.startsWith('() => ')) {
      return params;
    }

    var hasOnlyRequired = false;
    if (constructorString.startsWith('Closure: ({')) hasOnlyRequired = true;

    final allArgsRegex = RegExp(r'\((.+)\) => .+');

    final allArgsMatch = allArgsRegex.firstMatch(constructorString);

    var allArgs = allArgsMatch!.group(1)!;

    final hasNamedParams = RegExp(hasOnlyRequired ? r'\{(.+)\}' : r' \{(.+)\}');
    final namedParams = hasNamedParams.firstMatch(allArgs);

    if (namedParams != null) {
      final named = namedParams.group(1)!;
      allArgs = allArgs.replaceAll('{$named}', '');

      final paramsText = _customSplit(named);

      for (final paramText in paramsText) {
        final paramSplitted = paramText.split(' ');

        final isRequired = paramSplitted.first == 'required';
        if (isRequired) paramSplitted.removeAt(0);

        final named = Symbol(paramSplitted.last);
        paramSplitted.removeLast();

        final type = paramSplitted.join(' ');

        final param = NamedParam(
          type: type,
          isRequired: isRequired,
          named: named,
        );

        params.add(param);
      }
    }

    if (allArgs.isNotEmpty) {
      final paramList = _customSplit(allArgs);
      final allParam = paramList //
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) {
        return PositionalParam(
          type: e,
          isRequired: true,
        );
      }).toList();

      params.addAll(allParam);
    }

    return params;
  }

  List<String> _customSplit(String input) {
    final parts = <String>[];
    var currentPart = '';
    var bracketCount = 0;
    const openBrackets = ['<', '(', '['];
    const closeBrackets = ['>', ')', ']'];

    var previousChar = '';
    for (final char in input.runes) {
      final charStr = String.fromCharCode(char);

      if (charStr == ',' && bracketCount == 0) {
        parts.add(currentPart.trim());
        currentPart = '';
      } else {
        currentPart += charStr;

        if (openBrackets.contains(charStr)) {
          bracketCount++;
        } else if (closeBrackets.contains(charStr) && previousChar != '=') {
          bracketCount--;
        }
      }
      previousChar = charStr;
    }

    if (currentPart.isNotEmpty && currentPart != ' ') {
      parts.add(currentPart.trim());
    }

    return parts;
  }
}
