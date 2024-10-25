// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:material_file_icon/material_file_icon.dart';

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
          FileThumb(file),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                file?.name ?? '',
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FileThumb extends StatefulWidget {
  /// Creates a widget that shows a thumbnail of a file.
  const FileThumb(
    this.file, {
    super.key,
    this.url,
    this.size,
    this.color,
    this.placeholder = const Icon(Icons.insert_drive_file),
  });
  final XFile? file;
  final String? url;
  final double? size;
  final Color? color;
  final Widget placeholder;

  @override
  State<FileThumb> createState() => _FileThumbState();
}

class _FileThumbState extends State<FileThumb> {
  late final _future = widget.file?.readAsBytes();

  Widget get _fileIcon => MFIcon(
        widget.file?.name ?? '',
        size: widget.size,
        color: widget.color,
        placeholder: widget.placeholder,
      );

  @override
  Widget build(BuildContext context) {
    if (widget.file == null && widget.url != null) {
      return Image.network(widget.url!);
    }

    return SizedBox.square(
      dimension: 20,
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _fileIcon;

          return Image.memory(
            snapshot.data!,
            errorBuilder: (_, e, s) => _fileIcon,
          );
        },
      ),
    );
  }
}
