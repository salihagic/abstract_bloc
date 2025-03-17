import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
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
  final double borderRadius;
  final Color backgroundColor;
  final Color actionLineColor;
  final EdgeInsetsGeometry contentPadding;

  const InfoDialog({
    super.key,
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
    this.borderRadius = 10.0,
    this.backgroundColor = Colors.white,
    this.actionLineColor = const Color(0xFFF0F2F4),
    this.contentPadding = const EdgeInsets.symmetric(vertical: 25),
  });

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: contentPadding,
            decoration: BoxDecoration(
              color: backgroundColor,
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
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(borderRadius)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            onCancelText ??
                                abstractConfiguration?.translations.cancel ??
                                'Cancel',
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
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(borderRadius)),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: actionLineColor),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            onApplyText ??
                                abstractConfiguration?.translations.okay ??
                                'Okay',
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
