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
  Future<Result> initModel<T>([T? model]) async => Result.success();

  Future<void> init<T>([T? model]) async {
    if (state is AbstractFormState) {
      (state as AbstractFormState).autovalidate = false;
    }
    updateStatus(FormResultStatus.initializing);

    final result = await initModel(model);

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

    emit(state.copyWith() as S);
  }

  Future<Result> onSubmit(model) => throw Exception('onSubmit Not implemented');
  Future<Result> onSubmitEmpty() =>
      throw Exception('onSubmitEmpty Not implemented');

  Future<void> onSubmitSuccess(Result result) async {
    updateStatus(FormResultStatus.submittingSuccess);
  }

  Future<void> onSubmitError(
    Result result,
  ) async {
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
      emit(state.copyWith());

      final result = state is AbstractFormBasicState
          ? await onSubmit(model)
          : await onSubmitEmpty();

      if (result.isSuccess) {
        await onSubmitSuccess(result);
      } else {
        await onSubmitError(result);
      }
    }
  }

  void updateStatus(FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    emit(state.copyWith());
  }
}
