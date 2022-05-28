import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class AbstractFormConsumer<
    B extends AbstractFormBloc<S>,
    S extends AbstractFormState<TModel, TModelValidator>,
    TModel,
    TModelValidator extends ModelValidator> extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final Widget Function(void Function() onInit, S state)? errorBuilder;
  final Widget Function(void Function() onInit, S state)? noDataBuilder;
  final bool Function(S state)? isLoading;
  final bool Function(S state)? shouldAutovalidate;
  final bool Function(S state)? isError;
  final bool Function(S state)? hasData;
  final Widget? child;
  final Widget Function(
      BuildContext context,
      S state,
      TModel model,
      TModelValidator modelValidator,
      AbstractFormBloc bloc,
      void Function(TModel model) update)? extendedBuilder;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final void Function(BuildContext context, S state)? onSuccess;
  final void Function(BuildContext context, S state)? onValidationError;

  AbstractFormConsumer({
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
    this.extendedBuilder,
    this.builder,
    this.listener,
    this.onSuccess,
    this.onValidationError,
  }) : super(key: key);

  bool _isLoading(S state) =>
      isLoading?.call(state) ??
      state.formResultStatus == FormResultStatus.initializing;
  bool _isError(S state) =>
      isError?.call(state) ?? state.formResultStatus == FormResultStatus.error;
  bool _hasData(S state) => hasData?.call(state) ?? state.model != null;
  bool _isEmpty(S state) => !_hasData(state);
  bool _shouldAutovalidate(S state) =>
      shouldAutovalidate?.call(state) ?? state.autovalidate;

  AbstractFormBloc _blocInstance(BuildContext context) {
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
            if (_isLoading(state)) {
              return const Loader();
            }

            if (_isError(state)) {
              return errorBuilder?.call(() => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractFormErrorBuilder
                      ?.call(() => _onInit(context)) ??
                  AbstractFormErrorContainer(onInit: () => _onInit(context));
            }

            if (_isEmpty(state)) {
              return noDataBuilder?.call(() => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractFormNoDataBuilder
                      ?.call(() => _onInit(context)) ??
                  AbstractFormNoDataContainer(onInit: () => _onInit(context));
            }

            return Form(
              autovalidateMode: _shouldAutovalidate(state)
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: child ??
                  extendedBuilder?.call(
                    context,
                    state,
                    state.model!,
                    state.modelValidator!,
                    _blocInstance(context),
                    (model) => _blocInstance(context)
                        .add(AbstractFormUpdateEvent(model: model)),
                  ) ??
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
