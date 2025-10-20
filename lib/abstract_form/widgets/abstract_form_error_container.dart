import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A widget for displaying an error message and a retry button in a form.
/// This widget is typically used when a form encounters an error and needs
/// to provide the user with an option to retry the operation.
class AbstractFormErrorContainer extends StatelessWidget {
  /// Callback triggered when the retry button is pressed.
  /// This is usually used to reinitialize the form or retry the failed operation.
  final void Function()? onInit;

  /// Creates an [AbstractFormErrorContainer].
  /// - [onInit]: Callback for the retry action.
  const AbstractFormErrorContainer({super.key, this.onInit});

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display an error message
          Text(
            abstractConfiguration?.translations.anErrorOccuredPleaseTryAgain ??
                'An error occurred, please try again',
          ),
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
