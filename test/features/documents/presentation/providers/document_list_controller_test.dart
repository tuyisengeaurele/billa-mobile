import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_list_controller.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

const _customer = DocumentCustomerRef(name: 'Acme');
const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: _customer,
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 1800,
  total: 11800,
  amountPaid: 0,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  test('setStatusFilter refetches from page 1 with the given status', () async {
    final repository = _MockDocumentRepository();
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: null, status: DocumentStatus.draft, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [
      documentRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(documentListControllerProvider.future);

    await container.read(documentListControllerProvider.notifier).setStatusFilter(DocumentStatus.draft);

    final state = container.read(documentListControllerProvider).value!;
    expect(state.items.single.id, 'd1');
  });

  test('setTypes refetches with the given type list', () async {
    final repository = _MockDocumentRepository();
    when(() => repository.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: <Document>[], total: 0, page: 1, pageSize: 20),
    );
    when(() => repository.list(types: [DocumentType.invoice], status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
    final container = ProviderContainer(overrides: [
      documentRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);
    await container.read(documentListControllerProvider.future);

    await container.read(documentListControllerProvider.notifier).setTypes([DocumentType.invoice]);

    final state = container.read(documentListControllerProvider).value!;
    expect(state.items.single.id, 'd1');
  });
}
