import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

class AbstractGridErrorContainer extends StatelessWidget {
  final void Function()? onInit;

  const AbstractGridErrorContainer({
    Key? key,
    this.onInit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(abstractConfiguration?.translations.anErrorOccuredPleaseTryAgain ?? 'An error occured, please try again'),
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
