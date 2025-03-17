import 'package:abstract_bloc/abstract_bloc.dart';

/// An abstract base class representing the state of an item with generic type [TItem].
///
/// This class provides properties and utility methods for handling the
/// loading status and item data, as well as a contract for the copy method.
abstract class AbstractItemState<TItem> implements CopyWith {
  /// The current result status indicating the loading state of the item.
  ResultStatus resultStatus;

  /// The loaded item, which can be null if no item has been loaded.
  TItem? item;

  /// Checks if there is an item loaded.
  bool get hasItem => item != null;

  /// Checks if any item has been loaded (either from network or cache).
  bool get isLoadedAny =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  /// Checks if an item has been loaded from the network.
  bool get isLoadedNetwork => ResultStatus.loaded == resultStatus;

  /// Checks if an item has been loaded from the cache.
  bool get isLoadedCached => ResultStatus.loadedCached == resultStatus;

  /// Constructor for creating an instance of [AbstractItemState].
  ///
  /// Requires [resultStatus] and optionally an [item].
  AbstractItemState({
    required this.resultStatus,
    this.item,
  });

  /// Method that must be implemented by subclasses to support copying of the state.
  @override
  dynamic copyWith();
}

/// An abstract class representing a filterable item state with generic types
/// for both the search model [TSearchModel] and the item [TItem].
///
/// This class extends [AbstractItemState] by adding a search model property.
abstract class AbstractItemFilterableState<TSearchModel, TItem>
    extends AbstractItemState<TItem> {
  /// The search model used for filtering items or defining search criteria.
  TSearchModel searchModel;

  /// Constructor for creating an instance of [AbstractItemFilterableState].
  ///
  /// Requires [resultStatus], [searchModel], and optionally an [item].
  AbstractItemFilterableState({
    required super.resultStatus,
    required this.searchModel,
    super.item,
  });

  /// Method that must be implemented by subclasses to support copying of the state.
  @override
  dynamic copyWith();
}
