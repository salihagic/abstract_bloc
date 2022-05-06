import 'dart:async';

import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final Widget? child;
  final String? message;
  final FutureOr Function()? onCancel;
  final String? onCancelText;
  final Color? onCancelTextColor;
  final FutureOr Function()? onApply;
  final String? onApplyText;
  final Color? onApplyTextColor;
  final bool showCancelButton;
  final bool showApplyButton;

  InfoDialog({
    this.child,
    this.message,
    this.onCancel,
    this.onCancelText,
    this.onCancelTextColor,
    this.onApply,
    this.onApplyText,
    this.onApplyTextColor,
    this.showCancelButton = true,
    this.showApplyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: child ??
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        child: Text(
                          message ?? '',
                          softWrap: true,
                        ),
                      ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showCancelButton)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (onCancel != null) {
                            onCancel!();
                          }

                          Navigator.of(context).pop();
                        },
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            onCancelText ?? 'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: onCancelTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  if (showApplyButton)
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (onApply != null) {
                            await onApply!();
                          }

                          Navigator.of(context).pop();
                        },
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10)),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Color(0xFFF0F2F4)),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            onApplyText ?? 'Okay',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: onApplyTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
