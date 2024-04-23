import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

class FlutterFormExample extends StatefulWidget {
  const FlutterFormExample({super.key});

  @override
  State<FlutterFormExample> createState() => _FlutterFormExampleState();
}

class _FlutterFormExampleState extends State<FlutterFormExample> {
  final formKey = GlobalKey<FormState>();
  // Root
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Address
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final zipController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    streetController.dispose();
    numberController.dispose();
    zipController.dispose();
    super.dispose();
  }

  Future<void> fill(Map<String, dynamic> map) async {
    nameController.text = map['name'] as String;
    emailController.text = map['email'] as String;

    final address = map['address'] as Map<String, dynamic>;
    streetController.text = address['street'] as String;
    numberController.text = address['number'] as String;
    zipController.text = address['zip'] as String;
  }

  Future<void> submit() async {
    if (formKey.currentState?.validate() ?? false) {
      final map = <String, dynamic>{
        'name': nameController.text,
        'email': emailController.text,
        'address': {
          'street': streetController.text,
          'number': numberController.text,
          'zip': zipController.text,
        },
      };
      print('Form is valid: $map');
    } else {
      // Showing error texts requires many field GlobalKey's,
      // that's enough boilerplate already.
      //
      final errorTexts = {};
      print('Form is invalid: $errorTexts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('USER'),
              TextFormField(
                key: const Key('name'),
                controller: nameController,
              ),
              TextFormField(
                key: const Key('email'),
                controller: emailController,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Address:'),
                  TextFormField(
                    key: const Key('street'),
                    controller: streetController,
                  ),
                  TextFormField(
                    key: const Key('number'),
                    controller: numberController,
                  ),
                  TextFormField(
                    key: const Key('zip'),
                    controller: zipController,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class User {
  User({
    this.name,
    this.email,
    this.address,
  });

  String? name;
  String? email;
  Address? address;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'address': address?.toMap(),
    };
  }
}

class Address {
  Address({
    this.street,
    this.number,
    this.zip,
  });

  String? street;
  String? number;
  String? zip;

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'number': number,
      'zip': zip,
    };
  }
}

class FormxExample extends StatelessWidget {
  const FormxExample({super.key});

  Future<void> fill(BuildContext context, Map<String, dynamic> map) async {
    context.formx().fill(map);
  }

  Future<void> submit(BuildContext context) async {
    final state = context.formx();

    if (state.validate()) {
      print('Form is valid: ${state.values}');
    } else {
      print('Form is invalid: ${state.errorTexts}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('USER'),
              TextFormField(
                key: const Key('name'),
              ),
              TextFormField(
                key: const Key('email'),
              ),
              Form(
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
                    TextFormField(
                      key: const Key('zip'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => submit(context),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
