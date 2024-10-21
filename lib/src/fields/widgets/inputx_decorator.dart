// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

// not exported
class InputxDecorator<T> extends StatelessWidget {
  const InputxDecorator({
    required this.state,
    required this.decoration,
    required this.child,
    this.suffix,
    this.suffixIcon = const Icon(Icons.upload_file),
    super.key,
  });
  final InputDecoration? decoration;
  final FormFieldState<T> state;
  final Widget Function(Widget icon)? suffix;
  final Widget suffixIcon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final decoration = this.decoration ?? const InputDecoration();

    return InputDecorator(
      decoration: decoration.copyWith(
        errorText: state.errorText,
        suffix: decoration.suffix ??
            suffix?.call(decoration.suffixIcon ?? suffixIcon),
      ),
      child: child,
    );
  }
}
