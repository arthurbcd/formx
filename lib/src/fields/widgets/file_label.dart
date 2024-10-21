// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:material_file_icon/material_file_icon.dart';

// not exported
class FileLabel extends StatelessWidget {
  const FileLabel(this.file, {super.key});
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MFThumb(file),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                file.name,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
