import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget({
    required this.onRestart,
    required this.child,
    super.key,
  });

  final Widget child;
  final void Function() onRestart;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      widget.onRestart.call();
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
        key: key,
        child: widget.child,
      );
}
