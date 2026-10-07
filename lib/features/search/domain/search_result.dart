import '../../documents/domain/document_enums.dart';

enum SearchResultType { customer, item, document }

class SearchResult {
  const SearchResult({
    required this.type,
    required this.id,
    required this.label,
    required this.sublabel,
    this.documentType,
  });

  final SearchResultType type;
  final String id;
  final String label;
  final String sublabel;
  final DocumentType? documentType;

  /// Null for a result type this build does not know, so the repository can
  /// skip it rather than fail the whole search.
  static SearchResult? fromJson(Map<String, dynamic> json) {
    final type = switch (json['type']) {
      'customer' => SearchResultType.customer,
      'item' => SearchResultType.item,
      'document' => SearchResultType.document,
      _ => null,
    };
    if (type == null) return null;
    final documentType = json['documentType'] as String?;
    return SearchResult(
      type: type,
      id: json['id'] as String,
      label: json['label'] as String,
      sublabel: (json['sublabel'] as String?) ?? '',
      documentType: documentType == null ? null : documentTypeFromJson(documentType),
    );
  }

  /// Where a tap goes. The backend's own hrefs point at web pages (a customer
  /// statement, the items page), so mobile maps each type to its own screen.
  String get route => switch (type) {
        SearchResultType.customer => '/customers/$id',
        SearchResultType.item => '/items',
        SearchResultType.document => '/documents/$id',
      };
}
