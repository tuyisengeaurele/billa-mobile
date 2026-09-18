import 'package:dio/dio.dart';
import '../domain/outstanding_invoice.dart';
import '../domain/receivables_repository.dart';

class ReceivablesRepositoryImpl implements ReceivablesRepository {
  ReceivablesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<OutstandingInvoice>> list() async {
    final response = await _dio.get<Map<String, dynamic>>('/receivables');
    return (response.data!['results'] as List)
        .map((json) => OutstandingInvoice.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
