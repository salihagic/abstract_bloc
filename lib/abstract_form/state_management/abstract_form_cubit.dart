import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormCubit<S extends AbstractFormBaseState>
    extends Cubit<S> {
  AbstractFormCubit(S initialState, [ModelValidator? modelValidator])
      : super(initialState) {
    if (state is AbstractFormState) {
      (state as AbstractFormState).modelValidator = modelValidator;
    }
  }

  // Override this method to initialize referent data or a model from your API
  Future<Result> initModel(model) async => Result.success();
  Future<Result> initModelEmpty() async => Result.success();

  Future<void> init<T>([T? model]) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = false;
    }
    updateStatus(FormResultStatus.initializing);

    final result =
        model != null ? await initModel(model) : await initModelEmpty();

    if (result.isError) {
      updateStatus(FormResultStatus.error);
    } else {
      if (result.hasData) {
        if (state is AbstractFormBasicState) {
          (state as AbstractFormBasicState).model = result.data;
        }
      }

      updateStatus(FormResultStatus.initialized);
    }
  }

  Future<void> update<T>(T model) async {
    if (state is AbstractFormBasicState) {
      (state as AbstractFormBasicState).model = model;
    }

    updateState(state.copyWith() as S);
  }

  Future<Result> onSubmit(model) => throw Exception('onSubmit Not implemented');
  Future<Result> onSubmitEmpty() =>
      throw Exception('onSubmitEmpty Not implemented');

  void success() {}
  Future<void> onSubmitSuccess(Result result) async {
    updateStatus(FormResultStatus.submittingSuccess);
  }

  void error() {}
  Future<void> onSubmitError(Result result) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = true;
    }
    updateStatus(FormResultStatus.submittingError);
    await Future.delayed(const Duration(milliseconds: 100));
    updateStatus(FormResultStatus.initialized);
  }

  Future<void> submit<T>([T? pModel]) async {
    final model = pModel ??
        (state is AbstractFormBasicState
            ? (state as AbstractFormBasicState).model
            : null);

    if (state is AbstractFormState &&
        !((state as AbstractFormState).modelValidator?.validate(model) ??
            true)) {
      (state as AbstractFormState).autovalidate = true;
      updateStatus(FormResultStatus.validationError);
      await Future.delayed(const Duration(milliseconds: 100));
      updateStatus(FormResultStatus.initialized);
    } else {
      state.formResultStatus = FormResultStatus.submitting;
      updateState(state.copyWith());

      final result =
          model != null ? await onSubmit(model) : await onSubmitEmpty();

      if (result.isSuccess) {
        await onSubmitSuccess(result);
        success();
      } else {
        await onSubmitError(result);
        error();
      }
    }
  }

  void updateStatus(FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    updateState(state.copyWith());
  }

  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
