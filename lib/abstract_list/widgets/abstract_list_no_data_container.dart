import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A widget that displays a message indicating that no data is available.
///
/// The [AbstractListNoDataContainer] informs users when there's no data
/// available to display and provides a button to reload or refresh the data.
///
/// It includes an optional [onInit] callback function that can be executed
/// when the user chooses to reload the data.
class AbstractListNoDataContainer extends StatelessWidget {
  /// A callback function that is executed when the reload button is pressed.
  final void Function()? onInit;

  /// Creates an instance of [AbstractListNoDataContainer].
  ///
  /// [key] - An optional widget key.
  /// [onInit] - An optional callback invoked when the reload button is pressed.
  const AbstractListNoDataContainer({super.key, this.onInit});

  @override
  Widget build(BuildContext context) {
    // Retrieve the configuration settings, such as translations.
    final abstractConfiguration = AbstractConfiguration.of(context);

    // Build the UI for the no data state.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display a message to indicate that there's no data.
          Text(
            abstractConfiguration?.translations.thereIsNoData ??
                'There is no data',
          ),
          SizedBox(height: 15), // Add space between the message and button.
          // Button to reload the data.
          TextButton(
            onPressed: () =>
                onInit?.call(), // Use the onInit callback if provided.
            child: Text(
              abstractConfiguration?.translations.reload ??
                  'Reload', // Button text with fallback.
              style: TextStyle(
                color: Colors.black,
              ), // Custom text style for the button.
            ),
          ),
          SizedBox(height: 15), // Add space after the button.
        ],
      ),
    );
  }
}
