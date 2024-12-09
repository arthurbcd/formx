// ignore_for_file: public_member_api_docs

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

// not exported
class FileLabel extends StatelessWidget {
  const FileLabel(this.file, {this.url, super.key});
  final XFile? file;
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (file == null && url == null) return const SizedBox();

    return SizedBox(
      width: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 20,
            child: _FileThumb(file, url: url),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                file?.name ?? url?.split('/').last ?? url ?? '',
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileThumb extends StatefulWidget {
  const _FileThumb(this.file, {this.url});
  final XFile? file;
  final String? url;

  @override
  State<_FileThumb> createState() => _FileThumbState();
}

class _FileThumbState extends State<_FileThumb> {
  late final _future = widget.file?.readAsBytes();
  Widget get _fileIcon => const Icon(Icons.insert_drive_file);

  @override
  Widget build(BuildContext context) {
    if (widget.file == null && widget.url != null) {
      return Image.network(widget.url!);
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _fileIcon;

        return Image.memory(
          snapshot.data!,
          errorBuilder: (_, e, s) => _fileIcon,
        );
      },
    );
  }
}
