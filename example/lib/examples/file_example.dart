import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  Formx.setup = FormxSetup(
    filePicker: (state) async {
      final result = await FilePicker.platform.pickFiles();

      return result?.xFiles.firstOrNull;
    },
    filesPicker: (state) async {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);

      return result?.xFiles ?? [];
    },
    fileUploader: (file, path) async {
      await Future.delayed(const Duration(seconds: 2));

      /// Simulando o upload do arquivo.
      return '${file.name}/$path';
    },
    fileDeleter: (url) async {
      print('Deleting: $url');
    },
  );
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 400,
            width: 600,
            child: FileFormExample(),
          ),
        ),
      ),
    ),
  );
}

class FileFormExample extends StatelessWidget {
  const FileFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      onChanged: context.debugForm,
      child: Column(
        children: [
          FileFormField.url(
            key: const Key('imageUrl'),
            validator: Validator().required(),
          ),
          FileListFormField.url(
            key: const Key('imageUrls'),
            path: (_) {
              const userId = '1';
              final levelId = DateTime.now().millisecondsSinceEpoch;
              return 'users/$userId/levels/$levelId.jpg';
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.formx().validate();
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }
}
