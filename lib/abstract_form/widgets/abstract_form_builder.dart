import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class AbstractFormBuilder<B extends AbstractFormBloc<S>,
    S extends AbstractFormBasicState> extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final bool reinitOnSuccess;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? shouldAutovalidate;
  final bool Function(BuildContext context, S state)? isError;
  final bool Function(BuildContext context, S state)? hasData;
  final Widget? child;
  final Widget Function(
          BuildContext context, S state, B bloc, void Function() submit)?
      extendedBuilder;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final void Function(BuildContext context, S state)? onSuccess;
  final void Function(BuildContext context, S state)? onValidationError;

  AbstractFormBuilder({
    Key? key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.reinitOnSuccess = true,
    this.errorBuilder,
    this.isLoading,
    this.shouldAutovalidate,
    this.isError,
    this.hasData,
    this.child,
    this.extendedBuilder,
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
    final abstractConfiguration = AbstractConfiguration.of(context);

    return StatefullBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) => BlocConsumer<B, S>(
        listener: (context, state) {
          if (state.formResultStatus == FormResultStatus.submittingSuccess) {
            onSuccess?.call(context, state);
            if (reinitOnSuccess) {
              _onInit(context);
            }
          } else if (state.formResultStatus ==
              FormResultStatus.validationError) {
            onValidationError?.call(context, state);
          }

          listener?.call(context, state);
        },
        builder: (context, state) {
          if (_isLoading(context, state)) {
            return abstractConfiguration?.loaderBuilder?.call(context) ??
                const Loader();
          }

          if (_isError(context, state)) {
            return errorBuilder?.call(context, () => _onInit(context), state) ??
                AbstractConfiguration.of(context)
                    ?.abstractFormErrorBuilder
                    ?.call(context, () => _onInit(context)) ??
                AbstractFormErrorContainer(onInit: () => _onInit(context));
          }

          return child ??
              extendedBuilder?.call(
                context,
                state,
                _blocInstance(context),
                () => _blocInstance(context).add(AbstractFormSubmitEvent()),
              ) ??
              builder?.call(
                context,
                state,
              ) ??
              Container();
        },
      ),
    );
  }
}
