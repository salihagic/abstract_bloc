/// An abstract base class representing an event related to an item.
abstract class AbstractItemEvent {}

/// An event representing a request to load an item, optionally with a search model.
///
/// This class extends [AbstractItemEvent] and is used to trigger the loading
/// of item data, allowing for optional filtering with the provided search model.
class AbstractItemLoadEvent<TSearchModel> extends AbstractItemEvent {
  /// An optional search model that can be used to filter the items being loaded.
  TSearchModel? searchModel;

  /// Constructor for creating an instance of [AbstractItemLoadEvent].
  ///
  /// The [searchModel] parameter is optional and can be provided to specify
  /// how to filter loaded items.
  AbstractItemLoadEvent({this.searchModel});
}
