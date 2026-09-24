import '../../../core/pagination/paginated_result.dart';
import 'document.dart';
import 'document_draft_input.dart';
import 'document_enums.dart';

abstract class DocumentRepository {
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    String? customerId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Document> get(String id);
  Future<Document> create(DocumentDraftInput input);
  Future<Document> update(String id, DocumentDraftInput input);
}
