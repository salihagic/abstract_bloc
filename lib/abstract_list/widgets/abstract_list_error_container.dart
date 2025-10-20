import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A widget that displays an error message with an option to retry.
///
/// The [AbstractLisErrorContainer] is used to inform users when an error
/// occurs in the application and provides a button to retry the operation.
///
/// It takes an optional [onInit] callback to be executed when the user
/// chooses to reload.
class AbstractLisErrorContainer extends StatelessWidget {
  /// A callback function to execute when the reload button is pressed.
  final void Function()? onInit;

  /// Creates an instance of [AbstractLisErrorContainer].
  ///
  /// [key] - An optional key for the widget.
  /// [onInit] - An optional function called when the user clicks the reload button.
  const AbstractLisErrorContainer({super.key, this.onInit});

  @override
  Widget build(BuildContext context) {
    // Retrieve the abstract configuration from the context.
    final abstractConfiguration = AbstractConfiguration.of(context);

    // Build the error display widget.
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display the error message.
          Text(
            abstractConfiguration?.translations.anErrorOccuredPleaseTryAgain ??
                'An error occurred, please try again',
          ),
          SizedBox(height: 15), // Add space between the message and button.
          // Reload button.
          TextButton(
            onPressed: () =>
                onInit?.call(), // Call the onInit function if provided.
            child: Text(
              abstractConfiguration?.translations.reload ?? 'Reload',
              style: TextStyle(color: Colors.black), // Custom text style.
            ),
          ),
          SizedBox(height: 15), // Add space after the button.
        ],
      ),
    );
  }
}
