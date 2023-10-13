import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:flutter/material.dart';

class AbstractFormConsumer<
    B extends AbstractFormBloc<S>,
    S extends AbstractFormState<TModel, TModelValidator>,
    TModel,
    TModelValidator extends ModelValidator> extends StatelessWidget {
  final void Function(
          BuildContext context, B bloc, void Function([TModel? model]) init)?
      onInit;
  final bool skipInitialOnInit;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final bool Function(BuildContext context, S state)? isLoading;
  final bool Function(BuildContext context, S state)? shouldAutovalidate;
  final bool Function(BuildContext context, S state)? isError;
  final bool Function(BuildContext context, S state)? hasData;
  final Widget? child;
  final Widget Function(
      BuildContext context,
      S state,
      TModel model,
      TModelValidator modelValidator,
      B bloc,
      void Function(TModel model) update,
      void Function() submit)? extendedBuilder;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final void Function(BuildContext context, S state)? onSuccess;
  final void Function(BuildContext context, S state)? onError;
  final void Function(BuildContext context, S state)? onValidationError;

  AbstractFormConsumer({
    Key? key,
    this.onInit,
    this.skipInitialOnInit = false,
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
    this.onError,
    this.onValidationError,
  }) : super(key: key);

  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      state.formResultStatus == FormResultStatus.initializing;
  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ??
      state.formResultStatus == FormResultStatus.error;
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
      ? onInit?.call(
          context,
          _blocInstance(context),
          ([TModel? model]) =>
              _blocInstance(context).add(AbstractFormInitEvent(model: model)))
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
      builder: (context) => SafeArea(
        child: BlocConsumer<B, S>(
          listener: (context, state) {
            if (state.formResultStatus == FormResultStatus.submittingSuccess) {
              onSuccess?.call(context, state);
            } else if (state.formResultStatus ==
                FormResultStatus.submittingError) {
              onError?.call(context, state);
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
              return errorBuilder?.call(
                      context, () => _onInit(context), state) ??
                  AbstractConfiguration.of(context)
                      ?.abstractFormErrorBuilder
                      ?.call(context, () => _onInit(context)) ??
                  AbstractFormErrorContainer(onInit: () => _onInit(context));
            }

            return Form(
              autovalidateMode: _shouldAutovalidate(context, state)
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
                    () => _blocInstance(context).add(AbstractFormSubmitEvent()),
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
