class Pagination {
  late int skip;
  late int take;
  int get page => (skip ~/ take) + 1;

  late int _skip;
  late int _take;

  Pagination({
    int? skip,
    int? take,
  }) {
    this.skip = _skip = skip ?? 0;
    this.take = _take = take ?? 10;
  }

  void reset() {
    skip = _skip;
    take = _take;
  }

  void increment() => skip += take;

  void decrement() => skip -= take;

  Map<String, dynamic> toMap() => {
        'page': page,
        'pageSize': take,
      };
}
