// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Not exported.
class InputxDecorator extends StatefulWidget {
  const InputxDecorator({
    super.key,
    required this.autofocus,
    required this.focusNode,
    required this.decoration,
    required this.child,
    this.suffix,
  });

  final bool autofocus;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
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
    final enabled = state.widget.enabled;

    return Focus(
      autofocus: enabled && widget.autofocus,
      focusNode: widget.focusNode,
      onFocusChange:
          enabled ? (hasFocus) => setState(() => _hasFocus = hasFocus) : null,
      child: MouseRegion(
        onEnter: enabled ? (_) => setState(() => _hovering = true) : null,
        onExit: enabled ? (_) => setState(() => _hovering = false) : null,
        child: InputDecorator(
          isFocused: _hasFocus && enabled,
          isHovering: _hovering && enabled,
          decoration: decoration.copyWith(
            enabled: enabled,
            errorText: decoration.errorText ?? state.errorText,
            suffix: decoration.suffix ?? widget.suffix,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
