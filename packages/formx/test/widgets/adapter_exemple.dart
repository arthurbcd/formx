import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

class AdapterExample extends StatelessWidget {
  const AdapterExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: _Example(),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: const Key('adapter'),
      child: Column(
        children: [
          TextFormField(
            // ✅ String == String
            key: const Key('text').options(
              adapter: (String value) => value.toUpperCase(),
            ),
            initialValue: 'John Doe',
          ),
          DateFormxField(
            // ❌ DateTime != String
            key: const Key('date').options(
              adapter: (String value) => value.toUpperCase(),
            ),
            initialValue: DateTime.now(),
          ),
        ],
      ),
    );
  }
}
