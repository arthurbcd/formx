# Formx

<!-- markdownlint-disable no-inline-html -->
<p align="center">
  <img src="https://raw.githubusercontent.com/arthurbcd/formx/6f4c8fec8c107c7c3d091855bd8404541b9c04b6/packages/formx/image-1.png" alt="Image 1" height="600"/>
  <img src="https://raw.githubusercontent.com/arthurbcd/formx/6f4c8fec8c107c7c3d091855bd8404541b9c04b6/packages/formx/image-2.png" alt="Image 2" height="600"/>
</p>
<!-- markdownlint-enable no-inline-html -->

## Acessing the state

`BuildContext.formx(String key)` automatically retrieves `FormState` by key value.

```dart
// specify the form key:
final addressState = context.formx('address'); 

if (addressState.validate()) {
  final map = addressState.toMap();
  addressState.save();
  // do your logic

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
- `image/filePicker` to pick a file in `FormField<XFile>` fields.
- `image/filesPicker` to pick a file in `FormField<List<XFile>>` fields.
- `image/fileUploader` to upload a file in `FormField<XFile>` fields.
- `image/fileDeleter` to delete a file in `FormField<XFile>` fields.

## FormxOptions

You can use `Formx.options` to modify `FormState.values` output.

- `trim` removes leading and trailing whitespaces.
- `unmask` removes all [MaskedInputFormatter] masks.
- `nonNull` removes all `null` values.
- `nonEmptyMaps` removes all empty maps.
- `nonEmptyStrings` removes all empty strings.
- `nonEmptyIterables` removes all empty iterables.

By default, all options are enabled, except for [nonEmptyIterables].

> To get the unmodified values, use `FormState.rawValues`.

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

Looking for a way to create validators declaratively? `Validator` class provides a readable and declarative approach to defining validation rules for your Dart applications.

```dart
TextFormField(
  validator: Validator<String>(
    required: true,
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

// In case you need to temporarily disable all validators:
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

### `Iterable`

- `.castJson()` for casting any List as List<Map<String, dynamic>>.
- `.mapJson()` for mapping any jsonList to List<T>.
- `.orderedBy(R selector(T), {bool ascending})` for ordering.

### `Map`

- `.pairs` for getting a list of key-value pairs.
- `.indented` for a map view that indents when printed.
- `.indentedText` for getting an indented text.
- `.deepMap()` for mapping nested maps.
- `.clean()` for values that are `null` or empty string/iterable/map.
- `.cleaned()` for a new map with all `null` or empty values removed.

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

## Experimental Formx Api

Control your form using `Formx` class.

This is a complete replacement of the `Form` and `FormState` api.

`Formx` syncs directly with any `FormFieldState`. State is restored, so you don't need to worry about keeping the widget tree alive. You can even use it before the widget tree is built/rendered.

You can perform any validation or retrieval:
- `Formx.validate()`
- `Formx.values` (also a setter)
- `Formx.setValue`.

```dart
final form = Formx(
  initialValues: {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'street': '123 Main',
    'number': '456',
    'phone': '91982224111',
    'address': {
      'street': '123 Main',
      'number': '456',
    },
    'nested': {
      'password': '121212',
      'confirm': '343434',
    },
    'nested2': {
      'password': '1111111',
      'confirm': '999999',
    },
    'school': 'Equipe',
  },
);
```

Connect it simply with `Formx.key`:

```dart
TextFormField(
  key: form.key('name'),
  validator: Validator().required(),
  decoration: const InputDecoration(
    labelText: 'Name',
  ),
),
TextFormField(
  key: form.key('email'),
  validator: Validator().required().email(),
  decoration: const InputDecoration(
    labelText: 'Email',
  ),
),
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    TextFormField(key: form.key('nested.password')),
    TextFormField(key: form.key('nested.confirm')),
  ],
),
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    TextFormField(key: form.key('nested2.password')),
    TextFormField(key: form.key('nested2.confirm')),
  ],
),
```

## Contributing

Contributions to formx are welcome! Whether it's bug reports, feature requests, or pull requests, all "forms" of collaboration can help make formx better for everyone.
