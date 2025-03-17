import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// A reusable stateful widget that allows for initialization logic
/// through a builder function and an optional initState callback.
class AbstractStatefulBuilder extends StatefulWidget {
  /// A builder function that returns a widget based on the current context.
  final Widget Function(BuildContext context) builder;

  /// An optional callback that runs during the initialization phase of
  /// the stateful widget.
  final void Function(BuildContext context)? initState;

  const AbstractStatefulBuilder({
    super.key, // Use Key? instead of super.key for clarity
    required this.builder,
    this.initState,
  }); // Pass the key to the superclass constructor

  @override
  State<AbstractStatefulBuilder> createState() =>
      _AbstractStatefulBuilderState();
}

class _AbstractStatefulBuilderState extends State<AbstractStatefulBuilder> {
  @override
  void initState() {
    super.initState();
    // Call the optional initState method if provided
    widget.initState?.call(context);
  }

  @override
  Widget build(BuildContext context) {
    // Return the widget built by the provided builder function
    return widget.builder(context);
  }
}
