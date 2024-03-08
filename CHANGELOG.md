# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.7.0

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
