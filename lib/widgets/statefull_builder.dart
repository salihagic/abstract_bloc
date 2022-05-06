import 'package:flutter/material.dart';

class StatefullBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final void Function(BuildContext context)? initState;

  const StatefullBuilder({
    Key? key,
    required this.builder,
    this.initState,
  }) : super(key: key);

  @override
  _StatefullBuilderState createState() => _StatefullBuilderState();
}

class _StatefullBuilderState extends State<StatefullBuilder> {
  @override
  void initState() {
    widget.initState?.call(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
