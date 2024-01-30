import 'package:abstract_bloc/extensions/list_extensions.dart';

class GridResult<TListItem> {
  List<TListItem> items;
  bool hasMoreItems;
  int numberOfCachedItems = 0;
  int currentPage;
  int startPage;
  int endPage;
  int pageCount;
  int pageSize;
  int rowCount;
  int hasPreviousPage;
  int hasNextPage;
  int hasMultiplePages;
  int firstRowOnPage;
  int lastRowOnPage;
  bool hasItems;
  dynamic additionalData;

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
    this.additionalData,
  }) {
    hasMoreItems = hasMoreItems || items.count == pageSize;
    hasItems = hasItems || items.isNotNullOrEmpty;
  }

  void map(GridResult other) {
    this.items = other.items as List<TListItem>;
    this.hasMoreItems = other.hasMoreItems;
    this.currentPage = other.currentPage;
    this.startPage = other.startPage;
    this.endPage = other.endPage;
    this.pageCount = other.pageCount;
    this.pageSize = other.pageSize;
    this.rowCount = other.rowCount;
    this.hasPreviousPage = other.hasPreviousPage;
    this.hasNextPage = other.hasNextPage;
    this.hasMultiplePages = other.hasMultiplePages;
    this.firstRowOnPage = other.firstRowOnPage;
    this.lastRowOnPage = other.lastRowOnPage;
    this.hasItems = other.hasItems;
    this.additionalData = other.additionalData;
  }

  factory GridResult.fromMap(Map<dynamic, dynamic> map,
      [TListItem Function(Map<String, dynamic> data)? itemParser]) {
    final List<TListItem> items = map[GridResultJsonConfiguration.itemsJsonKey]
            ?.map<TListItem>((x) => itemParser?.call(x) ?? x as TListItem)
            .toList() ??
        [];
    final int pageSize = map[GridResultJsonConfiguration.pageSizeJsonKey] ?? 0;

    return GridResult<TListItem>(
      items: items,
      hasMoreItems: map[GridResultJsonConfiguration.hasMoreItemsJsonKey] ??
          items.count == pageSize,
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
      hasItems: map[GridResultJsonConfiguration.hasItemsJsonKey] ??
          items.isNotNullOrEmpty,
      additionalData: map[GridResultJsonConfiguration.additionalDataJsonKey],
    );
  }
}

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
  static String additionalDataJsonKey = 'additionalData';

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
    GridResultJsonConfiguration.firstRowOnPageJsonKey = firstRowOnPageJsonKey ??
        GridResultJsonConfiguration.firstRowOnPageJsonKey;
    GridResultJsonConfiguration.lastRowOnPageJsonKey = lastRowOnPageJsonKey ??
        GridResultJsonConfiguration.lastRowOnPageJsonKey;
    GridResultJsonConfiguration.hasItemsJsonKey =
        hasItemsJsonKey ?? GridResultJsonConfiguration.hasItemsJsonKey;
    GridResultJsonConfiguration.additionalDataJsonKey = additionalDataJsonKey ??
        GridResultJsonConfiguration.additionalDataJsonKey;
  }
}
