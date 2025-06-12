import 'dart:async';

import 'package:flutter/foundation.dart';

import 'param.dart';

export 'injector.dart';

/// Signature to locate dependencies by [Param].
typedef ParamLocator = FutureOr Function(Param param);

/// A class that injects dependencies into a function.
///
/// You must provide [T] if you wanna inject an abstract class.
/// Otherwise, it will be inferred from the [create] function.
class Injector<T> {
  /// Creates a new instance of [Injector].
  ///
  /// The [create] function is used to extract the constructor parameters.
  /// All parameters are lazily resolved.
  ///
  /// - [locator] is used to locate the dependencies by type.
  /// - [parameters] is used to manually provide a dependency by name or type.
  /// - [ignorePrivateTypes] is used to ignore private types.
  ///
  /// A default [ParamLocator] can be set using [Injector.defaultLocator].
  ///
  /// Example:
  /// ```dart
  /// final vmInjector = Injector(ViewModel.new, parameters: pathParameters);
  /// final viewModel = vmInjector(parameters: {'someId': 1});
  /// ```
  ///
  Injector(
    this.create, {
    this.locator,
    this.parameters,
    this.ignorePrivateTypes = true,
  });

  /// The default [ParamLocator] to use. Applied to all [Injector].
  ///
  /// This is called when [locator] returns `null`.
  static ParamLocator? defaultLocator;

  /// The [T] function to inject.
  final Function create;

  /// The locate args by [Param] while injecting.
  final ParamLocator? locator;

  /// The arguments values to use while injecting.
  /// Example:
  /// ```dart
  /// Injector(Text.new, parameters: {
  ///   '0': 'Hello', // by index
  ///   'style': TextStyle(), // by name
  ///   '$TextAlign': TextAlign.center, // by type
  /// });
  /// ```
  final Map<String, dynamic>? parameters;

  /// Whether to ignore private types.
  final bool ignorePrivateTypes;

  /// The return type of [create] function.
  ///
  /// If [create] is a [Future] or [Stream], the subtype is returned.
  late final type = _type();

  /// The type of [create] function.
  late final rawType = _rawType();

  /// The return type of [create] function.
  late final returnType = _returnType();

  /// Whether the [create] function is async.
  bool get isAsync {
    return returnType.startsWith(_future) || rawType.startsWith(_stream);
  }

  // handling minified types
  static final _future = '$Future'.split('<').first;
  static final _stream = '$Stream'.split('<').first;
  static final _generics = ['$dynamic', '$Object'];

  String _type() {
    if (!isAsync) return rawType.replaceAll('?', '');

    return rawType.split('<').last.split('>').first.replaceAll('?', '');
  }

  String _rawType() {
    if (!_generics.contains(T.type)) return T.toString();

    return returnType;
  }

  String _returnType() {
    final typeLine = _createTexts.last.replaceFirst(' => ', '');
    final buffer = StringBuffer();
    var nestedLevel = 0;

    for (final char in typeLine.split('')) {
      if (nestedLevel == 0 && char == ' ') {
        final type = buffer.toString();
        if (!type.endsWith(')') && !type.endsWith('=>')) return type;
      }
      if (char == '<' || char == '(') nestedLevel++;
      if (char == '>' || char == ')') nestedLevel--;
      buffer.write(char);
    }

    return buffer.toString();
  }

  /// Whether [create] has parameters.
  /// If false, we can treat it as a [ValueGetter] of [T].
  late final hasParams = !_createText.startsWith('() => ');

  /// All parameters of the constructor.
  List<Param> get params => List.unmodifiable(_params);

  /// Named parameters of the constructor.
  List<NamedParam> get namedParams => List.unmodifiable(_named);

  /// Positional parameters of the constructor.
  List<PositionalParam> get positionalParams => List.unmodifiable(_positional);

  /// Performs the injection.
  ///
  /// You can add locators on top of pre-existing ones. No overriding.
  /// - Use [locator] to locate args by [Param].
  /// - Use [parameters] to manually provide named args by [Symbol].
  ///
  /// Example:
  /// ```dart
  /// final userInjector = Injector(User.new, parameters: userJson);
  /// final user = userInjector({'id': 1, 'name': 'John'});
  /// ```
  ///
  FutureOr<T> call([Map<String, dynamic>? parameters]) {
    // ignore: return_of_invalid_type
    if (!hasParams) return this.create();

    if (this.parameters != null || parameters != null) {
      parameters = {...?this.parameters, ...?parameters};
    }

    final futures = <Future>[];

    dynamic locate(Param param) =>
        parameters?['${param.name ?? param.index}'] ??
        parameters?[param.type] ??
        locator?.call(param) ??
        defaultLocator?.call(param);

    final positionalArgs = <dynamic>[];

    for (final param in _positional) {
      final arg = locate(param);

      if (arg == null && param.hasDefaultValue) continue;

      if (arg is Future && !param.isFuture) {
        // we cant use `param.index` here because of optionals
        final index = (positionalArgs.length += 1) - 1;
        futures.add(Future(() async => positionalArgs[index] = await arg));
      } else {
        positionalArgs.add(arg);
      }
    }

    final namedArgs = <Symbol, dynamic>{};

    for (final param in _named) {
      final arg = locate(param);

      if (arg == null && param.hasDefaultValue) continue;

      if (arg is Future && !param.isFuture) {
        futures.add(Future(() async => namedArgs[param.symbol] = await arg));
      } else {
        namedArgs[param.symbol] = arg;
      }
    }

    FutureOr<T> create() {
      try {
        // ignore: return_of_invalid_type
        return Function.apply(this.create, positionalArgs, namedArgs);
        // ignore: avoid_catching_errors
      } on TypeError catch (e) {
        throw InjectorError.from(e, this);
      }
    }

    if (futures.isEmpty) return create();

    return Future.wait(futures).then((_) => create());
  }

  // lazy cache
  late final _createText = create.runtimeType.toString();
  late final _createTexts = _createText.splitBetween('(', ')')..removeAt(0);
  late final _input = _createTexts.first;
  late final _namedInput = _input.firstMatch(r'\{(.+)\}')?.group(1);
  late final _positionalInput =
      _namedInput != null ? _input.replaceAll('{$_namedInput}', '') : _input;

  // lazy params
  late final _params = [..._positional, ..._named];
  late final _named = _namedParams();
  late final _positional = _positionalParams();

  List<NamedParam> _namedParams() {
    if (!hasParams) return [];
    if (_namedInput == null) return [];

    final list = <NamedParam>[];
    final paramList = splitParams(_namedInput);

    for (final paramText in paramList) {
      final parts = paramText.split(' '); // ex: required Type name
      final isRequired = parts.remove('required');
      final name = parts.removeLast();
      final rawType = parts.join(' '); // for: () => void

      if (ignorePrivateTypes && rawType.startsWith('_')) continue;

      list.add(
        NamedParam(
          rawType,
          name: name,
          isRequired: isRequired,
          owner: this,
        ),
      );
    }

    return list;
  }

  List<PositionalParam> _positionalParams() {
    if (!hasParams) return [];
    if (_positionalInput.isEmpty) return [];

    final list = <PositionalParam>[];
    final paramList = splitParams(_positionalInput);

    var inBrackets = false;
    for (final paramText in paramList) {
      var rawType = paramText;
      var isRequired = !inBrackets;

      if (paramText.startsWith('[')) {
        inBrackets = true;
        isRequired = false;
        rawType = paramText.substring(1).trim();
      }

      if (paramText.endsWith(']')) {
        inBrackets = false;
        isRequired = false;
        rawType = paramText.substring(0, paramText.length - 1).trim();
      }

      if (ignorePrivateTypes && rawType.startsWith('_')) continue;

      list.add(
        PositionalParam(
          rawType,
          index: list.length,
          isRequired: isRequired,
          owner: this,
        ),
      );
    }

    return list;
  }

  List<String> splitParams(String input) {
    final list = <String>[];
    final currentParam = StringBuffer();
    var nestedLevel = 0;

    void addCurrent() {
      if (currentParam.isNotEmpty) {
        final param = currentParam.toString().trim();

        if (param.isNotEmpty) list.add(param);
        currentParam.clear();
      }
    }

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      if (char == ',' && nestedLevel == 0) {
        addCurrent();
      } else {
        // handle subtypes & records
        if (char == '<' || char == '(') nestedLevel++;
        if (char == '>' || char == ')') nestedLevel--;
        if (nestedLevel < 0) nestedLevel = 0;
        currentParam.write(char);
      }
    }
    addCurrent(); // add the last param, if any

    return list;
  }

  @override
  String toString() {
    return 'Injector<$type>${rawType == type ? '' : ' Raw: $rawType'}';
  }
}

class InjectorError implements TypeError {
  InjectorError._({
    required this.resultT,
    required this.expectedT,
    required this.stackTrace,
    required this.owner,
    required this.name,
  });

  factory InjectorError.from(TypeError e, Injector owner) {
    final parts = '$e'.split("'").where((s) => !s.contains(' ')).take(3);
    if (parts.length < 3 || parts.last.isEmpty) throw e;
    final [resultT, expectedT, name] = parts.toList();

    return InjectorError._(
      owner: owner,
      resultT: resultT,
      expectedT: expectedT,
      stackTrace: e.stackTrace,
      name: name.split('@').first,
    );
  }

  /// The type of the result.
  final String resultT;

  /// The expected type.
  final String expectedT;

  /// The name of the parameter.
  final String name;

  /// The [Injector] that caused the error.
  final Injector owner;

  @override
  final StackTrace? stackTrace;

  /// The error message.
  String get message {
    final message = 'Expected: ${owner.returnType}($expectedT $name)';
    if (resultT == 'Null') {
      return '$expectedT not found. $message';
    }
    return '$resultT is! $expectedT. $message';
  }

  @override
  String toString() => 'InjectorError: $message';
}

extension on String {
  RegExpMatch? firstMatch(String regex) => RegExp(regex).firstMatch(this);
}

extension SplitBetweenExtension on String {
  List<String> splitBetween(String start, String end) {
    if (start.length != 1 || end.length != 1) {
      throw ArgumentError('Delimiter must be a single character');
    }

    final startIndex = indexOf(start);
    if (startIndex == -1) throw ArgumentError('Start delimiter not found');

    var balance = 1;
    var currentIndex = startIndex + 1;

    // find matching closing delimiter
    while (currentIndex < length && balance > 0) {
      if (this[currentIndex] == start) balance++;
      if (this[currentIndex] == end) balance--;
      currentIndex++;
    }

    if (balance != 0) throw ArgumentError('Unbalanced delimiters');

    return [
      substring(0, startIndex), // before
      substring(startIndex + 1, currentIndex - 1), // between
      substring(currentIndex), // after
    ];
  }
}

extension TypeExtension on Type {
  String get type => toString().replaceAll('?', '');
}
