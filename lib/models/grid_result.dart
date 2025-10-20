import 'package:abstract_bloc/extensions/list_extensions.dart';

/// A class representing the result of a paginated grid, containing a list of items
/// and pagination-related metadata.
class GridResult<TListItem> {
  List<TListItem> items; // The list of items in the current grid result
  bool hasMoreItems; // Indicates if there are more items available for loading
  int numberOfCachedItems = 0; // Number of items cached
  int currentPage; // The current page number
  int startPage; // The start page of the grid result
  int endPage; // The end page of the grid result
  int pageCount; // Total number of pages available
  int pageSize; // Number of items per page
  int rowCount; // Total number of rows available across all pages
  int hasPreviousPage; // Indicator for existence of a previous page (1 or 0)
  int hasNextPage; // Indicator for existence of a next page (1 or 0)
  int hasMultiplePages; // Indicator for existence of multiple pages
  int firstRowOnPage; // Index of the first row on the current page
  int lastRowOnPage; // Index of the last row on the current page
  bool hasItems; // Indicates if the current result contains any items
  String? nextCursor; // Token for fetching the next page, if applicable
  String? previousCursor; // Token for fetching the previous page, if applicable
  dynamic additionalData; // Any additional data that might be needed

  /// Constructs a [GridResult] instance with optional parameters.
  GridResult({
    this.items = const [],
    this.hasMoreItems = true,
    this.currentPage = 0,
    this.startPage = 0,
    this.endPage = 0,
    this.pageCount = 0,
    this.pageSize = 0,
    this.rowCount = 0,
    this.hasPreviousPage = 0,
    this.hasNextPage = 0,
    this.hasMultiplePages = 0,
    this.firstRowOnPage = 0,
    this.lastRowOnPage = 0,
    this.hasItems = true,
    this.nextCursor,
    this.previousCursor,
    this.additionalData,
  }) {
    // Determine whether there are more items based on items count and page size
    hasMoreItems = hasMoreItems || items.abstractBlocListCount == pageSize;
    hasItems = hasItems || items.abstractBlocListIsNotNullOrEmpty;
  }

  /// Maps the properties of another [GridResult] instance to the current instance.
  void map(GridResult<TListItem> other) {
    items = other.items;
    hasMoreItems = other.hasMoreItems;
    currentPage = other.currentPage;
    startPage = other.startPage;
    endPage = other.endPage;
    pageCount = other.pageCount;
    pageSize = other.pageSize;
    rowCount = other.rowCount;
    hasPreviousPage = other.hasPreviousPage;
    hasNextPage = other.hasNextPage;
    hasMultiplePages = other.hasMultiplePages;
    firstRowOnPage = other.firstRowOnPage;
    lastRowOnPage = other.lastRowOnPage;
    hasItems = other.hasItems;
    nextCursor = other.nextCursor;
    previousCursor = other.previousCursor;
    additionalData = other.additionalData;
  }

  /// Factory constructor that creates an instance of [GridResult] from a Map.
  ///
  /// Takes an optional [itemParser] function for custom mapping of items.
  factory GridResult.fromMap(
    Map<dynamic, dynamic> map, [
    TListItem Function(Map<String, dynamic> data)? itemParser,
  ]) {
    final List<TListItem> items =
        (map[GridResultJsonConfiguration.itemsJsonKey] as List<dynamic>?)
            ?.map<TListItem>((x) => itemParser?.call(x) ?? x as TListItem)
            .toList() ??
        [];
    final int pageSize = map[GridResultJsonConfiguration.pageSizeJsonKey] ?? 0;
    final String nextCursor =
        map[GridResultJsonConfiguration.nextCursorJsonKey] ?? '';

    return GridResult<TListItem>(
      items: items,
      hasMoreItems:
          map[GridResultJsonConfiguration.hasMoreItemsJsonKey] ??
          (nextCursor.isNotEmpty || items.abstractBlocListCount == pageSize),
      currentPage: map[GridResultJsonConfiguration.currentPageJsonKey] ?? 0,
      startPage: map[GridResultJsonConfiguration.startPageJsonKey] ?? 0,
      endPage: map[GridResultJsonConfiguration.endPageJsonKey] ?? 0,
      pageCount: map[GridResultJsonConfiguration.pageCountJsonKey] ?? 0,
      pageSize: pageSize,
      rowCount: map[GridResultJsonConfiguration.rowCountJsonKey] ?? 0,
      hasPreviousPage:
          map[GridResultJsonConfiguration.hasPreviousPageJsonKey] ?? 0,
      hasNextPage: map[GridResultJsonConfiguration.hasNextPageJsonKey] ?? 0,
      hasMultiplePages:
          map[GridResultJsonConfiguration.hasMultiplePagesJsonKey] ?? 0,
      firstRowOnPage:
          map[GridResultJsonConfiguration.firstRowOnPageJsonKey] ?? 0,
      lastRowOnPage: map[GridResultJsonConfiguration.lastRowOnPageJsonKey] ?? 0,
      hasItems:
          map[GridResultJsonConfiguration.hasItemsJsonKey] ??
          items.abstractBlocListIsNotNullOrEmpty,
      nextCursor: map[GridResultJsonConfiguration.nextCursorJsonKey],
      previousCursor: map[GridResultJsonConfiguration.previousCursorJsonKey],
      additionalData: map[GridResultJsonConfiguration.additionalDataJsonKey],
    );
  }
}

/// A utility class that provides JSON key configurations for the [GridResult].
class GridResultJsonConfiguration {
  static String itemsJsonKey = 'items';
  static String hasMoreItemsJsonKey = 'hasMoreItems';
  static String currentPageJsonKey = 'currentPage';
  static String startPageJsonKey = 'startPage';
  static String endPageJsonKey = 'endPage';
  static String pageCountJsonKey = 'pageCount';
  static String pageSizeJsonKey = 'pageSize';
  static String rowCountJsonKey = 'rowCount';
  static String hasPreviousPageJsonKey = 'hasPreviousPage';
  static String hasNextPageJsonKey = 'hasNextPage';
  static String hasMultiplePagesJsonKey = 'hasMultiplePages';
  static String firstRowOnPageJsonKey = 'firstRowOnPage';
  static String lastRowOnPageJsonKey = 'lastRowOnPage';
  static String hasItemsJsonKey = 'hasItems';
  static String nextCursorJsonKey = 'nextCursor';
  static String previousCursorJsonKey = 'previousCursor';
  static String additionalDataJsonKey = 'additionalData';

  /// Configures JSON keys for the [GridResult].
  GridResultJsonConfiguration.configure({
    String? itemsJsonKey,
    String? hasMoreItemsJsonKey,
    String? currentPageJsonKey,
    String? startPageJsonKey,
    String? endPageJsonKey,
    String? pageCountJsonKey,
    String? pageSizeJsonKey,
    String? rowCountJsonKey,
    String? hasPreviousPageJsonKey,
    String? hasNextPageJsonKey,
    String? hasMultiplePagesJsonKey,
    String? firstRowOnPageJsonKey,
    String? lastRowOnPageJsonKey,
    String? hasItemsJsonKey,
    String? additionalDataJsonKey,
  }) {
    GridResultJsonConfiguration.itemsJsonKey =
        itemsJsonKey ?? GridResultJsonConfiguration.itemsJsonKey;
    GridResultJsonConfiguration.hasMoreItemsJsonKey =
        hasMoreItemsJsonKey ?? GridResultJsonConfiguration.hasMoreItemsJsonKey;
    GridResultJsonConfiguration.currentPageJsonKey =
        currentPageJsonKey ?? GridResultJsonConfiguration.currentPageJsonKey;
    GridResultJsonConfiguration.startPageJsonKey =
        startPageJsonKey ?? GridResultJsonConfiguration.startPageJsonKey;
    GridResultJsonConfiguration.endPageJsonKey =
        endPageJsonKey ?? GridResultJsonConfiguration.endPageJsonKey;
    GridResultJsonConfiguration.pageCountJsonKey =
        pageCountJsonKey ?? GridResultJsonConfiguration.pageCountJsonKey;
    GridResultJsonConfiguration.pageSizeJsonKey =
        pageSizeJsonKey ?? GridResultJsonConfiguration.pageSizeJsonKey;
    GridResultJsonConfiguration.rowCountJsonKey =
        rowCountJsonKey ?? GridResultJsonConfiguration.rowCountJsonKey;
    GridResultJsonConfiguration.hasPreviousPageJsonKey =
        hasPreviousPageJsonKey ??
        GridResultJsonConfiguration.hasPreviousPageJsonKey;
    GridResultJsonConfiguration.hasNextPageJsonKey =
        hasNextPageJsonKey ?? GridResultJsonConfiguration.hasNextPageJsonKey;
    GridResultJsonConfiguration.hasMultiplePagesJsonKey =
        hasMultiplePagesJsonKey ??
        GridResultJsonConfiguration.hasMultiplePagesJsonKey;
    GridResultJsonConfiguration.firstRowOnPageJsonKey =
        firstRowOnPageJsonKey ??
        GridResultJsonConfiguration.firstRowOnPageJsonKey;
    GridResultJsonConfiguration.lastRowOnPageJsonKey =
        lastRowOnPageJsonKey ??
        GridResultJsonConfiguration.lastRowOnPageJsonKey;
    GridResultJsonConfiguration.hasItemsJsonKey =
        hasItemsJsonKey ?? GridResultJsonConfiguration.hasItemsJsonKey;
    GridResultJsonConfiguration.additionalDataJsonKey =
        additionalDataJsonKey ??
        GridResultJsonConfiguration.additionalDataJsonKey;
  }
}
