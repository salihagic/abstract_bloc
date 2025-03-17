import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A widget to display an error message with an option to reload.
class AbstractItemErrorContainer extends StatelessWidget {
  // Callback to be executed when the user wants to retry the operation
  final void Function()? onInit;

  // Constructor for AbstractItemErrorContainer
  const AbstractItemErrorContainer({
    super.key,
    this.onInit, // Optional callback to initialize/reload
  });

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    // Builds the UI layout for displaying the error message
    return Center(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center-aligns children horizontally
        mainAxisSize: MainAxisSize.min, // Takes minimum space vertically
        children: [
          // Error message text
          Text(abstractConfiguration
                  ?.translations.anErrorOccuredPleaseTryAgain ??
              'An error occurred, please try again'),

          // Space between error message and reload button
          SizedBox(height: 15),

          // Reload button to retry the operation
          TextButton(
            onPressed: () => onInit?.call(), // Calls onInit if it's not null
            child: Text(
              abstractConfiguration?.translations.reload ??
                  'Reload', // Button label
              style: TextStyle(color: Colors.black), // Button text color
            ),
          ),

          // Space below the button
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
