# Formx

`formx` is a dynamic and robust Flutter package for building and managing forms. With an emphasis on ease of use and customizability, `formx` provides a powerful way to handle form inputs, validations, and submissions without the boilerplate.

## Key Features

- **Live State Management**: Tracks changes to form fields in real-time, providing immediate feedback and interaction capabilities.
- **Built-in Validation**: Enforces field requirements and custom validation logic, ensuring data integrity before submission.
- **Nested Forms Support**: Easily manage complex forms with nested fields, allowing for structured data input and validation.
- **Initial Values Setup**: Initialize form fields with default values, making edit forms and persisted states a breeze.
- **Custom Field Modifiers**: Tailor the behavior of fields with custom modifiers, applying conditional logic or enhancing functionality.
- **Flexible Field Wrappers**: Wrap fields with custom widgets for consistent styling or layout requirements across the form.
- **Decoration Customization**: Modify the `InputDecoration` for each field to align with your app's theme and user experience design.
- **Error Handling**: Customize the display of error messages with the possibility to use internationalization (i18n) for multi-language support.
- **Extensible API**: Extend the base functionality with your own widgets and logic, maintaining a seamless integration with the form system.

## Getting Started

To integrate `formx` into your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  formx: ^latest_version
```

This package was made with Flutter in mind, and focus on having the simplest api as possible:

```dart
// For Form() just add change it to Formx()
 Form(...) -> Formx(...)

 // For TextFormField, add the `x` and your form `tag`. 
 // Your form value will be keyed to this tag.
 TextFormField(...) -> TextFormxField(tag: 'name', ...)

 // This also applies to states:
 final formxKey = GlobalKey<FormxState>();
```

## Code example

```dart
    return Scaffold(
      body: Formx(
        // Check your console and type, it's alive!
        onChanged: print,

        // Called when all fields are valid and submitted via Enter key or .submit().
        onSubmitted: (state) {
          if (state.validate()) {
            print('all valid and ready to go: $form');
          }
        },

        // Optional initial values for all fields. Tip: Model.toMap() or autofill.
        initialValues: const {
          'name': 'Big',
          'email': '',
          'address': {
            'street': 'Sesame Street',
            'number': 42, // will be stringified
          }
        },

        // Allows you to modify the field before it's built.
        fieldModifier: (tag, field) {
          // `.required()` is an extension. See [TextFormxFieldModifiers]
          return tag == 'name' ? field.required() : field;
        },

        // A wrapper that will be applied to all fields. DRY!
        fieldWrapper: (tag, widget) => Padding(padding: padding, child: widget),

        // [InputDecoration] callback. Tip: scope your form themes!
        decorator: (tag, decoration) {
          return decoration?.copyWith(
            labelText: tag,
            border: const OutlineInputBorder(),
            constraints: const BoxConstraints(maxWidth: 300),
          );
        },

        // [TextFormField.validator] errorText callback. Tip: nice for i18n key.
        errorTextModifier: (tag, errorText) {
          if (tag == 'email') return errorText;
          return '$errorText.$tag';
        },

        // Your creativity is the limit. Manage your fields however you want.
        // Just make sure there's a [Formx] above them.
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('USER'),

              // Same as TextFormField but copiable and const.
              const TextFormxField(tag: 'name'),

              /// Stack validators through extensions modifiers.
              const TextFormxField(tag: 'email')
                  .validate((value) => value.isNotEmpty) // same as .required()
                  .validate((value) => value.contains('form'))
                  .validate((value) => value.contains('x'), 'Missing x')
                  .validate((value) => value.contains('@'), 'Not an email'),

              /// Simple as one line.
              const TextFormxField(tag: 'password'), // adds suffixIcon

              /// Nested fields too!?
              Formx(
                tag: 'address',

                /// and value modifier? Yes!
                valueModifier: (tag, value) {
                  if (tag == 'number') {
                    return int.tryParse(value);
                  }
                  return value;
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Address:'),

                    // Use copyWith to create your own extensions!
                    const TextFormxField(tag: 'street').copyWith(),

                    // Like this cool num validator.
                    const TextFormxField(tag: 'number').validateNum((n) => n < 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can use formxKey or just visit the state at context.
          final state = Formx.at(context); // or .of() for above.

          // Validate all fields. Just like `Form.validate()`.
          final isValid = state.validate();

          // you can also validate specific fields with:
          // validate(tag: , tags: , key: , keys: ,);

          if (isValid) {
            Map<String, dynamic> form = state.form;
            print('all valid and ready to go: $form');
          } else {
            print('invalid fields:');
            state.errorTexts.forEach((tag, errorText) {
              print('$tag: $errorText');
            });
          }
        },
        child: const Icon(Icons.check),
      ),
    );
```

## Migrating from Vanilla Flutter Form and TextFormField

### Example with Flutter api

```dart
  Form(
    child: Column(
      children: [
        TextFormField(
          onChanged: (value) => print('name'),
          decoration: InputDecoration(labelText: 'name'),
        ),
        TextFormField(
          onChangd: (value) => print('email'),
          decoration: InputDecoration(labelText: 'email'),
        ),
      ],
    ),
  )
```

### Example with Formx api

```dart
  Formx(
    onChanged: (form) => print(form),
    decorationModifier: (tag, decoration) => decoration?.copyWith(labelText: tag),
    child: const Column(
      children: [
        TextFormxField('name'),
        TextFormxField('email'),
      ],
    ),
  );
```

## Contributing

Contributions to formx are welcome! Whether it's bug reports, feature requests, or pull requests, all forms of collaboration can help make formx better for everyone.
