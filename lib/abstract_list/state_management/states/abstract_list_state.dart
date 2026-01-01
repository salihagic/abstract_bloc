import 'package:abstract_bloc/abstract_bloc.dart';
import 'package:abstract_bloc/models/base_pagination.dart';

/// Base state class for managing list data in BLoC/Cubit patterns.
///
/// This abstract class provides the foundation for list state management with:
/// - Loading status tracking (loading, loaded, cached, error)
/// - Data storage via [GridResult]
/// - Convenient accessors for common state checks
///
/// ## Usage
///
/// Extend this class to create your own list state:
///
/// ```dart
/// class UsersState extends AbstractListState<User> {
///   UsersState({
///     required super.resultStatus,
///     required super.result,
///   });
///
///   factory UsersState.initial() => UsersState(
///     resultStatus: ResultStatus.loading,
///     result: GridResult<User>(),
///   );
///
///   @override
///   UsersState copyWith({
///     ResultStatus? resultStatus,
///     GridResult<User>? result,
///   }) => UsersState(
///     resultStatus: resultStatus ?? this.resultStatus,
///     result: result ?? this.result,
///   );
/// }
/// ```
///
/// ## State Hierarchy
///
/// Choose the appropriate state class based on your needs:
/// - [AbstractListState]: Basic list without filtering or pagination
/// - [AbstractListFilterableState]: List with search/filter support
/// - [AbstractListFilterablePaginatedState]: Full-featured list with pagination
///
/// Type parameter [TListItem] defines the type of items in the list.
abstract class AbstractListState<TListItem> implements CopyWith {
  /// Current loading/result status of the list data.
  ///
  /// Possible values:
  /// - [ResultStatus.loading]: Data is being fetched
  /// - [ResultStatus.loaded]: Data successfully loaded from network
  /// - [ResultStatus.loadedCached]: Data loaded from cache
  /// - [ResultStatus.error]: An error occurred during loading
  ResultStatus resultStatus;

  /// Container for list items and pagination metadata.
  ///
  /// Includes:
  /// - `items`: The list of [TListItem] objects
  /// - `hasMoreItems`: Whether more pages are available
  /// - `numberOfCachedItems`: Count of items from cache
  /// - Pagination cursors and metadata
  GridResult<TListItem> result;

  /// Direct access to the list items.
  ///
  /// Shorthand for `result.items`.
  List<TListItem> get items => result.items;

  /// Whether data has been loaded (from network or cache).
  ///
  /// Returns `true` if [resultStatus] is either `loaded` or `loadedCached`.
  /// Use this to determine if the list has displayable content.
  bool get isLoadedAny =>
      [ResultStatus.loaded, ResultStatus.loadedCached].contains(resultStatus);

  /// Whether data was loaded fresh from the network.
  ///
  /// Returns `true` only if [resultStatus] is `loaded`.
  bool get isLoadedNetwork => ResultStatus.loaded == resultStatus;

  /// Whether data was loaded from cache.
  ///
  /// Returns `true` only if [resultStatus] is `loadedCached`.
  /// When true, consider showing a "cached data" indicator to the user.
  bool get isLoadedCached => ResultStatus.loadedCached == resultStatus;

  /// Creates an [AbstractListState].
  ///
  /// Parameters:
  /// - [resultStatus]: Initial loading status
  /// - [result]: Initial result container (typically empty [GridResult])
  AbstractListState({required this.resultStatus, required this.result});

  /// Creates a copy of this state with optionally modified properties.
  ///
  /// Subclasses must implement this to enable immutable state updates.
  /// The implementation should copy all properties and allow overriding any.
  @override
  dynamic copyWith();
}

/// State class for filterable lists with search model support.
///
/// Extends [AbstractListState] to add filtering capabilities:
/// - Search model for API queries and local filtering
/// - Temporary search model for filter dialogs (snapshot/revert pattern)
/// - Dirty flag to track unsaved filter changes
///
/// ## Usage
///
/// ```dart
/// class UsersState extends AbstractListFilterableState<UserSearchModel, User> {
///   UsersState({
///     required super.resultStatus,
///     required super.result,
///     required super.searchModel,
///     super.tempSearchModel,
///     super.isDirty,
///   });
///
///   factory UsersState.initial() => UsersState(
///     resultStatus: ResultStatus.loading,
///     result: GridResult<User>(),
///     searchModel: UserSearchModel(),
///   );
///
///   @override
///   UsersState copyWith({...}) => UsersState(...);
/// }
/// ```
///
/// ## Filter Workflow
///
/// The snapshot/revert pattern allows users to preview filter changes:
/// 1. User opens filter dialog → Cubit saves snapshot to [tempSearchModel]
/// 2. User modifies filters → Changes applied to [searchModel], [isDirty] = true
/// 3. User confirms → Load is called, [isDirty] resets
/// 4. User cancels → Cubit reverts [searchModel] from [tempSearchModel]
///
/// Type parameters:
/// - [TSearchModel]: The type of search/filter model
/// - [TListItem]: The type of items in the list
abstract class AbstractListFilterableState<TSearchModel, TListItem>
    extends AbstractListState<TListItem> {
  /// The current search/filter model used for API queries.
  ///
  /// This model is sent to the repository/API when fetching data.
  /// Modify this to change filters, then call `load()` to fetch filtered data.
  ///
  /// If your search model is a complex object, ensure it implements [CopyWith]
  /// to support the snapshot/revert pattern properly.
  TSearchModel searchModel;

  /// Temporary storage for the search model snapshot.
  ///
  /// Used by the snapshot/revert pattern:
  /// - [snapshot] saves current [searchModel] here
  /// - [revert] restores [searchModel] from here
  ///
  /// Typically used when opening a filter dialog to allow cancellation.
  TSearchModel? tempSearchModel;

  /// Whether [searchModel] has unsaved changes.
  ///
  /// Set to `true` when filters are modified via [update].
  /// Set to `false` after [load], [revert], or [reset].
  ///
  /// Use this to show a "filters changed" indicator or enable/disable
  /// an "Apply" button in filter UIs.
  bool? isDirty;

  /// Creates an [AbstractListFilterableState].
  ///
  /// Parameters:
  /// - [resultStatus]: Initial loading status
  /// - [result]: Initial result container
  /// - [searchModel]: Initial search/filter model
  /// - [tempSearchModel]: Optional saved search model for reversion
  /// - [isDirty]: Whether filters have unsaved changes
  AbstractListFilterableState({
    required super.resultStatus,
    required super.result,
    required this.searchModel,
    this.tempSearchModel,
    this.isDirty,
  });

  /// Creates a copy of this state with optionally modified properties.
  @override
  dynamic copyWith();
}

/// State class for paginated lists with filtering and load-more support.
///
/// Extends [AbstractListFilterableState] to add pagination:
/// - Search model must extend [BasePagination] for page/cursor management
/// - Supports both offset-based ([Pagination]) and cursor-based ([CursorPagination])
/// - Automatic pagination increment on load-more
///
/// ## Usage
///
/// ```dart
/// class UsersState extends AbstractListFilterablePaginatedState<UserSearchModel, User> {
///   UsersState({
///     required super.resultStatus,
///     required super.result,
///     required super.searchModel,
///     super.tempSearchModel,
///     super.isDirty,
///   });
///
///   factory UsersState.initial() => UsersState(
///     resultStatus: ResultStatus.loading,
///     result: GridResult<User>(),
///     searchModel: UserSearchModel(), // Must extend BasePagination
///   );
/// }
///
/// // UserSearchModel with pagination
/// class UserSearchModel extends Pagination {
///   String? nameFilter;
///   String? roleFilter;
///
///   UserSearchModel({
///     this.nameFilter,
///     this.roleFilter,
///     super.page,
///     super.pageSize,
///   });
/// }
/// ```
///
/// ## Pagination Types
///
/// Your [TSearchModel] must extend one of:
/// - [Pagination]: Offset-based (page, pageSize, skip, take)
/// - [CursorPagination]: Cursor-based (cursor, nextCursor, previousCursor)
///
/// The cubit/bloc automatically calls `increment()` and `reset()` on the
/// search model during load-more and refresh operations.
///
/// Type parameters:
/// - [TSearchModel]: Search model that extends [BasePagination]
/// - [TListItem]: The type of items in the list
abstract class AbstractListFilterablePaginatedState<
  TSearchModel extends BasePagination,
  TListItem
>
    extends AbstractListFilterableState<TSearchModel, TListItem> {
  /// Creates an [AbstractListFilterablePaginatedState].
  ///
  /// Parameters:
  /// - [resultStatus]: Initial loading status
  /// - [result]: Initial result container
  /// - [searchModel]: Initial search model (must extend [BasePagination])
  /// - [tempSearchModel]: Optional saved search model for reversion
  /// - [isDirty]: Whether filters have unsaved changes
  AbstractListFilterablePaginatedState({
    required super.resultStatus,
    required super.result,
    required super.searchModel,
    super.tempSearchModel,
    super.isDirty,
  });

  /// Creates a copy of this state with optionally modified properties.
  @override
  dynamic copyWith();
}
