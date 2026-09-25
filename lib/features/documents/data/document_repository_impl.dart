import 'package:dio/dio.dart';
import '../../../core/pagination/paginated_result.dart';
import '../domain/document.dart';
import '../domain/document_draft_input.dart';
import '../domain/document_enums.dart';
import '../domain/document_repository.dart';
import '../domain/payment.dart';
import '../domain/payment_input.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedResult<Document>> list({
    List<DocumentType>? types,
    DocumentStatus? status,
    String? search,
    String? customerId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents', queryParameters: {
      if (types != null && types.isNotEmpty) 'type': types.map(documentTypeToJson).join(','),
      if (status != null) 'status': documentStatusToJson(status),
      if (search != null && search.isNotEmpty) 'search': search,
      if (customerId != null) 'customerId': customerId,
      'page': page,
      'pageSize': pageSize,
    });
    final data = response.data!;
    final results = (data['results'] as List)
        .map((json) => Document.fromJson(json as Map<String, dynamic>))
        .toList();
    return PaginatedResult(
      results: results,
      total: data['total'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  @override
  Future<Document> get(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents/$id');
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> create(DocumentDraftInput input) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents', data: input.toJson());
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> update(String id, DocumentDraftInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>('/documents/$id', data: input.toJson());
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> finalize(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$id/finalize');
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> convert(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$id/convert');
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<String> send(String id, {DocumentLanguage? language}) async {
    final response = language == null
        ? await _dio.post<Map<String, dynamic>>('/documents/$id/send')
        : await _dio.post<Map<String, dynamic>>(
            '/documents/$id/send',
            data: {'language': documentLanguageToJson(language)},
          );
    return response.data!['sentAt'] as String;
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<void>('/documents/$id');
  }

  @override
  Future<List<int>> fetchPdfBytes(String id, {DocumentLanguage? language}) async {
    final options = Options(responseType: ResponseType.bytes);
    final response = language == null
        ? await _dio.get<List<int>>('/documents/$id/pdf', options: options)
        : await _dio.get<List<int>>(
            '/documents/$id/pdf',
            queryParameters: {'language': documentLanguageToJson(language)},
            options: options,
          );
    return response.data!;
  }

  @override
  Future<Document> recordPayment(String documentId, PaymentInput input) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$documentId/payments', data: input.toJson());
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> voidPayment(String documentId, String paymentId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/documents/$documentId/payments/$paymentId/void',
      data: {'voidReason': reason},
    );
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<List<Payment>> listPayments(String documentId) async {
    final response = await _dio.get<Map<String, dynamic>>('/documents/$documentId/payments');
    return (response.data!['payments'] as List).map((json) => Payment.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Document> writeOff(String documentId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/documents/$documentId/write-off',
      data: {'writeOffReason': reason},
    );
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<Document> reactivate(String documentId) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$documentId/reactivate');
    return Document.fromJson(response.data!['document'] as Map<String, dynamic>);
  }

  @override
  Future<String> uploadPaymentReceipt(List<int> bytes, String filename) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/documents/payments/receipt',
      data: FormData.fromMap({'receipt': MultipartFile.fromBytes(bytes, filename: filename)}),
    );
    return response.data!['url'] as String;
  }
}
