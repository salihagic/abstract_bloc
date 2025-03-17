import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

class AbstractListNoDataContainer extends StatelessWidget {
  final void Function()? onInit;

  const AbstractListNoDataContainer({
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
          Text('There is no data'),
          SizedBox(height: 15),
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
