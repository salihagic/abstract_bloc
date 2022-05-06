import 'package:flutter/material.dart';

class AbstractListEmptyContainerOptions {
  final bool showImage;
  final String? imagePath;
  final Widget? text;

  const AbstractListEmptyContainerOptions({
    this.showImage = true,
    this.imagePath,
    this.text,
  });
}

class AbstractListEmptyContainer extends StatelessWidget {
  final AbstractListEmptyContainerOptions? options;

  const AbstractListEmptyContainer({
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
          if (options?.showImage != null && options!.showImage)
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Image.asset(options?.imagePath ?? ''),
            ),
          SizedBox(height: 15),
          options?.text ?? const Text('The list is empty'),
        ],
      ),
    );
  }
}
