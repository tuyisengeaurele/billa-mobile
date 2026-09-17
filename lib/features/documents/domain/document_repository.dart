import '../../../core/pagination/paginated_result.dart';
import 'document.dart';
import 'document_enums.dart';

abstract class DocumentRepository {
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  Future<Document> get(String id);
}
