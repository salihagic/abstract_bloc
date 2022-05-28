import 'package:abstract_bloc/abstract_bloc.dart';

abstract class AbstractFormBloc<S extends AbstractFormState>
    extends Bloc<AbstractFormEvent, S> {
  AbstractFormBloc(
    S initialState,
    ModelValidator modelValidator,
  ) : super(initialState) {
    state.modelValidator = modelValidator;

    on(
      (AbstractFormEvent event, Emitter<S> emit) async {
        if (event is AbstractFormInitEvent) {
          await _init(event, emit);
        } else if (event is AbstractFormUpdateEvent) {
          await update(event, emit);
        } else if (event is AbstractFormSubmitEvent) {
          await submit(event, emit);
        }
      },
    );
  }

  // Override this method to initialize referent data or a model from your API
  Future<Result> prepareModel(
          AbstractFormInitEvent event, Emitter<S> emit) async =>
      NetworkResult();

  Future<void> _init(AbstractFormInitEvent event, Emitter<S> emit) async {
    _changeStatus(emit, FormResultStatus.initializing);

    if (state is AbstractFormFilterableState) {
      (state as AbstractFormFilterableState).searchModel = event.searchModel ??
          (state as AbstractFormFilterableState).searchModel;
    }

    final result = await prepareModel(event, emit);

    if (result.isSuccess) {
      if (result.hasData) {
        state.model = result.data;
      }

      _changeStatus(emit, FormResultStatus.initialized);
    } else {
      _changeStatus(emit, FormResultStatus.error);
    }
  }

  Future<void> update(AbstractFormUpdateEvent event, Emitter<S> emit) async {
    state.model = event.model;
    emit(state.copyWith() as S);
  }

  Future<Result> onSubmit(model) => throw Exception('onSubmit Not implemented');

  Future<void> submit(AbstractFormSubmitEvent event, Emitter<S> emit) async {
    if (state.modelValidator?.validate(state.model) ?? false) {
      state.formResultStatus = FormResultStatus.submitting;
      emit(state.copyWith());

      final result = await onSubmit(state.model);

      if (result.isSuccess) {
        _changeStatus(emit, FormResultStatus.submittingSuccess);
        add(AbstractFormInitEvent());
      } else {
        state.autovalidate = true;
        _changeStatus(emit, FormResultStatus.submittingError);
        _changeStatus(emit, FormResultStatus.initialized);
      }
    } else {
      state.autovalidate = true;
      _changeStatus(emit, FormResultStatus.validationError);
      _changeStatus(emit, FormResultStatus.initialized);
    }
  }

  void _changeStatus(Emitter<S> emit, FormResultStatus formResultStatus) {
    state.formResultStatus = formResultStatus;
    emit(state.copyWith());
  }
}
