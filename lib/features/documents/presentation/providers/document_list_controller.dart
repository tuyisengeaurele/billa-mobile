import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/pagination/paginated_list_controller.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/pagination/paginated_state.dart';
import '../../../auth/presentation/providers/active_business_provider.dart';
import '../../domain/document.dart';
import '../../domain/document_enums.dart';
import 'document_repository_provider.dart';

class DocumentListController extends PaginatedListController<Document> {
  @override
  List<ProviderListenable<Object?>> get rebuildOn => [activeBusinessIdProvider];

  List<DocumentType>? _types;
  DocumentStatus? _statusFilter;

  bool hasFilters({List<DocumentType>? types, DocumentStatus? status}) {
    return listEquals(_types, types) && _statusFilter == status;
  }

  // One refresh for both filters: applying them one after the other would
  // fetch twice and briefly show a list that matches only one of them.
  Future<void> setFilters({List<DocumentType>? types, DocumentStatus? status}) {
    _types = types;
    _statusFilter = status;
    return refresh();
  }

  Future<void> setTypes(List<DocumentType>? types) {
    _types = types;
    return refresh();
  }

  Future<void> setStatusFilter(DocumentStatus? status) {
    _statusFilter = status;
    return refresh();
  }

  @override
  Future<PaginatedResult<Document>> fetchPage({
    required String search,
    required bool includeInactive,
    required int page,
  }) {
    return ref.read(documentRepositoryProvider).list(
          types: _types,
          status: _statusFilter,
          search: search.isEmpty ? null : search,
          page: page,
          pageSize: PaginatedListController.pageSize,
        );
  }
}

final documentListControllerProvider =
    AsyncNotifierProvider<DocumentListController, PaginatedState<Document>>(DocumentListController.new);
