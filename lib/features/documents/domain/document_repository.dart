import '../../../core/pagination/paginated_result.dart';
import 'document.dart';
import 'document_draft_input.dart';
import 'document_enums.dart';
import 'payment.dart';
import 'payment_input.dart';

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
  Future<Document> finalize(String id);
  Future<Document> convert(String id);
  Future<String> send(String id, {DocumentLanguage? language});
  Future<void> delete(String id);
  Future<List<int>> fetchPdfBytes(String id, {DocumentLanguage? language});
  Future<Document> recordPayment(String documentId, PaymentInput input);
  Future<Document> voidPayment(String documentId, String paymentId, String reason);
  Future<List<Payment>> listPayments(String documentId);
  Future<Document> writeOff(String documentId, String reason);
  Future<Document> reactivate(String documentId);
  Future<String> uploadPaymentReceipt(List<int> bytes, String filename);
}
