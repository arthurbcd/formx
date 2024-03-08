import 'package:flutter/widgets.dart';

/// Extension for [List] to keep alive its children.
extension ListAliveExtension<T extends Widget> on List<T> {
  /// Wraps each child with a [_KeepAlive] widget.
  ///
  /// Useful for [PageView] children.
  List<Widget> keepAlive() {
    return map((e) => _KeepAlive(child: e)).toList();
  }
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => __KeepAliveState();
}

class __KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
