import 'dart:async';

import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:flutter/material.dart';

/// A customizable information dialog widget.
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
          _buildContent(context),
          _buildActionButtons(context, abstractConfiguration),
        ],
      ),
    );
  }

  /// Builds the content of the dialog.
  Widget _buildContent(BuildContext context) {
    return Container(
      padding: contentPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child:
                child ??
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Text(
                    message ?? '',
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons (cancel and apply) at the bottom of the dialog.
  Widget _buildActionButtons(
    BuildContext context,
    AbstractConfiguration? configuration,
  ) {
    return Row(
      children: [
        if (showCancelButton) _buildCancelButton(context, configuration),
        if (showApplyButton) _buildApplyButton(context, configuration),
      ],
    );
  }

  /// Builds the cancel button.
  Widget _buildCancelButton(
    BuildContext context,
    AbstractConfiguration? configuration,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (onCancel != null) {
            onCancel!();
          } else {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
        ),
        child: _buildButtonText(
          text: onCancelText ?? configuration?.translations.cancel ?? 'Cancel',
          textColor: onCancelTextColor,
        ),
      ),
    );
  }

  /// Builds the apply button.
  Widget _buildApplyButton(
    BuildContext context,
    AbstractConfiguration? configuration,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          if (onApply != null) {
            await onApply!();
          } else {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(borderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: actionLineColor)),
          ),
          child: _buildButtonText(
            text: onApplyText ?? configuration?.translations.okay ?? 'Okay',
            textColor: onApplyTextColor,
          ),
        ),
      ),
    );
  }

  /// Builds stylized button text.
  Widget _buildButtonText({required String text, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black, // Handle null textColor
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
