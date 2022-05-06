import 'package:flutter/material.dart';

class AbstractItemEmptyContainerOptions {
  final String? imagePath;
  final String? text;

  const AbstractItemEmptyContainerOptions({
    this.imagePath,
    this.text,
  });
}

class AbstractItemEmptyContainer extends StatelessWidget {
  final AbstractItemEmptyContainerOptions? options;

  const AbstractItemEmptyContainer({
    Key? key,
    this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Image.asset(options?.imagePath ?? ''),
          ),
          SizedBox(height: 15),
          Text(options?.text ?? 'There is no data'),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
