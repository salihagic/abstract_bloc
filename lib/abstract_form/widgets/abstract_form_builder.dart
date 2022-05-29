import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class AbstractFormBuilder<B extends AbstractFormBloc<S>,
    S extends AbstractFormState> extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      noDataBuilder;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? shouldAutovalidate;
  final bool Function(BuildContext context, S state)? isError;
  final bool Function(BuildContext context, S state)? hasData;
  final Widget? child;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final void Function(BuildContext context, S state)? onSuccess;
  final void Function(BuildContext context, S state)? onValidationError;

  AbstractFormBuilder({
    Key? key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.errorBuilder,
    this.noDataBuilder,
    this.isLoading,
    this.shouldAutovalidate,
    this.isError,
    this.hasData,
    this.child,
    this.builder,
    this.listener,
    this.onSuccess,
    this.onValidationError,
  }) : super(key: key);

  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      state.formResultStatus == FormResultStatus.initializing;
  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ??
      state.formResultStatus == FormResultStatus.error;
  bool _hasData(BuildContext context, S state) =>
      hasData?.call(context, state) ?? state.model != null;
  bool _isEmpty(BuildContext context, S state) => !_hasData(context, state);
  bool _shouldAutovalidate(BuildContext context, S state) =>
      shouldAutovalidate?.call(context, state) ?? state.autovalidate;

  B _blocInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      print('There is no instance of AbstractFormBloc registered: $e');
      throw e;
    }
  }

  void _onInit(BuildContext context) => onInit != null
      ? onInit?.call(context)
      : _blocInstance(context).add(AbstractFormInitEvent());

  @override
  Widget build(BuildContext context) {
    return StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) => SafeArea(
        child: BlocConsumer<B, S>(
          listener: (context, state) {
            if (state.formResultStatus == FormResultStatus.submittingSuccess) {
              onSuccess?.call(context, state);
            } else if (state.formResultStatus ==
                FormResultStatus.validationError) {
              onValidationError?.call(context, state);
            }

            listener?.call(context, state);
          },
          builder: (context, state) {
            if (_isLoading(context, state)) {
              return const Loader();
            }

            if (_isError(context, state)) {
              return errorBuilder?.call(
                      context, () => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractFormErrorBuilder
                      ?.call(() => _onInit(context)) ??
                  AbstractFormErrorContainer(onInit: () => _onInit(context));
            }

            if (_isEmpty(context, state)) {
              return noDataBuilder?.call(
                      context, () => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractFormNoDataBuilder
                      ?.call(() => _onInit(context)) ??
                  AbstractFormNoDataContainer(onInit: () => _onInit(context));
            }

            return Form(
              autovalidateMode: _shouldAutovalidate(context, state)
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: child ??
                  builder?.call(
                    context,
                    state,
                  ) ??
                  Container(),
            );
          },
        ),
      ),
    );
  }
}
