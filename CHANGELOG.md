# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.24.1 - Nov 6, 2024
- Added `FileListFormField.initialValue` to saved files.

## 0.24.0 - Nov 6, 2024
- Added `FormFieldState.submit` and `FormFieldState.trySubmit`.
- Added `FormxException.errorMessage` for custom messages.
- Added `errorMessage` to all formx/field `submit`.
- Added `ImageListFormField.url` default decoration.
- Added `FormxDateExtension.hasPassed`.

## 0.23.1 - Nov 5, 2024

- Added singnature parameters to `ImageFormField.url` constructors.
- Added `imageDeleter` & `imageUploader` to `FormxSetup`.
- Simplified `Unmasker` signature.
- Removed `adaptedValue`. Use `toValue`.

## 0.23.0 - Nov 5, 2024
- Added `ImageFormField` fields.
- Added `imagePicker`/`imagesPicker` to `FormxOptions`.

## 0.22.0 - Nov 5, 2024
- Added `Formatter` class.
- Added `FormatterExtension` & many modifiers.
- Simplified `FormxOptions` customizations.
- Improved `.submit` to reach nested fields.
- Improved `.fill` to format text fields.
- Removed `mask_text_input_formatter`.
- Removed `string_validators` dependency.
- Removed `material_file_icon` dependency.
- Removed all deprecations.
- Added test utils.

## 0.21.0 - Oct 28, 2024

- Added `FormxField` and `FormxFieldState` interfaces.
- Major refactor.

## 0.20.4 - Oct 25, 2024

- Added `onChanged` to all `FileFormField`.
- Added `CircularProgressIndicator` to all `FileFormField` when picking/uploading.

## 0.20.2 - Oct 24, 2024

- Fixed exception on `FileFormFeild` deleter.
- Added `XFile.timestampName`.
- Added `XFile.extension`.

## 0.20.1 - Oct 23, 2024

- Fixed `InputDecorator` empty state.

## 0.20.0 - Oct 23, 2024

- Added `Map.pairs` extension.
- Added `Validator.state` getter.
- Added `Validator.testState` extension.
- Added `Validator.equalsField` extension.
- Fixed `FileFormField` deleter call order.
- Optimized formx/field visitors & to not use dependsOn.
- Optimized field widgets that use `InputDecorator` & added hover, empty and focus interactions.
- Optimized `castJson()` and `mapJson()` to work on any Iterable.
- Removed `FormxOptions.defaultTitle` deprecation. Use `FormxSetup.defaultTitle`.

## 0.19.1 - Oct 22, 2024

- Added `FormFieldState.valueAdapted`.
- Fixed `FieldKey.unmask` apply on the entire map instead of just the value. 
- Deprecates `FieldKey` extensions. Use `Key.options` instead.

## 0.19.0 - Oct 20, 2024

- Added `BuildContext.submit`.
- Added `BuildContext.trySubmit`.
- Added `Formx.submit`.
- Added `Formx.trySubmit`.
- Added `FormxStringExtension.initials`.
- Added `FormxFromMapExtension`: `of` & `maybeOf`.
- Added `FormxException`.
- Improve `FileListFormField.url` upload.
- Changes `ListFormField` to use `InputDecoration.suffix` instead of `suffixIcon`, so you can change the suffix icon.

## 0.18.1 - Sep 29, 2024

- Added adapter support to `Form.key`.

## 0.18.0 - Sep 29, 2024

- Removed old deprecations.
- Deprecates `.values` and `.customValues`. Unified to `.toMap()`.
- Added `FormxSetup` class to configure Formx widgets.
- Added `FileFormField` widgets.
- Added `material_file_icon` for `FileFormField`s.
- Added `FormFieldStateExtension.isInitial`.
- Improved `FormState.isInitial` performance.
- Updated examples and README.

## 0.17.2 - Ago 9, 2024

- Added `adapter` extension for `List`.

## 0.17.1 - Ago 5, 2024

- Updated docs & linting.

## 0.17.0 - Jul 31, 2024

- Added `FormxOptions.defaultTitle`. Which applies a default String title for all collection fields.

## 0.16.3 - Jul 19, 2024

- Added `Key.adapt`, shorthand for adding an adapter.

## 0.16.2 - Jul 2, 2024

- Added `FormxOption.enumAdapter` to format enum in `FormState.values`.

## 0.16.1 - Jun 28, 2024

- Improved `FieldKey` class null safety.
- Added `Key.list<T>` extension.
- Added `FieldKey<T>.toMap` adapter.
- Added `FieldKey<T>.toJson` adapter.
- Added `FieldKey<List<T>>.map` adapter.
- Added `FieldKey<Enum>.toName` adapter.
- Added `FieldKey<Enum>.toIndex` adapter.
- Added `FieldKey<String>.toColor` adapter.

## 0.16.0 - Jun 27, 2024

- Added `FieldKey` class and `Key` adapter & modifiers extensions.
- Make `unmask` feature independant of `mask_text_input_formatter` internal state.
- Deprecated all field apis inside `FormState`. Use `context.field` instead.
- Added `DateFormField` widget.
- Added `FormxOption.dateAdapter` to format date in `FormState.values`.

## 0.15.0 - Jun 24, 2024

- Added `FormxOptions` class.
- Added `Formx.options` static variable.
- Added `FormState.rawValues` getter.
- Updated `FormState.values` getter.
- Added `FormState.customValues` method.
- Added `FormState.debug` method.
- Added `context.debugForm` method extension.
- Added `IndentedMap.of` factory constructor.
- Included `mask_text_input_formatter`.
- Updated docs & README.

## 0.14.0 - Jun 21, 2024

- Added `RadioListFormField`.

## 0.13.0 - Jun 19, 2024

- Added `CheckboxFormField`.
- Added `CheckboxListFormField`.
- Bump `string_validator` to 1.1.0.

## 0.12.2 - May 22, 2024

- Added `List.mapJson` extension.

## 0.12.1 - May 22, 2024

- Improved sanitizers and validators.

## 0.11.0 - May 2, 2024

- Added `Validator.translator` for translating error messages.
- Removed `Validator.modifier`.

Thanks to `lizandraquaresma` for the `translator` feature!

## 0.10.4 - Apr 25, 2024

- Added several `Validator` extensions.
- Updated `Map.clean` and added `Map.cleaned` extension.
- Updated `README.md`.
- Updated tests.

## 0.10.1 - Apr 24, 2024

- Refactor: removed all `if case when` as they're not working on flutter web.

## 0.10.0 - Apr 23, 2024

Breaking Update.

- Removed `Formx` widget in favor o `context.formx()`.
- Added new `README.md`.

## 0.9.2 - Mar 25, 2024

- Added `Validator.test` shorthand constructor with positional parameters.
- Added `Map.clean` extension to remove null and empty values.
- Fixed `FormState.setErrorText` that was never reseting on validation.
- Changed `FormState.setErrorText` to accept null to remove the errorText.
- Updated examples and README.

## 0.9.1 - Mar 22, 2024

- Fixed validation priority order.

## 0.9.0 - Mar 21, 2024

- Changed `FormxBuilder` typedef to follow `FormFieldBuilder` signature from Flutter.
- Added `FormxCastExtension` with `cast` and `tryCast`.

## 0.8.0 - Feb 24, 2024

`Validator` was cleaned up and simplified. Now it's a declarative class that can be used to create custom validators.

- Added `validators` property to `Validator` class.
- Removed `Validator.merge` constructor, use `Validator.validators` instead.
- Removed `Validator` modifiers to make it excluively declarative. Use `Validator.validators` instead.

## 0.7.1 - Feb 12, 2024

- Added `Validator` class to simplify the creation of custom validators.
- Added `Validator.modifier` to modify the errorText of a validator.
- Added `FormFieldState.setErrorText` to set `errorText` programmatically.
- Added smart AutovalidateMode to Formx. If null, starts with `AutovalidateMode.disabled` and changes to `AutovalidateMode.always` when validated.
- Added smart operators to FormxState, to get and set fields/nesteds.
- Added reset to FormxState, to reset all fields to their initial values.

## 0.7.0 - Feb 10, 2024

Completely simplification of the library. Now Formx works with any `FormField` Widget! No need to use custom fields anymore. You can use `TextFormField`, `DropdownButtonFormField` or wrap/extend any widget to a `FormField`. Just add a key to it and you are good to go!

- Removed `TextFormxField`, `TextFormxFieldState` and it's extensions.

We realized that using extensions and callback modifiers was misleading users to use only the "new" approach. Which introduces unnecessaries new api's. We want to make it easier for developers to use Formx, as well as for others to understand it.

- Removed `errorTextModifier`, `fieldModifier`, `fieldWrapper`, `decorator`, `fieldWrapper`, `fieldModifier` and `valueModifier` callbacks.

Formx is now a single widget that manages fields and their states.

## 0.6.1 - Jan 30, 2024

- Changes `TextFormxField` tag to named parameter.
- Adds `FormxState.field` to get a field value by tag, no matter how deep it is.
- Adds `Formx.builder` parameter for context and state access.
- Added `TextFormxFieldState.hasInteractedByUser`, same as `FormFieldState.hasInteractedByUser`.
- Removed `Formx.at`.
- Changed `decorationModifier` to `decorator`.

## 0.5.1 - Jan 23, 2024

- Added `Formx.disableValidatorsOnDebugMode` to disable validators on debug mode.
- Added `suffixIcon` extension to `TextFormxFieldModifiers`.
- Added `prefixIcon` extension to `FormxFieldModifiers`.

## 0.5.0 - Nov 13, 2023

- Added `FormxField` and `FormxFieldState` abstract interfaces.
  - Updated [FormxState.validate] you can validate by tag, tags, key or keys.
  - Added [FormxState.setValue].
  - Added [FormxState.didChange].
- Removed fieldKey param, use key directly with `FormxFieldState` for GlobalKey type.
- Removed FormxException. AssertErrors will be thrown instead, for best practices.
- Changes `TextFormxFieldModifiers.obscure`, which now also makes the field required.
- Added `complex_structure` example.
- Added `page_view` example.

## 0.4.0 - Nov 07, 2023

- Adds [Formx.valueModifier] and updates [FormxState.form] getter.
- Adds [FormxState.save] and [Formx.onSaved] callback.
- Adds [FormxState.reset].
- Adds [FormxState.isValid].
- Adds [FormxState.hasError].
- Changes `onWidget` to `fieldWrapper`.
- Changes `onField` to `fieldModifier`.
- Changes `onDecoration` to `decorationModifier`.
- Changes `onErrorText` to `errorTextModifier`.

- Updates in code were made to better follow Effective Dart style and also improve developer experience:
  - Adds `all_lint_rules.yaml`.
  - Updates `analysis_options` for stricter lints.
  - Updates CHANGELOG style.

## 0.3.13 - Oct 23, 2023

- Bump to Flutter sdk 3.13.0.
- Adds support to TextFormField in sdk 3.13.0.
- Adds `undoController` to TextFormxField.
- Adds `onAppPrivateCommand` to TextFormxField.
- Adds `cursorOpacityAnimates` to TextFormxField.
- Adds `selectionHeightStyle` to TextFormxField.
- Adds `selectionWidthStyle` to TextFormxField.
- Adds `dragStartBehavior` to TextFormxField.
- Adds `contentInsertionConfiguration` to TextFormxField.
- Adds `clipBehavior` to TextFormxField.
- Adds `scribbleEnabled` to TextFormxField.
- Adds `canRequestFocus` to TextFormxField.

## 0.3.10 - Oct 23, 2023

- Bump to Flutter sdk 3.10.0.
- Adds support to TextFormField in sdk 3.10.0.
- Adds `spellCheckConfiguration` to TextFormxField.
- Adds `magnifierConfiguration` to TextFormxField.

## 0.3.7 - Oct 23, 2023

- Bump to Flutter sdk 3.7.0.
- Adds support to TextFormField in sdk 3.7.0.
- Adds `contextMenuBuilder` to TextFormxField.
- Adds `onTapOutside` to TextFormxField.

## 0.3.0 - Oct 23, 2023

- Adds support to TextFormField in sdk 3.0.0
- Adds FormxState.fill() method to autofill all nested fields.
- Adds Formx.at(context) and `maybeAt` to access state below context.
- Adds `Formx.errorTexts` to access all `errorTexts` by field `tag`.
- Updates `FormxException` with errorTexts parameter.

## 0.1.5 - Sep 26, 2023

- Fixes initialValue conflict with TextEditingController.
- Fixes unnecessary didChange on setField.

## 0.1.1 - Sep 23, 2023

- Fixes minor conflict with [onField].

## 0.1.0 - Sep 22, 2023

- Initial pre-release.
