# Formx

<!-- markdownlint-disable no-inline-html -->
<p align="center">
  <img src="https://raw.githubusercontent.com/arthurbcd/formx/ea6d5d36ea384399838f650c8ca124743f43f40e/image-1.png" alt="Image 1" height="600"/>
  <img src="https://raw.githubusercontent.com/arthurbcd/formx/ea6d5d36ea384399838f650c8ca124743f43f40e/image-2.png" alt="Image 2" height="600"/>
</p>
<!-- markdownlint-enable no-inline-html -->

## Acessing the state

`BuildContext.formx([String? key])` automatically retrieves the appropriate `FormState` for you, though you can specify a key if necessary.

```dart
final addressState = context.formx();
// specify if multiple forms:
final addressState = context.formx('address'); 

if (addressState.validate()) {
  final map = addressState.toMap();
  addressState.save(); // do something with map
} else {
  throw FormxException(addressState.errorTexts);
}
```

> You can do the same for a specific field `final emailState = context.field('email')`

## Submit shortcut

Performs .validate(), .save() and .toMap(). Throws errorTexts if invalid.

```dart
// essentially the same as the code above, but in one line
final map = context.submit('address');
final mapOrNull = context.trySubmit('address');
```

> We recommend using it with `flutter_async` to handle errors effortlessly.

## FromMap.of shortcut

Performs .submit() in any .fromMap/fromJson constructor.
  
```dart
final user = User.fromMap.of(context);
final userOrNull = User.fromMap.maybeOf(context);
```

## FormState extensions

- `.toMap({FormxOptions? options})`, a structured `Map` with all the values of the form.
  - Use `options` to modify the output. If `null`, the global `Formx.options` will be used.
  - If a `Key` is used, it will apply the associated adapter or unmask to the value.
- `.rawValues`, a structured `Map` with all [FormFieldState.value]. Unmodified.
- `.initialValues`, a structured `Map` with all [FormField.initialValue]. Unmodified.
- `.isInitial`, whether any nested [FormFieldStateExtension.isInitial].
- `.hasInteractedByUser`, whether any nested [FormFieldState.hasInteractedByUser].
- `.hasError`, whether any nested [FormFieldState.hasError].
- `.isValid`, whether all nested [FormFieldState.isValid].
- `.invalids`, a list with all invalid field keys, regardless if validated.
- `.errorTexts`, a flat `Map` with all nested [FormFieldState.errorText].
- `.fill(Map<String, dynamic> map)`, sets each associated field by it's key-value pair.

## FormxState extension type

`FormxState` is an inline-class that redeclares some of the `FormState` methods:

- `.validate([List<String>? keys])`
- `.save([List<String>? keys])`
- `.reset([List<String>? keys])`

These methods function identically to their original counterparts but extend their effects to nested forms. Using `FormState.validate` only validates the top-level form, whereas `FormxState.validate` also validates any nested forms.

You have the option to specify a list of `keys` with these methods to target specific forms or fields for validation, saving, or resetting.

You can redeclare any `FormState` to a `FormxState` by using `FormxState(formState)` type extension.

## FormFieldState extensions

- `.setErrorText(String? errorText)`, sets the field errorText programmatically. Requires `Validator`.

## FormxSetup

You can use `Formx.setup` to set global options for all formx widgets.

- `defaultTitle` to set the default title for fields that internally use `ListTile`. 
- `datePicker` to pick a date in `FormField<DateTime>` fields.
- `filePicker` to pick a file in `FormField<XFile>` fields.
- `filesPicker` to pick a file in `FormField<List<XFile>>` fields.
- `fileUploader` to upload a file in `FormField<XFile>` fields.
- `fileDeleter` to delete a file in `FormField<XFile>` fields.

## FormxOptions

You can use `Formx.options` to modify `FormState.values` output.

- `trim` removes leading and trailing whitespaces.
- `unmask` removes all [MaskTextInputFormatter] masks.
- `nonNull` removes all `null` values.
- `nonEmptyMaps` removes all empty maps.
- `nonEmptyStrings` removes all empty strings.
- `nonEmptyIterables` removes all empty iterables.
- `dateAdapter` to format date in `FormState.values`.
- `enumAdapter` to format enum in `FormState.values`.

By default, all options are enabled, except for [nonEmptyIterables].

> To get the unmodified values, use `FormState.rawValues`.

To understand how masks are applied, see [mask_text_input_formatter](https://pub.dev/packages/mask_text_input_formatter) library, also exported by this package.

## FieldKey options

- `.adapter` to format the field value.
- `.unmask` to (un)mask the field value, regardless of the form global options.

```dart
TextFormField(
  key: const Key('age').options(
    unmask: true,
    adapter: (String value) => value?.toInt(),
  ),
),
```

## Validator class

Looking for a way to create validators declaratively? The `Validator` class provides a readable and declarative approach to defining validation rules for your Dart applications.

```dart
TextFormField(
  validator: Validator<String>(
    isRequired: true,
    test: (value) => value.isEmail,
  ),
),
```

For the one-liners, the modifiers allows you to chain your validators.

```dart
TextFormField(
  validator: Validator().required().email(),
),
```

### Customizing

```dart
// You can set a default `requiredText`/`invalidText` for all validators:
Validator.defaultRequiredText = 'This field is required';
Validator.defaultInvalidText = 'This field is invalid';

// You can also modify the errorText of a validator:
Validator.translator = (key, errorText) => errorText; // good for translations

// And disable them all:
Validator.disableOnDebug = true; // only works on debug mode
```

### Modifiers

- `.test(bool Function(T value) test)`
- `.number(bool Function(num value) test)`
- `.datetime(bool Function(DateTime value) test)`
- `.required`
- `.email`
- `.url`
- `.phone`
- `.creditCard`
- `.cpf`
- `.cnpj`
- `.date`
- `.alpha`
- `.numeric`
- `.alphanumeric`
- `.hasAlpha`
- `.hasNumeric`
- `.hasAlphanumeric`
- `.hasUppercase`
- `.hasLowercase`
- `.hasSpecialCharacter`
- `.minLength(int length)`
- `.maxLength(int length)`
- `.minWords(int words)`
- `.maxWords(int words)`
- `.minNumber(num number)`
- `.maxNumber(num number)`
- `.isAfter(DateTime date)`
- `.isBefore(DateTime date)`

## Validators, Sanitizers & Helpers extensions

Formx comes bundled with a set of built-in validators and sanitizers, which you can use to validate and sanitize your form fields.

### `String`

- `.isPhone`
- `.isCpf`
- `.isCnpj`
- `.numeric` (returns the numbers)
- `.alpha` (returns the letters)
- `.alphanumeric` (returns numbers/letters)
- `.hasAlpha`
- `.hasNumeric`
- `.hasAlphanumeric`
- `.hasUppercase`
- `.hasLowercase`
- `.hasSpecialCharacters`
- `.equalsIgnoreCase(String)`

Additionally exports [string_validator](https://pub.dev/packages/string_validator) library. See it for complete list of extensions.

### `Map`

- `.pairs` for getting a list of key-value pairs.
- `.indented` for a map view that indents when printed.
- `.indentedText` for getting an indented text.
- `.deepMap()` for mapping nested maps.
- `.clean()` for values that are `null` or empty string/iterable/map.
- `.cleaned()` for a new map with all `null` or empty values removed.
- `.castJson()` for casting any List as List<Map<String, dynamic>>.
- `.mapJson()` for mapping any jsonList to List<T>.

Deeply recases all your map keys:

- `.camelCase` "camelCase"
- `.constantCase` "CONSTANT_CASE"
- `.sentenceCase` "Sentence case"
- `.snakeCase` "snake_case"
- `.dotCase` "dot.case"
- `.paramCase` "param-case"
- `.pathCase` "path/case"
- `.pascalCase` "PascalCase"
- `.headerCase` "Header-Case"
- `.titleCase` "Title Case"

Additionally exports [recase](https://pub.dev/packages/recase) library. See it for complete list of extensions.

### `List<Widget>`

- `.keepAlive` usually needed for building forms with [PageView.children].
- `.expanded` usually needed for building forms with [Column.children] or [Row.children].

## Contributing

Contributions to formx are welcome! Whether it's bug reports, feature requests, or pull requests, all "forms" of collaboration can help make formx better for everyone.
