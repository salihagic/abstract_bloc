class Pagination {
  late int skip;
  late int take;
  int get page => (skip ~/ take) + configuration.initialPage;

  late int _skip;
  late int _take;

  Pagination({
    int? skip,
    int? take,
  }) {
    this.skip = _skip = skip ?? 0;
    this.take = _take = take ?? configuration.pageSize;
  }

  void reset() {
    skip = _skip;
    take = _take;
  }

  void increment() => skip += take;

  void decrement() => skip -= take;

  Map<String, dynamic> toJson() => configuration.toJson(page, take);

  static PaginationConfiguration configuration = PaginationConfiguration(
    initialPage: 1,
    pageSize: 10,
    toJson: (page, pageSize) => {
      'page': page,
      'pageSize': pageSize,
    },
  );
}

class PaginationConfiguration {
  final int initialPage;
  final int pageSize;
  final Map<String, dynamic> Function(int page, int pageSize) toJson;

  const PaginationConfiguration({
    this.initialPage = 1,
    this.pageSize = 10,
    required this.toJson,
  });
}
