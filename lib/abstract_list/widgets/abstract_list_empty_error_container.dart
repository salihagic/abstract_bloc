import 'package:flutter/material.dart';

class AbstractListEmptyErrorContainerOptions {
  final String? imagePath;
  final String? text;
  final String? buttonText;

  const AbstractListEmptyErrorContainerOptions({
    this.imagePath,
    this.text,
    this.buttonText,
  });
}

class AbstractListEmptyErrorContainer extends StatelessWidget {
  final AbstractListEmptyErrorContainerOptions? options;
  final void Function(BuildContext context)? onInit;

  const AbstractListEmptyErrorContainer({
    Key? key,
    this.options,
    this.onInit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Image.asset(options?.imagePath ?? ''),
          ),
          SizedBox(height: 15),
          Text(options?.text ?? 'An error occured, please try again'),
          SizedBox(height: 15),
          TextButton(
            onPressed: () => onInit?.call(context),
            child: Text(options?.buttonText ?? 'Reload'),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
