# Formx

`formx` is a dynamic and robust Flutter package for building and managing forms. With an emphasis on ease of use and customizability, `formx` provides a powerful way to handle form inputs, validations, and submissions without the boilerplate.

## Key Features

- **Live State Management**: Tracks changes to form fields in real-time, providing immediate feedback and interaction capabilities.
- **Initial Values Setup**: Initialize form fields with default values, making edit forms and persisted states a breeze.
- **Nested Forms Support**: Easily manage complex forms with nested fields, allowing for structured data input and validation.
- **Declarative Validation**: Enforces field requirements and custom validation logic, ensuring data integrity before submission.

## Getting Started

To integrate `formx` into your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  formx: ^latest_version
```

This package was made with Flutter in mind, and focus on having the simplest api as possible:

### Form api

```dart
  Form(
    child: Column(
      children: [
        TextFormField(
          controller: nameController,
          onChanged: print,
        ),
        TextFormField(
          controller: emailController,
          onChangd: print,
        ),
      ],
    ),
  )
```

### Formx api

```dart
  Formx(
    onChanged: print,
    child: const Column(
      children: [
        TextFormField(
          key: const Key('name'),
        ),
        TextFormField(
          key: const Key('email'),
        ),
      ],
    ),
  );
```

## Code example

```dart
Widget build(BuildContext context) {
    return Scaffold(
      body: Formx(
        // Check your console and type, it's alive!
        onChanged: print,

        // Optional initial values for all fields. Tip: Model.toMap().
        initialValues: const {
          'name': 'Big',
          'email': 'some@email',
          'address': {
            'street': 'Sesame Street',
            'number': '42',
          },
        },

        // Builder shortcut to access the form state.
        builder: (state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('USER'),

                // Just add a key to your fields and you're good to go.
                TextFormField(
                  key: const Key('name'),
                ),
                TextFormField(
                  key: const Key('email'),
                ),

                /// You can nest [Formx] to create complex structures.
                Formx(
                  key: const Key('address'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Address:'),
                      TextFormField(
                        key: const Key('street'),
                      ),
                      TextFormField(
                        key: const Key('number'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  // reset to initial values.
                  state.reset();
                },
                child: const Icon(Icons.refresh),
              ),
              FloatingActionButton(
                onPressed: () {
                  // programatically fill all fields.
                  state.fill({
                    'name': 'Biggy',
                    'email': 'z@z',
                    'address': {
                      'street': 'Lalala Street',
                      'number': '43',
                    },
                  });

                  // or the shorthand:
                  state['name'] = 'Biggy';
                  state['email'] = 'z@z';
                  state['address'] = {
                    'street': 'Lalala Street',
                    'number': '43',
                  };
                },
                child: const Icon(Icons.edit),
              ),
              FloatingActionButton(
                onPressed: () {
                  // Validate all fields. Just like `Form.validate()`.
                  final isValid = state.validate();
                  print('isValid: $isValid');

                  // You can also validate a single field.
                  final isEmailValid = state.validate(['email']);
                  print('isEmailValid: $isEmailValid');
                },
                child: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ),
    );
  }
```

## Contributing

Contributions to formx are welcome! Whether it's bug reports, feature requests, or pull requests, all forms of collaboration can help make formx better for everyone.
