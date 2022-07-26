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
  int hasItems;
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
    this.hasItems = 0,
    this.additionalData,
  });

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
}
