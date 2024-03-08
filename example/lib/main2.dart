import 'dart:convert';

import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Material(
        child: UserForm(
          onChanged: print,
        ),
      ),
    ),
  );
}

class UserForm extends StatefulWidget {
  const UserForm({super.key, required this.onChanged});
  final void Function(Map<String, String> texts) onChanged;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final formController = {
    'name': TextEditingController(),
    'nickname': TextEditingController(),
    'email': TextEditingController(),
    'age': TextEditingController(),
  };

  var obscure = false;

  void toggleObscure() {
    setState(() => obscure = !obscure);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: () {
        widget.onChanged(formController.texts);
      },
      child: Column(
        children: [
          for (var e in formController.entries)
            TextFormField(
              controller: e.value,
              decoration: InputDecoration(
                labelText: 'form.label.${e.key}',
              ),
            ),
        ],
      ),
    );
  }
}

void log(Object? value) {
  print(const JsonEncoder.withIndent('  ').convert(value));
}

extension FormControllerExtension on Map<String, TextEditingController> {
  Map<String, String> get texts {
    return map((key, value) => MapEntry(key, value.text));
  }
}
