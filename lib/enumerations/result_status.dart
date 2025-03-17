/// An enumeration representing the various statuses of a result in a data-fetching context.
enum ResultStatus {
  /// The data is currently being loaded.
  loading,

  /// An error has occurred while trying to load the data.
  error,

  /// Cached data has been loaded successfully.
  loadedCached,

  /// Data has been loaded successfully from the source.
  loaded,
}
