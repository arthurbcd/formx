import 'package:flutter/widgets.dart';

/// Extension for [List] to keep alive its children.
extension ListWidgetExtension<T extends Widget> on List<T> {
  /// Wraps each child with a [Expanded] widget.
  List<Widget> expanded() {
    return map((e) => Expanded(child: e)).toList();
  }

  /// Wraps each child with a [_KeepAlive] widget.
  ///
  /// Useful for using [Form] with [PageView] children.
  List<Widget> keepAlive() {
    return map((e) => _KeepAlive(child: e)).toList();
  }
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
