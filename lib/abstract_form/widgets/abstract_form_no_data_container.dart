import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A widget for displaying a "no data" message and a retry button in a form.
/// This widget is typically used when a form has no data to display and provides
/// the user with an option to retry fetching or loading the data.
class AbstractFormNoDataContainer extends StatelessWidget {
  /// Callback triggered when the retry button is pressed.
  /// This is usually used to reinitialize the form or retry fetching the data.
  final void Function()? onInit;

  /// Creates an [AbstractFormNoDataContainer].
  /// - [onInit]: Callback for the retry action.
  const AbstractFormNoDataContainer({
    super.key,
    this.onInit,
  });

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display a "no data" message
          Text(abstractConfiguration?.translations.thereIsNoData ??
              'There is no data'),
          SizedBox(height: 15),

          // Retry button to trigger the `onInit` callback
          TextButton(
            onPressed: () => onInit?.call(),
            child: Text(
              abstractConfiguration?.translations.reload ?? 'Reload',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
