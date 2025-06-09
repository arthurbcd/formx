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

class LizStore {
  final form = Formx();

  Key key(String key) => form.key(key);
}

class PageViewExample extends StatelessWidget {
  const PageViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    // print(context.formx.indented);
    return Card(
      child: Scaffold(
        body: PageView(
          controller: PageController(keepPage: true),
          children: const [
            Page1(),
            Page2(),
            Page3(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.filter_list),
              label: 'Page 1',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restore),
              label: 'Page 2',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Page 3',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                form.values = {'school': 'ESCS', 'name': 'Arthur'};
              case 1:
                form.reset();
              case 2:
                context.pageController?.jumpToPage(2);
            }
          },
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: form.key('street'),
            validator: Validator().required(),
            decoration: const InputDecoration(
              labelText: 'Street',
            ),
          ),
          TextFormField(
            key: form.key('number'),
            validator: Validator().required().numeric(),
            decoration: const InputDecoration(
              labelText: 'Number',
            ),
          ),
          TextFormField(
            key: form.key('phone'),
            inputFormatters: Formatter().phone.br(),
            decoration: const InputDecoration(
              labelText: 'Phone',
            ),
          ),
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
              key: form.key('school'),
              validator: Validator().required(),
              decoration: const InputDecoration(
                labelText: 'School',
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This is a convenient [BuildContext] extension.
          if (form.validate()) {
            print(form.values);
          }
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
