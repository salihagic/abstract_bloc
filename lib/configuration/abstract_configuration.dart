import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

// Defines an inherited widget that provides configuration options for abstract widgets
class AbstractConfiguration extends InheritedWidget {
  // Optional builder for a custom loading widget
  final Widget Function(BuildContext context)? loaderBuilder;

  // Optional builder for a loading widget when cached data is being used
  final Widget Function(BuildContext context)? cachedDataLoaderBuilder;

  // Optional builder for a warning icon related to cached data, with an onTap callback
  final Widget Function(BuildContext context, void Function() onTap)?
      cachedDataWarningIconBuilder;

  // Optional builder for a dialog warning about cached data, with an onReload callback
  final Widget Function(
          BuildContext context, void Function(BuildContext context)? onReload)?
      cachedDataWarningDialogBuilder;

  // Optional builder for displaying form-related errors, with an onInit callback
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractFormErrorBuilder;

  // Optional builder for displaying item-specific errors, with an onInit callback
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractItemErrorBuilder;

  // Optional builder for displaying a "no data" state for an item, with an onInit callback
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractItemNoDataBuilder;

  // Optional builder for displaying list-related errors, with an onInit callback
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractListErrorBuilder;

  // Optional builder for displaying a "no data" state for a list, with an onInit callback
  final Widget Function(BuildContext context, void Function() onInit)?
      abstractListNoDataBuilder;

  // Stores translation configurations for the abstract widgets
  final AbstractTranslations translations;

  // Constructor for AbstractConfiguration
  AbstractConfiguration({
    super.key, // Unique key for the widget, inherited from InheritedWidget
    required super.child, // The widget below this one in the tree, required by InheritedWidget
    this.loaderBuilder, // Custom loader widget builder
    this.cachedDataLoaderBuilder, // Custom cached data loader widget builder
    this.cachedDataWarningIconBuilder, // Custom cached data warning icon builder
    this.cachedDataWarningDialogBuilder, // Custom cached data warning dialog builder
    this.abstractFormErrorBuilder, // Custom form error widget builder
    this.abstractItemErrorBuilder, // Custom item error widget builder
    this.abstractItemNoDataBuilder, // Custom item "no data" widget builder
    this.abstractListErrorBuilder, // Custom list error widget builder
    this.abstractListNoDataBuilder, // Custom list "no data" widget builder
    this.translations =
        const AbstractTranslations(), // Default translations if none provided
    PaginationConfiguration?
        paginationConfiguration, // Optional pagination configuration
  }) {
    // If pagination configuration is provided, set it in the Pagination class
    if (paginationConfiguration != null) {
      Pagination.configuration = paginationConfiguration;
    }
  }

  // Determines if the widget should notify its dependents when updated
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  // Static method to retrieve the nearest AbstractConfiguration instance from the context
  static AbstractConfiguration? of(BuildContext context) {
    // Returns the AbstractConfiguration widget from the widget tree, if it exists
    return context.dependOnInheritedWidgetOfExactType<AbstractConfiguration>();
  }
}
