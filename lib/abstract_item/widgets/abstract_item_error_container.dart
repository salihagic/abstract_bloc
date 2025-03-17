import 'package:flutter/material.dart';

class AbstractItemErrorContainer extends StatelessWidget {
  final void Function()? onInit;

  const AbstractItemErrorContainer({
    super.key,
    this.onInit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('An error occured, please try again'),
          SizedBox(height: 15),
          TextButton(
            onPressed: () => onInit?.call(),
            child: Text(
              'Reload',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
