/// An abstract class that defines the base for all list-related events.
///
/// This serves as a parent class for more specific events related to loading,
/// refreshing, and loading more items in a list managed by a BLoC or Cubit.
abstract class AbstractListEvent {}

/// An event that signifies a request to load data into a list.
///
/// This event can optionally include a search model that helps to filter
/// or query the data when loading. It is generic to allow flexibility with
/// different types of search models.
///
/// [TSearchModel] - The type of the search model used to filter data.
///
/// Example usage:
/// ```dart
/// AbstractListLoadEvent<MySearchModel>(
///   searchModel: MySearchModel(query: 'search term'),
/// );
/// ```
class AbstractListLoadEvent<TSearchModel> extends AbstractListEvent {
  /// An optional search model that can be used to filter or refine the data load.
  TSearchModel? searchModel;

  /// Constructor that allows initializing this event with an optional
  /// search model.
  AbstractListLoadEvent({this.searchModel});
}

/// An event that signifies a request to refresh the currently loaded list data.
///
/// This event can be triggered by user actions such as pulling to refresh
/// or pressing a refresh button. It does not carry any additional data
/// since the current state can be restored without extra parameters.
///
/// Example usage:
/// ```dart
/// AbstractListRefreshEvent();
/// ```
class AbstractListRefreshEvent extends AbstractListEvent {}

/// An event that signifies a request to load more data into the list.
///
/// This is typically used for paginated lists where more items are loaded
/// as the user scrolls to the end of the currently displayed items. This
/// event does not carry additional data, functioning as a signal for the
/// loading mechanism to fetch the next set of items.
///
/// Example usage:
/// ```dart
/// AbstractListLoadMoreEvent();
/// ```
class AbstractListLoadMoreEvent extends AbstractListEvent {}
