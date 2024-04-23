import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueAccent,
        body: Center(
          child: SizedBox(
            height: 400,
            width: 300,
            child: CustomFieldExample(),
          ),
        ),
      ),
    ),
  );
}

class CustomFieldExample extends StatelessWidget {
  const CustomFieldExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: () => print(context.formx().values),
      child: Card(
        child: Scaffold(
          body: FormField(
            builder: (field) => field.widget,
          ),
        ),
      ),
    );
  }
}
