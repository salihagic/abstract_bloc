import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract class representing the state of a list.
///
/// This class provides common properties and methods necessary to manage
/// a list's state, including its loading status and the list of items.
///
/// [TListItem] - The type of items contained in the list.
abstract class AbstractListState<TListItem> implements CopyWith {
  /// The current status of the result, indicating loading state.
  ResultStatus resultStatus;

  /// The result object containing the list of items and any related metadata.
  GridResult<TListItem> result;

  /// A getter that returns the list of items from the result.
  List<TListItem> get items => result.items;

  /// Checks if any data has been loaded (either from the network or cache).
  bool get isLoadedAny =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  /// Checks if the list was loaded from the network.
  bool get isLoadedNetwork => ResultStatus.loaded == resultStatus;

  /// Checks if the list was loaded from cached data.
  bool get isLoadedCached => ResultStatus.loadedCached == resultStatus;

  /// Constructor to initialize [AbstractListState].
  ///
  /// [resultStatus] - The current loading status of the result.
  /// [result] - The result object containing the list of items.
  AbstractListState({
    required this.resultStatus,
    required this.result,
  });

  /// A method that creates a copy of the current state with possibly modified properties.
  @override
  dynamic copyWith();
}

/// An abstract class representing a filterable list state.
///
/// This class extends [AbstractListState] and adds functionality for
/// filtering the list of items based on a search model.
///
/// [TSearchModel] - The type of the search model used to filter items.
/// [TListItem] - The type of items contained in the list.
abstract class AbstractListFilterableState<TSearchModel, TListItem>
    extends AbstractListState<TListItem> {
  /// The search model used to filter items in the list.
  TSearchModel searchModel;

  /// Constructor to initialize [AbstractListFilterableState].
  ///
  /// [resultStatus] - The current loading status of the result.
  /// [searchModel] - The current search model.
  /// [result] - The result object containing the list of items.
  AbstractListFilterableState({
    required super.resultStatus,
    required this.searchModel,
    required super.result,
  });

  /// A method that creates a copy of the current state with possibly modified properties.
  @override
  dynamic copyWith();
}

/// An abstract class representing a filterable and paginated list state.
///
/// This class extends [AbstractListFilterableState] to support pagination,
/// allowing dynamic loading of items based on pagination mechanics.
///
/// [TSearchModel] - The type of the search model used to filter items (must extend [Pagination]).
/// [TListItem] - The type of items contained in the list.
abstract class AbstractListFilterablePaginatedState<
    TSearchModel extends Pagination,
    TListItem> extends AbstractListFilterableState<TSearchModel, TListItem> {
  /// Constructor to initialize [AbstractListFilterablePaginatedState].
  ///
  /// [resultStatus] - The current loading status of the result.
  /// [searchModel] - The current search model.
  /// [result] - The result object containing the list of items.
  AbstractListFilterablePaginatedState({
    required super.resultStatus,
    required super.searchModel,
    required super.result,
  });

  /// A method that creates a copy of the current state with possibly modified properties.
  @override
  dynamic copyWith();
}
