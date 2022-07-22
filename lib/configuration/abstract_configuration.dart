import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

class AbstractConfiguration extends InheritedWidget {
  final Widget Function(BuildContext context)? loaderBuilder;
  final Widget Function(BuildContext context)? smallLoaderBuilder;
  final Widget Function(BuildContext context, void Function() onTap)?
      cachedDataWarningIconBuilder;
  final Widget Function(
          BuildContext context, void Function(BuildContext context)? onReload)?
      cachedDataWarningDialogBuilder;

  final Widget Function(BuildContext context, void Function() onInit)?
      abstractFormErrorBuilder;

  final Widget Function(BuildContext context, void Function() onInit)?
      abstractItemErrorBuilder;
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractItemNoDataBuilder;

  final Widget Function(BuildContext context, void Function() onInit)?
      abstractListErrorBuilder;
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractListNoDataBuilder;

  final AbstractTranslations translations;

  AbstractConfiguration({
    Key? key,
    required Widget child,
    this.loaderBuilder,
    this.smallLoaderBuilder,
    this.cachedDataWarningIconBuilder,
    this.cachedDataWarningDialogBuilder,
    this.abstractFormErrorBuilder,
    this.abstractItemErrorBuilder,
    this.abstractItemNoDataBuilder,
    this.abstractListErrorBuilder,
    this.abstractListNoDataBuilder,
    this.translations = const AbstractTranslations(),
    PaginationConfiguration? paginationConfiguration,
  }) : super(
          key: key,
          child: child,
        ) {
    if (paginationConfiguration != null) {
      Pagination.configuration = paginationConfiguration;
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static AbstractConfiguration? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AbstractConfiguration>();
  }
}
