// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

// not exported
class IconLoadingButton extends StatefulWidget {
  const IconLoadingButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });
  final Widget icon;
  final Future<void> Function() onPressed;

  @override
  State<IconLoadingButton> createState() => _IconLoadingButtonState();
}

class _IconLoadingButtonState extends State<IconLoadingButton> {
  bool _loading = false;

  Future<void> press() async {
    // preserve previous size
    _size = context.size;
    try {
      setState(() => _loading = true);
      await widget.onPressed();
    } finally {
      setState(() => _loading = false);
    }
  }

  Size? _size;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox.fromSize(
        size: _size,
        child: Padding(
          padding: EdgeInsets.all(
            switch (_size) {
              null => 8,
              var size => size.shortestSide / 4,
            },
          ),
          child: const CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }

    return IconButton(
      icon: widget.icon,
      onPressed: press,
    );
  }
}
