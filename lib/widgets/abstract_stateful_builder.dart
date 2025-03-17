import 'package:flutter/material.dart';

class AbstractStatefulBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final void Function(BuildContext context)? initState;

  const AbstractStatefulBuilder({
    super.key,
    required this.builder,
    this.initState,
  });

  @override
  State<AbstractStatefulBuilder> createState() =>
      _AbstractStatefulBuilderState();
}

class _AbstractStatefulBuilderState extends State<AbstractStatefulBuilder> {
  @override
  void initState() {
    super.initState();

    widget.initState?.call(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
