/// Build, validate and fill forms easily with extended Form and TextFormField.

// ignore_for_file: invalid_use_of_protected_member

library formx;

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

export 'package:formx/src/extensions/keep_alive_extension.dart';

/// Signature for [Formx.builder].
typedef FormxBuilder = Widget Function(FormxState state);

/// Signature for [Formx.onChanged].
typedef FormxCallback = void Function(FormxState state);

/// A [Form] that handles any [FormField] and nested [Formx] below it.
class Formx extends StatefulWidget {
  /// A form can also be nested in another [Formx] for more complex forms.
  ///
  /// Use `Formx.of(context)`, `GlobalKey` or [builder] to access [FormxState].
  ///
  /// Example:
  ///
  /// ```dart
  /// Formx(
  ///   tag: null,
  ///   child: Formx(
  ///     tag: 'my_nested_form',
  ///     child: TextFormxField('my_field'),
  ///   ),
  /// )
  /// ```
  ///
  /// Which results in the form:
  ///
  /// ```dart
  /// {
  ///  'my_nested_form': {'my_field': 'value'},
  /// }
  const Formx({
    super.key,
    this.initialValues,
    this.onChanged,
    this.onSaved,
    this.builder,
    this.child,
    this.autovalidateMode,
  }) : assert(
          (child != null) != (builder != null),
          'You must set either child or builder, but not both.',
        );

  /// The initial value for each nested [FormField] or [Formx], that has a
  /// valid [Key].
  ///
  /// Example:
  ///
  /// 1. Set a key.
  /// ```dart
  ///  TextFormField(key: 'name'.key),
  /// ```
  ///
  /// 2. Set the initial value.
  /// ```dart
  /// Formx(
  ///  initialValues: {
  ///   'name': 'John',
  ///  },
  /// ```
  final Map<String, dynamic>? initialValues;

  /// Sintax-sugar for accessing the [FormState].
  final FormxBuilder? builder;

  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// Same as [Form.onChanged], but callbacks the [FormxState].
  ///
  /// If it is a nested [Formx], it will trigger the parent [onChanged] as well.
  final FormxCallback? onChanged;

  /// Called when [FormxState.save] is called.
  final FormxCallback? onSaved;

  /// The [Form.autovalidateMode] that fields will inherit.
  ///
  /// If null:
  /// - [Formx] - starts with [AutovalidateMode.disabled] and then changes to
  /// [AutovalidateMode.always] after the first validation.
  ///
  /// - [Form] - starts and stays with [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

  /// Returns the first [FormxState] above [BuildContext].
  static FormxState of(BuildContext context) {
    final maybe = maybeOf(context);
    assert(maybe != null, 'No [Formx] of this context.');

    return maybe!;
  }

  /// Returns the first [FormxState] above [BuildContext] or null.
  static FormxState? maybeOf(BuildContext context) {
    final widget = context.getInheritedWidgetOfExactType<_Form2Scope>();

    return widget?.state;
  }

  @override
  State<Formx> createState() => FormxState();
}

/// The state of a [Formx].
class FormxState extends State<Formx> {
  /// The parent [FormxState] descendant of this [context].
  late final FormxState? parent = () {
    final state = Formx.maybeOf(context);
    if (widget.key?.value case String key) {
      assert(
          state != null,
          'This [Formx] has a valid key but no parent was found. '
          'Only use a valid key if you are using a nested [Formx].');
      state?._nested[key] = this;
      return state;
    }
    return null;
  }();

  final _fields = <String, FormFieldState>{};
  final _nested = <String, FormxState>{};
  bool? _hasInteractedByUser;
  bool _hasValidated = false;

  /// Wheter this [Formx] has a valid [Key].
  bool get hasValidKey => widget.key?.value != null;

  /// The [AutovalidateMode] for this [Formx].
  AutovalidateMode? get autovalidateMode {
    if (_hasInteractedByUser == null) return null;
    final mode = widget.autovalidateMode ?? parent?.autovalidateMode;

    return _hasValidated && mode == null ? AutovalidateMode.always : mode;
  }

  /// The initial value for each nested [FormField] or [Formx].
  Map<String, dynamic>? get initialValues =>
      widget.initialValues ??
      parent?.initialValues?[widget.key?.value] as Map<String, dynamic>?;

  /// All attached [FormFieldState].
  Map<String, FormFieldState> get fields => UnmodifiableMapView(_fields);

  /// All attached [FormxState] and nested [FormFieldState].
  Map<String, FormxState> get nested => UnmodifiableMapView(_nested);

  /// A [Map] containaing all attached field values.
  Map<String, dynamic> get form {
    var form = <String, dynamic>{};
    _fields.forEach((key, field) => form[key] = field.value);
    _nested.forEach((key, formx) => form[key] = formx.form);
    return form;
  }

  /// Returns true if [fields] or [nested] have errors. Doesn't set ui state.
  bool get hasError =>
      _fields.values.any((field) => field.hasError) ||
      _nested.values.any((formx) => formx.hasError);

  /// Returns true if [fields] and [nested] are valid. Doesn't set ui state.
  bool get isValid =>
      _fields.values.every((field) => field.isValid) &&
      _nested.values.every((formx) => formx.isValid);

  /// Returns a flat [Map] of all [_fields] and [_nested] errorTexts.
  ///
  /// Note, if they were not validated, they will not be present.
  Map<String, String> get errorTexts {
    final errorTexts = <String, String>{};
    _fields.forEach((tag, field) => errorTexts[tag] = field.errorText ?? '');
    _nested.forEach((tag, formx) => errorTexts.addAll(formx.errorTexts));
    return errorTexts..removeWhere((key, value) => value.isEmpty);
  }

  /// Gets either a [FormFieldState.value] or [FormxState.form] by [key].
  Object? operator [](String key) {
    final state = stateWhere((e) => e.key == key);

    if (state is FormFieldState) return state.value;
    if (state is FormxState) return state.form;
    return null;
  }

  /// Sets either a [FormFieldState.value] or [FormxState.form] value by [key].
  void operator []=(String key, Object? value) {
    final state = stateWhere((e) => e.key == key);

    if (state is FormFieldState) state.didChange(value);
    if (state is FormxState && value is Map) state.fill(value.cast());
  }

  void _visitFields() {
    _fields.clear();
    void visit(Element el) {
      if ((el, el.widget.key) case (StatefulElement el, Key key)) {
        // stop recursion, the nested form will handle it.
        if (el.state is FormxState) return;

        if (el.state case FormFieldState state) {
          if (key.value case String value) {
            _fields[value] = state.._attachToValidator();
            return;
          }
          assert(
            true,
            'FormField.key.value is not a String: $key.\n'
            'You must set a valid key for this FormField:\n\n'
            'Ex: `TextFormField(key: const Key("name"))`',
          );
        }
      }
      el.visitChildren(visit); // continue recursion
    }

    if (mounted) context.visitChildElements(visit);
  }

  void _onChanged() {
    // still waiting for the first build.
    if (_hasInteractedByUser == null) return;

    // ready to go.
    if (_hasInteractedByUser == false) {
      setState(() => _hasInteractedByUser = true);
    }
    _visitFields();

    // We callback the change.
    widget.onChanged?.call(this);

    if (parent case FormxState parent when hasValidKey) {
      // If this is a nested form, we callback the parent as well.
      parent._onChanged();
    }

    if (hasError && !_hasValidated) {
      setState(() => _hasValidated = true);
    }
  }

  /// Fills this [FormxState.form] with new [values].
  void fill(Map<String, dynamic> values) {
    values.forEach((key, value) {
      if (value case Map<String, dynamic> form) return _nested[key]?.fill(form);

      _fields[key]?.didChange(value);
    });
  }

  /// Resets all fields.
  ///
  /// Optionally, you can set [keys] to reset only specific fields.
  void reset([List<String> keys = const []]) {
    _hasInteractedByUser = null;
    _hasValidated = false;

    for (final e in _fields.entries) {
      if (keys.isEmpty || keys.contains(e.key)) {
        e.value.reset();
        if (initialValues?[e.key] case Object value) e.value.didChange(value);
      }
    }
    _nested.forEach((key, formx) => formx.reset(keys));
    setState(() => _hasInteractedByUser = false);
  }

  /// Saves all fields.
  ///
  /// Optionally, you can set [keys] to save only specific fields.
  void save([List<String> keys = const []]) {
    for (final e in _fields.entries) {
      if (keys.isEmpty || keys.contains(e.key)) e.value.save();
    }
    _nested.forEach((key, formx) => formx.save(keys));
    widget.onSaved?.call(this);
  }

  /// Validates this and nested fields.
  ///
  /// Optionally, you can set [keys] to validate only specific fields.
  bool validate([List<String> keys = const []]) {
    final isValid = _fields.entries
        .where((e) => keys.isEmpty || keys.contains(e.key))
        .fold(true, (p, e) {
      e.value._attachToValidator();
      return e.value.validate() && p;
    });

    final areValid = _nested.values.fold(true, (p, e) => e.validate(keys) && p);
    return isValid && areValid;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visitFields();
      if (initialValues case Map<String, dynamic> map) fill(map);

      // unlock autovalidateMode after the first build.
      setState(() => _hasInteractedByUser = false);
    });
  }

  @override
  void reassemble() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _visitFields());
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return _Form2Scope(
      state: this,
      child: Form(
        autovalidateMode: autovalidateMode,
        onChanged: _onChanged,
        child: Builder(
          builder: (context) {
            if (widget.builder case FormxBuilder builder) {
              return builder(this);
            }
            return widget.child ?? (throw StateError('No child or builder'));
          },
        ),
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    final debugMessage = super.toString(minLevel: minLevel);
    return '''
$debugMessage
key: ${widget.key}
form: ${form.indented},
''';
  }
}

class _Form2Scope extends InheritedWidget {
  const _Form2Scope({required this.state, required super.child});
  final FormxState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

extension on Key {
  String? get value {
    try {
      return (this as dynamic).value as String;
    } catch (_) {}
    return null;
  }
}

extension on FormxState {
  State? stateWhere(bool Function(MapEntry<String, State> e) visitor) {
    for (final e in _fields.entries) {
      if (visitor(e)) return e.value;
    }
    for (final e in _nested.entries) {
      if (visitor(e)) return e.value.stateWhere(visitor);
    }
    return null;
  }
}

/// Extends [FormFieldState] with a programatic way to set [errorText].
extension FormFieldExtension on FormFieldState {
  /// Sets the [errorText] programatically.
  ///
  /// You need to set a [Validator] to use this method.
  void setErrorText(String? errorText) {
    _attachToValidator(errorText: errorText);
    validate();
  }

  void _attachToValidator({String? errorText}) {
    final _FieldData data;
    try {
      data = (
        state: this,
        errorText: errorText,
      );
      widget.validator?.call(data);
    } catch (_) {
      assert(
        errorText == null,
        'No `Validator` was set for this `$this`.\n'
        'You must set `Validator` class in order to call `setErrorText`.\n'
        'Ex:\n'
        '```dart\n'
        'TextFormField(\n'
        "   key: const Key('email'),\n "
        '  validator: Validator(), // <-- set your `Validator` here\n'
        ')\n'
        '```\n'
        'Then call:\n'
        '```dart\n'
        "state.fields['email']?.setErrorText('errorText');\n"
        '```\n',
      );
    }
  }
}

/// Signature for binding a [FormFieldState] to a [FormFieldValidator].
typedef _FieldData = ({FormFieldState state, String? errorText});

/// Extension for [Map] to convert it to an indented [String].
extension FormxIndentedExtension on Map<dynamic, dynamic> {
  /// Converts this [Map] to a indented [String].
  String get indented {
    return JsonEncoder.withIndent('  ', (e) => e.toString()).convert(this);
  }

  /// Removes all null or empty values from this [Map] and nesteds.
  void clean() {
    // ignore: avoid_types_on_closure_parameters
    removeWhere((key, Object? value) {
      if (value is Map) value.clean();

      return value == null || value.isEmpty;
    });
  }
}

/// Extension to enable Object inference casting by type.
extension FormxCastExtension on Object? {
  /// Returns this as [T].
  T cast<T>() => this as T;

  /// Returns this as [T] if it is [T], otherwise null.
  T? tryCast<T>() => this is T ? this as T : null;
}

extension on Object {
  bool get isEmpty {
    if (this case Iterable e) return e.isEmpty;
    if (this case String e) return e.isEmpty;
    if (this case Map e) return e.isEmpty;
    return false;
  }
}

/// A class that handles the validation of a [FormField].
///
/// It can be used as a [FormField.validator] or as a programatic way to set
/// errorTexts, declaratively or imperatively.
class Validator<T> {
  /// Creates a [Validator] that handles [FormField] validation declaratively.
  ///
  /// - [isRequired] - Whether this field is required.
  /// - [test] - The test to check if the value is valid.
  /// - [requiredText] - The required text to show when the field is empty.
  /// - [invalidText] - The invalid text to show when the field is invalid.
  Validator({
    ValidatorTest<T>? test,
    this.isRequired = false,
    this.requiredText,
    this.invalidText,
    this.validators = const [],
  }) : _test = test;

  /// Shorthand to [Validator.new] with a [test] and an optional [invalidText].
  Validator.test(
    ValidatorTest<T> test, [
    this.invalidText,
  ])  : _test = test,
        isRequired = false,
        requiredText = null,
        validators = [];

  /// The test to check if the value is valid.
  ///
  /// Always called after [isRequired] check. So value is never null or empty.
  final ValidatorTest<T>? _test;

  /// Whether this field is required.
  final bool isRequired;

  /// The required text to show when the field is empty.
  ///
  /// Defaults to [Validator.defaultRequiredText].
  final String? requiredText;

  /// The invalid text to show when the field is invalid.
  ///
  /// Defaults to [Validator.defaultInvalidText].
  final String? invalidText;

  /// Additional validators to be merged with this one.
  final List<Validator<T>> validators;

  /// The default required text.
  static String defaultRequiredText = 'Required value';

  /// The default invalid text.
  static String defaultInvalidText = 'Invalid value';

  /// Whether to disable all [Validator]'s on debug mode.
  static bool disableOnDebug = false;

  /// Modifies the `errorText` returned by [Validator].
  static ValidatorModifier modifier = (validator, errorText) => errorText;

  // States
  String? _errorText;
  FormFieldState? _state;

  /// The [Key] value of the [FormField] that this [Validator] is attached.
  late final String? key = _state?.widget.key?.value;

  /// Caller for [validator].
  ///
  /// Applies the [Validator.modifier] before calling it.
  String? call(Object? value) {
    if (value case _FieldData data) {
      if (data.errorText != null) _errorText = data.errorText;
      _state = data.state;
      return null;
    }

    if (validator(value) case String errorText) {
      return modifier(this, errorText);
    }

    return null;
  }

  /// The resolved [FormField.validator] for this [Validator].
  FormFieldValidator<Object> get validator {
    return (value) {
      // 0. Check if it is disabled.
      if (Validator.disableOnDebug && kDebugMode) return null;

      // 1. Check if errorText was set programatically.
      if (_errorText case String errorText) {
        _errorText = null;
        return errorText;
      }

      // 2. Check if it is required.
      if (value == null || value.isEmpty) {
        return isRequired ? requiredText ?? defaultRequiredText : null;
      }

      // 3. Check if it passes the test.
      if ((_test, value) case (ValidatorTest<T> test, T value)) {
        if (!test(value)) return invalidText ?? defaultInvalidText;
      }

      // 4. Check if any other merged validator are valid.
      for (final validator in validators) {
        if (validator(value) case String errorText) return errorText;
      }

      return null;
    };
  }
}

/// Signature for testing a value.
typedef ValidatorTest<T> = bool Function(T value);

/// Signature for modifying a [Validator] behavior.
typedef ValidatorModifier = String Function(
  Validator validator,
  String errorText,
);

/// Extension for [Validator] to add syntactic sugar.
extension ValidatorExtension<T> on Validator<T> {
  /// Returns a copy of this [Validator] with the new values.
  // Validator<T> copyWith({
  //   ValidatorTest<T>? test,
  //   bool? isRequired,
  //   String? requiredText,
  //   String? invalidText,
  // }) {
  //   return Validator(
  //     test: test ?? _test,
  //     isRequired: isRequired ?? this.isRequired,
  //     requiredText: requiredText ?? this.requiredText,
  //     invalidText: invalidText ?? this.invalidText,
  //   );
  // }

  /// Sets [Validator.isRequired] to `true`.
  // Validator<T> required([String? requiredText]) {
  //   return copyWith(isRequired: true, requiredText: requiredText);
  // }

  /// Sets [ValidatorTest]. Optionally, you can set [invalidText].
  // Validator<T> test(ValidatorTest<T> test, [String? invalidText]) {
  //   return this..add(copyWith(test: test, invalidText: invalidText).validat);
  // }

  // /// Sets [ValidatorTest] that callbacks the value as a [num].
  // Validator<T> number(ValidatorTest<num> test, [String? invalidText]) {
  //   return this.test(
  //     (value) {
  //       if (value is num) return test(value);
  //       if (num.tryParse('$value') case num number) return test(number);
  //       return true;
  //     },
  //     invalidText,
  //   );
  // }

  // /// Sets [ValidatorTest] to check if the value is not null or empty.
  // Validator<T> notEquals(Object value, [String? invalidText]) {
  //   return test((val) => val != value, invalidText);
  // }

  // /// Sets [ValidatorTest] to check if the value is equals to [value].
  // Validator<T> equals(Object value, [String? invalidText]) {
  //   return test((val) => val == value, invalidText);
  // }

  // /// Sets [ValidatorTest] to check if the value is greater than [value].
  // Validator<T> contains(Object value, [String? invalidText]) {
  //   return test((val) => '$val'.contains('$value'), invalidText);
  // }

  // /// Validates the minimum length of the value.
  // Validator<T> min(int length, [String? invalidText]) {
  //   return test((value) => '$value'.length >= length, invalidText);
  // }

  // /// Validates the maximum length of the value.
  // Validator<T> max(int length, [String? invalidText]) {
  //   return test((value) => '$value'.length <= length, invalidText);
  // }

  // /// Validates the length range of the value.
  // Validator<T> range(int min, int max, [String? invalidText]) {
  //   return test(
  //     (value) => '$value'.length >= min && '$value'.length <= max,
  //     invalidText,
  //   );
  // }

  // /// Validates [RegExp] pattern.
  // Validator<T> pattern(RegExp pattern, [String? invalidText]) {
  //   return test((val) => pattern.hasMatch('$val'), invalidText);
  // }

  // /// Validates if the value is one of the [list].
  // Validator<T> oneOf(List<T> list, [String? invalidText]) {
  //   return test((val) => list.contains(val), invalidText);
  // }

  // /// Validates if the value is not one of the [list].
  // Validator<T> notOneOf(List<T> list, [String? invalidText]) {
  //   return test((val) => !list.contains(val), invalidText);
  // }
}

extension on String {}

/// Extension for [String] for validations.
extension on String {
  /// Whether is a valid email. Special characters are ignored.
  bool get isCnpj {
    final numbers = replaceAll(RegExp(r'\D'), '');

    if (numbers.length != 14) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;

    int digit(String digits, List<int> weights) {
      var sum = 0;
      for (var i = 0; i < digits.length; i++) {
        sum += int.parse(digits[i]) * weights[i];
      }
      final mod = sum % 11;
      return mod < 2 ? 0 : 11 - mod;
    }

    final weight1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final weight2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    final d1 = digit(numbers.substring(0, 12), weight1);
    final d2 = digit(numbers.substring(0, 12) + d1.toString(), weight2);

    return numbers.substring(12) == d1.toString() + d2.toString();
  }

  /// Whether is a valid email. Special characters are ignored.
  bool get isCpf {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return false;

    int digit(String numbers, int length) {
      var sum = 0;
      for (var i = 0; i < length - 1; i++) {
        sum += int.parse(numbers[i]) * (length - i);
      }
      var mod = (sum * 10) % 11;
      return mod == 10 ? 0 : mod;
    }

    return int.parse(digits[9]) == digit(digits, 10) &&
        int.parse(digits[10]) == digit(digits, 11);
  }

  /// Whether is a valid phone number. Special characters are ignored.
  bool get isPhone => RegExp(
        r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
      ).hasMatch(this);

  /// Whether is a valid email. Special characters are ignored.
  bool get isEmail => RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      ).hasMatch(this);
}
