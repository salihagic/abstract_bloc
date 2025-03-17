import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/material.dart';

class AbstractFormBuilder<B extends StateStreamableSource<S>,
    S extends AbstractFormBaseState> extends StatelessWidget {
  final void Function(BuildContext context)? onInit;
  final bool skipInitialOnInit;
  final bool reinitOnSuccess;
  final bool reinitOnLocalSuccess;
  final Widget Function(BuildContext context, void Function() onInit, S state)?
      errorBuilder;
  final Widget Function(BuildContext context, S state)? loaderBuilder;
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
  final void Function(BuildContext context, S state)? onLocalSuccess;
  final void Function(BuildContext context, S state)? onError;
  final void Function(BuildContext context, S state)? onLocalError;
  final void Function(BuildContext context, S state)? onValidationError;
  final B? providerValue;
  final B Function(BuildContext context)? provider;
  final List<SingleChildWidget>? providers;

  const AbstractFormBuilder({
    super.key,
    this.onInit,
    this.skipInitialOnInit = false,
    this.reinitOnSuccess = true,
    this.reinitOnLocalSuccess = false,
    this.errorBuilder,
    this.loaderBuilder,
    this.isLoading,
    this.shouldAutovalidate,
    this.isError,
    this.hasData,
    this.child,
    this.extendedBuilder,
    this.builder,
    this.listener,
    this.onSuccess,
    this.onLocalSuccess,
    this.onError,
    this.onLocalError,
    this.onValidationError,
    this.providerValue,
    this.provider,
    this.providers,
  });

  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      state.formResultStatus == FormResultStatus.initializing;
  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ??
      state.formResultStatus == FormResultStatus.error;

  B _blocOrCubitInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      debugPrint('There is no instance of bloc or cubit registered: $e');

      rethrow;
    }
  }

  void _execute(
    BuildContext context,
    void Function(BuildContext)? executable,
    void Function(AbstractFormBloc instance)? executableBloc,
    void Function(AbstractFormCubit instance)? executableCubit,
  ) {
    if (executable != null) {
      executable.call(context);
    } else {
      final instance = _blocOrCubitInstance(context);

      if (instance is AbstractFormBloc) {
        executableBloc?.call(instance as AbstractFormBloc);
      }

      if (instance is AbstractFormCubit) {
        executableCubit?.call(instance as AbstractFormCubit);
      }
    }
  }

  void _onInit(BuildContext context) => _execute(
        context,
        onInit,
        (instance) => instance.add(AbstractFormInitEvent()),
        (instance) => instance.init(),
      );

  @override
  Widget build(BuildContext context) {
    final abstractConfiguration = AbstractConfiguration.of(context);

    final mainChild = AbstractStatefulBuilder(
      initState: (context) {
        if (!skipInitialOnInit) {
          _onInit(context);
        }
      },
      builder: (context) => BlocConsumer<B, S>(
        listener: (context, state) {
          if (state.formResultStatus == FormResultStatus.initializing) {
            // Implement initializing
          }
          if (state.formResultStatus == FormResultStatus.initialized) {
            //  Implement initialized
          }
          if (state.formResultStatus == FormResultStatus.error) {
            onError?.call(context, state);
          }
          if (state.formResultStatus == FormResultStatus.submitting) {
            // Implement submitting
          }
          if (state.formResultStatus == FormResultStatus.submittingSuccess) {
            onSuccess?.call(context, state);
            if (reinitOnSuccess) {
              _onInit(context);
            }
          }
          if (state.formResultStatus ==
              FormResultStatus.submittingLocalSuccess) {
            onLocalSuccess?.call(context, state);
            if (reinitOnLocalSuccess) {
              _onInit(context);
            }
          }
          if (state.formResultStatus == FormResultStatus.submittingError) {
            onError?.call(context, state);
          }
          if (state.formResultStatus == FormResultStatus.submittingLocalError) {
            onLocalError?.call(context, state);
          }
          if (state.formResultStatus == FormResultStatus.validationError) {
            onValidationError?.call(context, state);
          }

          listener?.call(context, state);
        },
        builder: (context, state) {
          if (_isLoading(context, state)) {
            return loaderBuilder?.call(context, state) ??
                abstractConfiguration?.loaderBuilder?.call(context) ??
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
                _blocOrCubitInstance(context),
                () => _execute(
                  context,
                  null,
                  (instance) => instance.add(AbstractFormSubmitEvent()),
                  (instance) => instance.submit(),
                ),
              ) ??
              builder?.call(
                context,
                state,
              ) ??
              Container();
        },
      ),
    );

    if (providerValue != null) {
      return BlocProvider.value(
        value: providerValue!,
        child: mainChild,
      );
    }

    if (provider != null) {
      return BlocProvider<B>(
        create: provider!,
        child: mainChild,
      );
    }

    if (providers.isNotNullOrEmpty) {
      return MultiBlocProvider(
        providers: providers!,
        child: mainChild,
      );
    }

    return mainChild;
  }
}
