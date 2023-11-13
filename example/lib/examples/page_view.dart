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
            child: PageViewExample(),
          ),
        ),
      ),
    ),
  );
}

class PageViewExample extends StatelessWidget {
  const PageViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Formx(
      onChanged: print,
      onSubmitted: print,
      fieldModifier: (tag, field) {
        // makes all fields required
        return field.required();
      },
      decorationModifier: (tag, decoration) {
        return decoration?.copyWith(labelText: tag);
      },
      child: Card(
        child: PageView(
          controller: PageController(keepPage: true),
          children: const [
            Page1(),
            Page2(),
            Page3(),
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormxField('name', onSaved: print),
          TextFormxField('email', onSaved: print),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This is a convenient [BuildContext] extension.
          context.nextPage();
        },
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormxField('street', onSaved: print),
          TextFormxField('number', onSaved: print),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: context.nextPage),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormxField('school', onSaved: print),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This is a convenient [BuildContext] extension.
          Formx.of(context).validate();
        },
      ),
    );
  }
}

extension on BuildContext {
  /// The [PageController] of the nearest [PageView].
  PageController? get pageController {
    return findAncestorWidgetOfExactType<PageView>()?.controller;
  }

  /// Sintax sugar for [PageController.previousPage].
  void nextPage() {
    pageController?.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
