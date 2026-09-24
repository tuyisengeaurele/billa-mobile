class PaginatedResult<T> {
  const PaginatedResult({required this.results, required this.total, required this.page, required this.pageSize});

  final List<T> results;
  final int total;
  final int page;
  final int pageSize;
}
