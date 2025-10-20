import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A widget to display a message indicating no data is available, with an option to reload.
class AbstractItemNoDataContainer extends StatelessWidget {
  // Callback to be executed when the user wants to retry the operation
  final void Function()? onInit;

  // Constructor for AbstractItemNoDataContainer
  const AbstractItemNoDataContainer({
    super.key,
    this.onInit, // Optional callback to initialize/reload
  });

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    // Builds the UI layout for displaying the "no data" message
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimum space vertically
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center-aligns children horizontally
        children: [
          // Message indicating no data is available
          Text(
            abstractConfiguration?.translations.thereIsNoData ??
                'There is no data',
          ),

          // Space between the message and the reload button
          SizedBox(height: 15),

          // Reload button to retry fetching data
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
