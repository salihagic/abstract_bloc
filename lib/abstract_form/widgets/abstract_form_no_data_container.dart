import 'package:flutter/material.dart';

class AbstractFormNoDataContainer extends StatelessWidget {
  final void Function()? onInit;

  const AbstractFormNoDataContainer({
    super.key,
    this.onInit,
  });

  @override
  Widget build(BuildContext context) {
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
