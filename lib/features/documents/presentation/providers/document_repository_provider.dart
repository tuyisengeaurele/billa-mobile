import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/document_repository_impl.dart';
import '../../domain/document_repository.dart';
import '../../../../core/network/api_client_provider.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(ref.watch(apiClientProvider).dio);
});
