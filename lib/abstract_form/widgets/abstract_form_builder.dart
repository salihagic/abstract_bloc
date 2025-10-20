import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/extensions/_all.dart';
import 'package:abstract_bloc/widgets/_all.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/material.dart';

/// A widget for building forms with state management and event handling.
/// This widget integrates with [AbstractFormBaseState] and provides
/// callbacks for initialization, submission, success, and error handling.
class AbstractFormBuilder<
  B extends StateStreamableSource<S>,
  S extends AbstractFormBaseState
>
    extends StatelessWidget {
  /// Callback triggered when the form is initialized.
  /// This can be used to perform custom initialization logic.
  final void Function(BuildContext context)? onInit;

  /// If `true`, skips the initial `onInit` call when the widget is first built.
  /// Defaults to `false`.
  final bool skipInitialOnInit;

  /// If `true`, reinitializes the form after a successful submission.
  /// Defaults to `true`.
  final bool reinitOnSuccess;

  /// If `true`, reinitializes the form after a successful local submission.
  /// Defaults to `false`.
  final bool reinitOnLocalSuccess;

  /// Builder for displaying an error state.
  /// Provides a callback to retry initialization.
  final Widget Function(BuildContext context, void Function() onInit, S state)?
  errorBuilder;

  /// Builder for displaying a loading state.
  final Widget Function(BuildContext context, S state)? loaderBuilder;

  /// Custom function to determine if the form is in a loading state.
  /// If not provided, defaults to checking if the state is `initializing`.
  final bool Function(BuildContext context, S state)? isLoading;

  /// Custom function to determine if the form should auto-validate.
  final bool Function(BuildContext context, S state)? shouldAutovalidate;

  /// Custom function to determine if the form is in an error state.
  /// If not provided, defaults to checking if the state is `error`.
  final bool Function(BuildContext context, S state)? isError;

  /// Custom function to determine if the form has data.
  final bool Function(BuildContext context, S state)? hasData;

  /// The child widget to display if no custom builders are provided.
  final Widget? child;

  /// Extended builder that provides access to the form state, bloc/cubit instance,
  /// and a submit callback for custom form rendering.
  final Widget Function(
    BuildContext context,
    S state,
    B bloc,
    void Function() submit,
  )?
  extendedBuilder;

  /// Builder for rendering the form based on the current state.
  final Widget Function(BuildContext context, S state)? builder;

  /// Listener for state changes. Can be used to perform side effects
  /// based on the form's state.
  final void Function(BuildContext context, S state)? listener;

  /// Callback triggered when the form submission is successful.
  final void Function(BuildContext context, S state)? onSuccess;

  /// Callback triggered when the local form submission is successful.
  final void Function(BuildContext context, S state)? onLocalSuccess;

  /// Callback triggered when the form submission encounters an error.
  final void Function(BuildContext context, S state)? onError;

  /// Callback triggered when the local form submission encounters an error.
  final void Function(BuildContext context, S state)? onLocalError;

  /// Callback triggered when the form validation fails.
  final void Function(BuildContext context, S state)? onValidationError;

  /// The bloc/cubit instance to use. If provided, the widget will not create a new instance.
  final B? providerValue;

  /// A function to create the bloc/cubit instance. Used if `providerValue` is not provided.
  final B Function(BuildContext context)? provider;

  /// A list of additional providers to wrap around the form.
  final List<SingleChildWidget>? providers;

  /// Creates an [AbstractFormBuilder].
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

  /// Determines if the form is in a loading state.
  bool _isLoading(BuildContext context, S state) =>
      isLoading?.call(context, state) ??
      state.formResultStatus == FormResultStatus.initializing;

  /// Determines if the form is in an error state.
  bool _isError(BuildContext context, S state) =>
      isError?.call(context, state) ??
      state.formResultStatus == FormResultStatus.error;

  /// Retrieves the bloc/cubit instance from the context.
  B _blocOrCubitInstance(BuildContext context) {
    try {
      return context.read<B>();
    } catch (e) {
      debugPrint('There is no instance of bloc or cubit registered: $e');
      rethrow;
    }
  }

  /// Executes a callback based on the type of the bloc/cubit instance.
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

  /// Initializes the form by triggering the `onInit` callback or the appropriate bloc/cubit event.
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
                AbstractConfiguration.of(context)?.abstractFormErrorBuilder
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
              builder?.call(context, state) ??
              Container();
        },
      ),
    );

    if (providerValue != null) {
      return BlocProvider.value(value: providerValue!, child: mainChild);
    }

    if (provider != null) {
      return BlocProvider<B>(create: provider!, child: mainChild);
    }

    if (providers.abstractBlocListIsNotNullOrEmpty) {
      return MultiBlocProvider(providers: providers!, child: mainChild);
    }

    return mainChild;
  }
}
