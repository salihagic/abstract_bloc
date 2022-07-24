import 'package:abstract_bloc/extensions/_all.dart';

class GridResult<TListItem> {
  List<TListItem> items;
  bool hasMoreItems;
  int numberOfCachedItems;
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
    this.numberOfCachedItems = 0,
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

  void removeCachedItemsFromEnd() {
    items.removeLastItems(numberOfCachedItems);
    numberOfCachedItems = 0;
  }
}
