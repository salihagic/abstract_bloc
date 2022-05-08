import 'package:flutter/material.dart';

class AbstractConfiguration extends InheritedWidget {
  final Widget Function(void Function() onInit)? abstractItemErrorBuilder;
  final Widget Function(void Function() onInit)? abstractItemNoDataBuilder;

  final Widget Function(void Function() onInit)? abstractListErrorBuilder;
  final Widget Function(void Function() onInit)? abstractListNoDataBuilder;

  AbstractConfiguration({
    Key? key,
    required Widget child,
    this.abstractItemErrorBuilder,
    this.abstractItemNoDataBuilder,
    this.abstractListErrorBuilder,
    this.abstractListNoDataBuilder,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static AbstractConfiguration? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AbstractConfiguration>();
  }
}
