import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class that serves as a base for item Cubits,
/// providing functionality for loading and processing data states.
abstract class AbstractItemCubit<S extends AbstractItemState> extends Cubit<S> {
  final S _initialState;

  /// Constructor that initializes the cubit with its initial state.
  AbstractItemCubit(super.initialState) : _initialState = initialState;

  /// Resolves data asynchronously and must be implemented by subclasses.
  Future<Result> resolveData() async => throw UnimplementedError();

  /// Resolves data via a stream asynchronously and must be implemented by subclasses.
  Stream<Result> resolveStreamData() async* {
    throw UnimplementedError();
  }

  /// A hook method that can be overridden to perform actions
  /// before data loading occurs.
  Future<void> onBeforeLoad<TSearchModel>(TSearchModel? searchModel) async {}

  /// Saves a snapshot of current search model to temporary search model so it can be reverted if needed
  /// Make sure that your search model implements CopyWith if it's a complex model (class)
  Future<void> snapshot() async {
    if (state is AbstractListFilterableState) {
      if ((state as AbstractListFilterableState).searchModel is CopyWith) {
        (state as AbstractListFilterableState).tempSearchModel =
            ((state as AbstractListFilterableState).searchModel as CopyWith)
                .copyWith();
      } else {
        (state as AbstractListFilterableState).tempSearchModel =
            (state as AbstractListFilterableState).searchModel;
      }

      emit(state.copyWith());
    }
  }

  /// Updates search model, it can be reverted to previous state by calling revert
  Future<void> update<TSearchModel>(TSearchModel searchModel) async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).searchModel = searchModel;
      emit(state.copyWith());
    }
  }

  /// Reverts to previous state of search model (if there is tempSearchModel, if previously used snapshot and load occured)
  Future<void> revert() async {
    if (state is AbstractListFilterableState &&
        (state as AbstractListFilterableState).tempSearchModel != null) {
      (state as AbstractListFilterableState).searchModel =
          (state as AbstractListFilterableState).tempSearchModel;
      // (state as AbstractListFilterableState).tempSearchModel = null;
      emit(state.copyWith());
    }
  }

  /// Resets all filters, both: search model and temporary search model
  Future<void> reset() async {
    if (state is AbstractListFilterableState) {
      (state as AbstractListFilterableState).tempSearchModel =
          (_initialState as AbstractListFilterableState).searchModel;
      (state as AbstractListFilterableState).searchModel =
          (_initialState as AbstractListFilterableState).searchModel;
      await load();
    }
  }

  Future<void> _applySnapshot() async {
    if (state is AbstractListFilterableState &&
        (state as AbstractListFilterableState).tempSearchModel != null) {
      (state as AbstractListFilterableState).tempSearchModel =
          (state as AbstractListFilterableState).searchModel;
    }
  }

  /// Loads data and updates the state accordingly.
  Future<void> load<TSearchModel>([TSearchModel? searchModel]) async {
    await _applySnapshot();

    // Update the search model if the current state is filterable
    if (state is AbstractItemFilterableState && searchModel != null) {
      (state as AbstractItemFilterableState).searchModel = searchModel;
    }

    await onBeforeLoad(searchModel);

    // Set state to loading
    state.resultStatus = ResultStatus.loading;
    updateState(state.copyWith() as S);

    try {
      // Attempt to resolve data and update state
      final result = await resolveData();

      updateState(convertResultToState(result));
      await onAfterLoad(result);
    } catch (e) {
      // On error, resolve data via stream and update state for each result
      await for (final result in resolveStreamData()) {
        updateState(convertResultToState(result));
        await onAfterLoad(result);
      }
    }
  }

  /// A hook method that can be overridden to perform actions
  /// after data loading is completed.
  Future<void> onAfterLoad(Result result) async {}

  /// Converts the result obtained from data resolution into a state.
  S convertResultToState(Result result) {
    // Update the result status based on the result
    state.resultStatus = _getStatusFromResult(result) ?? state.resultStatus;

    if (result.isSuccess) {
      state.item = result.data; // Populate the item if the result is successful
    }

    return state.copyWith(); // Return the new state based on the result
  }

  /// Gets the result status based on the provided result.
  ResultStatus? _getStatusFromResult(Result result) => result.isError
      ? ResultStatus.error
      : result.hasData && result is CacheResult
      ? ResultStatus.loadedCached
      : ResultStatus.loaded;

  /// Updates the current state of the Cubit if it is not closed.
  void updateState(S state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
