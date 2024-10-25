// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Not exported.
class InputxDecorator extends StatefulWidget {
  const InputxDecorator({
    super.key,
    required this.decoration,
    required this.child,
    required this.isTextEmpty,
    this.suffix,
  });

  final InputDecoration? decoration;
  final bool isTextEmpty;
  final Widget? suffix;
  final Widget? child;

  @override
  State<InputxDecorator> createState() => _InputxDecoratorState();
}

class _InputxDecoratorState extends State<InputxDecorator> {
  var _hasFocus = false;
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration ?? const InputDecoration();
    final state = context.findAncestorStateOfType<FormFieldState>()!;

    return Focus(
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: InputDecorator(
          isFocused: _hasFocus,
          isHovering: _hovering,
          isEmpty: widget.isTextEmpty,
          decoration: decoration.copyWith(
            errorText: decoration.errorText ?? state.errorText,
            suffix: decoration.suffix ?? widget.suffix,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
