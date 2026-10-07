# Phase 4c: Finalize, PDF, Send, Conversion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user finalize a draft (permanent number, locked editing),
share a finalized document as a PDF, email it to the customer, convert a
finalized Proforma/Quote into a draft Invoice, and delete an unwanted
draft.

**Architecture:** Five new one-shot `DocumentRepository` methods, each a
thin wrapper over its endpoint. No new controller class — these are
fire-and-refresh actions, so `DocumentDetailScreen` gets local
`_actionInProgress`/`_actionError` state and calls the repository
directly, the same pattern `CustomerDetailScreen`'s toggle-active handler
already established in Phase 3. One pure helper maps server error codes
to user-facing messages.

**Tech Stack:** Flutter, `flutter_riverpod` 2.6.1, `go_router`, `dio`,
`share_plus` (new), `path_provider` (already a dependency).

**Spec:** `docs/superpowers/specs/2026-09-19-phase4c-finalize-pdf-send-convert-design.md`

## Global Constraints

- Commits authored as `Ange Aurele TUYISENGE <tuyisengeauris@gmail.com>`; never a `Co-authored-by` trailer; no tooling attribution anywhere.
- Small, single-sentence, conventional-commit-style messages, one logical change per commit.
- Comments explain *why*, never *what*.
- No dead ends: every action has a specific, actionable error message and a retry path — never a silent failure or a generic "something went wrong" when a real cause is known.
- Every task ends with `flutter analyze` clean and `flutter test` passing.
- The public/customer-facing decline flow, the `requireApprovalToFinalize` setting itself, reminder toggling, and payments/write-off/reactivate are all out of scope — see the spec's Non-goals.

---

### Task 1: Repository actions — finalize, convert, send, delete, PDF bytes

**Files:**
- Modify: `lib/features/documents/domain/document_repository.dart`
- Modify: `lib/features/documents/data/document_repository_impl.dart`
- Modify: `test/features/documents/data/document_repository_impl_test.dart`

**Interfaces:**
- Consumes: `Document` (Phase 4a).
- Produces: `DocumentRepository.finalize(id)`, `.convert(id)`,
  `.send(id)` (returns the new `sentAt` string), `.delete(id)`,
  `.fetchPdfBytes(id)` (returns `List<int>`).

- [ ] **Step 1: Write the failing tests**

Add to `test/features/documents/data/document_repository_impl_test.dart`:

```dart
  test('finalize posts to /finalize and returns the finalized document', () async {
    final options = RequestOptions(path: '/documents/d1/finalize');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/finalize')).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.finalize('d1');

    expect(document.id, 'd1');
  });

  test('convert posts to /convert and returns the new invoice', () async {
    final options = RequestOptions(path: '/documents/d1/convert');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/convert')).thenAnswer(
      (_) async => _response(201, {'document': _documentJson()}, options),
    );

    final document = await repository.convert('d1');

    expect(document.id, 'd1');
  });

  test('send posts to /send and returns the sentAt timestamp', () async {
    final options = RequestOptions(path: '/documents/d1/send');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/send')).thenAnswer(
      (_) async => _response(200, {'sentAt': '2026-01-02T00:00:00.000Z'}, options),
    );

    final sentAt = await repository.send('d1');

    expect(sentAt, '2026-01-02T00:00:00.000Z');
  });

  test('delete sends a DELETE request', () async {
    final options = RequestOptions(path: '/documents/d1');
    when(() => dio.delete<void>('/documents/d1')).thenAnswer(
      (_) async => Response(statusCode: 204, requestOptions: options),
    );

    await repository.delete('d1');

    verify(() => dio.delete<void>('/documents/d1')).called(1);
  });

  test('fetchPdfBytes requests bytes and returns the raw response', () async {
    final options = RequestOptions(path: '/documents/d1/pdf');
    when(() => dio.get<List<int>>('/documents/d1/pdf', options: any(named: 'options'))).thenAnswer(
      (_) async => Response(statusCode: 200, data: [1, 2, 3], requestOptions: options),
    );

    final bytes = await repository.fetchPdfBytes('d1');

    expect(bytes, [1, 2, 3]);
  });
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: FAIL — none of the five methods exist yet.

- [ ] **Step 3: Add the methods to the abstract repository**

```dart
// lib/features/documents/domain/document_repository.dart
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
  Future<Document> finalize(String id);
  Future<Document> convert(String id);
  Future<String> send(String id);
  Future<void> delete(String id);
  Future<List<int>> fetchPdfBytes(String id);
}
```

- [ ] **Step 4: Implement them**

Add to `lib/features/documents/data/document_repository_impl.dart`:

```dart
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
  Future<String> send(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/documents/$id/send');
    return response.data!['sentAt'] as String;
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<void>('/documents/$id');
  }

  @override
  Future<List<int>> fetchPdfBytes(String id) async {
    final response = await _dio.get<List<int>>('/documents/$id/pdf', options: Options(responseType: ResponseType.bytes));
    return response.data!;
  }
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/documents/data/document_repository_impl_test.dart
```

Expected: PASS (11 tests).

- [ ] **Step 6: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/domain/document_repository.dart lib/features/documents/data/document_repository_impl.dart test/features/documents/data/document_repository_impl_test.dart
git commit -m "feat: add finalize, convert, send, delete, and pdf-fetch to the document repository"
```

---

### Task 2: Error-code-to-message mapping

**Files:**
- Create: `lib/features/documents/presentation/document_action_errors.dart`
- Test: `test/features/documents/presentation/document_action_errors_test.dart`

**Interfaces:**
- Produces: `String describeDocumentActionError(Object error)`.

This lives in the presentation layer, not domain, because it's aware of
`DioException` — the domain/data layers stay Dio-agnostic (the abstract
`DocumentRepository` has no Dio dependency at all), but nothing else in
this app currently translates transport errors into domain exception
types, so this is a UI-facing concern, not a new domain abstraction.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/documents/presentation/document_action_errors_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/presentation/document_action_errors.dart';

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  test('maps every known error code to its message', () {
    expect(describeDocumentActionError(_error('no_lines')), 'Add at least one line before finalizing');
    expect(
      describeDocumentActionError(_error('finalize_requires_approval')),
      'Only the business owner can finalize documents',
    );
    expect(describeDocumentActionError(_error('already_finalized')), 'This document was already finalized');
    expect(
      describeDocumentActionError(_error('not_convertible')),
      "This document type can't be converted to an invoice",
    );
    expect(describeDocumentActionError(_error('not_finalized')), 'Finalize this document first');
    expect(describeDocumentActionError(_error('already_converted')), 'This was already converted to an invoice');
    expect(describeDocumentActionError(_error('already_declined')), 'The customer already declined this');
    expect(describeDocumentActionError(_error('customer_has_no_email')), 'This customer has no email on file');
    expect(describeDocumentActionError(_error('pdf_render_failed')), "Couldn't generate the PDF");
    expect(describeDocumentActionError(_error('email_send_failed')), "Couldn't send the email");
  });

  test('falls back to a generic message for an unknown code', () {
    expect(describeDocumentActionError(_error('something_else')), 'Something went wrong — try again');
  });

  test('falls back to a generic message for a non-Dio error', () {
    expect(describeDocumentActionError(Exception('boom')), 'Something went wrong — try again');
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/document_action_errors_test.dart
```

Expected: FAIL — `document_action_errors.dart` doesn't exist yet.

- [ ] **Step 3: Implement `describeDocumentActionError`**

```dart
// lib/features/documents/presentation/document_action_errors.dart
import 'package:dio/dio.dart';

String describeDocumentActionError(Object error) {
  final code = error is DioException ? (error.response?.data?['error'] as String?) : null;
  return switch (code) {
    'no_lines' => 'Add at least one line before finalizing',
    'finalize_requires_approval' => 'Only the business owner can finalize documents',
    'already_finalized' => 'This document was already finalized',
    'not_convertible' => "This document type can't be converted to an invoice",
    'not_finalized' => 'Finalize this document first',
    'already_converted' => 'This was already converted to an invoice',
    'already_declined' => 'The customer already declined this',
    'customer_has_no_email' => 'This customer has no email on file',
    'pdf_render_failed' => "Couldn't generate the PDF",
    'email_send_failed' => "Couldn't send the email",
    _ => 'Something went wrong — try again',
  };
}
```

- [ ] **Step 4: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/document_action_errors_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 5: Analyze and commit**

```bash
flutter analyze
git add lib/features/documents/presentation/document_action_errors.dart test/features/documents/presentation/document_action_errors_test.dart
git commit -m "feat: map document action error codes to user-facing messages"
```

---

### Task 3: Wire finalize/convert/send/share/delete into `DocumentDetailScreen`

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/features/documents/presentation/screens/document_detail_screen.dart`
- Modify: `test/features/documents/presentation/screens/document_detail_screen_test.dart`

**Interfaces:**
- Consumes: `DocumentRepository` (Task 1), `describeDocumentActionError`
  (Task 2), `documentListControllerProvider` (Phase 4a), `AppButton`
  (Phase 1), `share_plus`'s `SharePlus.instance.share`, `path_provider`'s
  `getTemporaryDirectory`.
- Produces: context-sensitive Finalize / Convert to Invoice / Share PDF
  / Send buttons and an overflow Delete action on `DocumentDetailScreen`.

- [ ] **Step 1: Add the `share_plus` dependency**

```bash
flutter pub add share_plus
```

Expected: adds `share_plus: ^13.3.0` (the version it resolves to today)
to `pubspec.yaml` — `path_provider` is already a dependency, so this is
the only new package this phase needs.

- [ ] **Step 2: Write the failing tests**

Add to `test/features/documents/presentation/screens/document_detail_screen_test.dart`
(reusing its existing `_customer`/`repository`/`buildApp` from Phase
4a/4b — `buildApp()`'s router already maps `/documents/:id` to a
placeholder "converted-from screen" `Scaffold`, which doubles as the
target for the convert-navigation assertion below):

```dart
  testWidgets('Finalize appears for a draft and reloads on success', (tester) async {
    const draft = Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
      lines: [_line],
    );
    when(() => repository.get('d1')).thenAnswer((_) async => draft);
    when(() => repository.finalize('d1')).thenAnswer(
      (_) async => draft.copyWith(status: DocumentStatus.finalized, number: 'INV-0001'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finalize'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalize').last);
    await tester.pumpAndSettle();

    verify(() => repository.finalize('d1')).called(1);
    verify(() => repository.get('d1')).called(2); // initial load + reload after finalize
  });

  testWidgets('Convert to Invoice appears for a finalized proforma with no convertedTo, and navigates on success', (tester) async {
    const proforma = Document(
      id: 'd1',
      type: DocumentType.proforma,
      number: 'PRO-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    const newInvoice = Document(
      id: 'd2',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => proforma);
    when(() => repository.convert('d1')).thenAnswer((_) async => newInvoice);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Convert to Invoice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert').last);
    await tester.pumpAndSettle();

    expect(find.text('converted-from screen'), findsOneWidget);
  });

  testWidgets('Send is disabled when the customer has no email', (tester) async {
    const noEmailCustomer = DocumentCustomerRef(name: 'Acme');
    const finalized = Document(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerId: 'c1',
      customer: noEmailCustomer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => finalized);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final sendButton = tester.widget<OutlinedButton>(find.byKey(const Key('document-send')));
    expect(sendButton.onPressed, isNull);
  });

  testWidgets('Send confirms and reloads on success when the customer has an email', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.send('d1')).thenAnswer((_) async => '2026-01-02T00:00:00.000Z');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('document-send')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send').last);
    await tester.pumpAndSettle();

    verify(() => repository.send('d1')).called(1);
    verify(() => repository.get('d1')).called(2);
  });

  testWidgets('Share PDF fetches the document bytes', (tester) async {
    when(() => repository.get('d1')).thenAnswer((_) async => _document);
    when(() => repository.fetchPdfBytes('d1')).thenAnswer((_) async => [1, 2, 3]);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('document-share-pdf')));
    await tester.pumpAndSettle();

    // share_plus/path_provider use platform channels this test harness
    // doesn't provide, so whatever happens after the fetch isn't asserted —
    // only that the action actually requested the bytes.
    verify(() => repository.fetchPdfBytes('d1')).called(1);
  });

  testWidgets('the overflow Delete action appears only for drafts, confirms, and pops back to the list', (tester) async {
    const draft = Document(
      id: 'd1',
      type: DocumentType.invoice,
      status: DocumentStatus.draft,
      customerId: 'c1',
      customer: _customer,
      issueDate: '2026-01-01T00:00:00.000Z',
      subtotal: 0,
      taxTotal: 0,
      total: 0,
      amountPaid: 0,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    );
    when(() => repository.get('d1')).thenAnswer((_) async => draft);
    when(() => repository.delete('d1')).thenAnswer((_) async {});
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('list screen'))),
      GoRoute(path: '/documents/d1', builder: (context, state) => const DocumentDetailScreen(documentId: 'd1')),
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await tester.pumpAndSettle();
    router.push('/documents/d1');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('list screen'), findsOneWidget);
    verify(() => repository.delete('d1')).called(1);
  });
```

The existing top-of-file `_document` fixture already has
`customer: _customer` with `email: 'acme@example.com'` and
`status: DocumentStatus.finalized` (from Phase 4a), so it's reused
as-is for the "Send confirms..." and "Share PDF..." cases above.

- [ ] **Step 3: Run it to confirm it fails**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: FAIL — none of the buttons/menu exist yet.

- [ ] **Step 4: Implement the actions and UI**

Add these imports to `lib/features/documents/presentation/screens/document_detail_screen.dart`:

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../document_action_errors.dart';
import '../providers/document_list_controller.dart';
```

(`app_colors.dart`/`app_theme.dart` provide `AppColors`/`AppRadii`, used
by the error banner below — the same two imports `ErrorState` already
uses for the same purpose.)

Replace the `_DocumentDetailScreenState` class with:

```dart
class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late Future<Document> _future;
  bool _actionInProgress = false;
  String? _actionError;
  Future<void> Function()? _lastAction;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Document> _load() => ref.read(documentRepositoryProvider).get(widget.documentId);

  void _reload() => setState(() {
        _future = _load();
      });

  Future<void> _runAction(Future<void> Function() action) async {
    _lastAction = action;
    setState(() {
      _actionInProgress = true;
      _actionError = null;
    });
    try {
      await action();
    } catch (e) {
      setState(() => _actionError = describeDocumentActionError(e));
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<bool> _confirm(String title, String? content, String confirmLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content == null ? null : Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmLabel)),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _finalize() async {
    if (!await _confirm(
      'Finalize this document?',
      'It will get a permanent number and can no longer be edited.',
      'Finalize',
    )) {
      return;
    }
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).finalize(widget.documentId);
      _reload();
    });
  }

  Future<void> _convert() async {
    if (!await _confirm('Convert to invoice?', 'Creates a new draft invoice with the same lines.', 'Convert')) {
      return;
    }
    await _runAction(() async {
      final invoice = await ref.read(documentRepositoryProvider).convert(widget.documentId);
      if (mounted) context.push('/documents/${invoice.id}');
    });
  }

  Future<void> _send(String email) async {
    if (!await _confirm('Send to $email?', null, 'Send')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).send(widget.documentId);
      _reload();
    });
  }

  Future<void> _sharePdf() async {
    await _runAction(() async {
      final bytes = await ref.read(documentRepositoryProvider).fetchPdfBytes(widget.documentId);
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/${widget.documentId}.pdf').writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    });
  }

  Future<void> _delete() async {
    if (!await _confirm("Delete this draft?", "This can't be undone.", 'Delete')) return;
    await _runAction(() async {
      await ref.read(documentRepositoryProvider).delete(widget.documentId);
      ref.invalidate(documentListControllerProvider);
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Document>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Document')),
            body: ErrorState(
              message: "Couldn't load this document",
              onRetry: () => setState(() {
                _future = _load();
              }),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Document')),
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: [LoadingSkeleton(height: 24), SizedBox(height: 12), LoadingSkeleton(height: 200)]),
            ),
          );
        }
        final document = snapshot.data!;
        final isDraft = document.status == DocumentStatus.draft;
        final isFinalized = document.status == DocumentStatus.finalized;
        final isConvertible =
            isFinalized && (document.type == DocumentType.proforma || document.type == DocumentType.quote) &&
                document.convertedTo == null;
        final colors = Theme.of(context).extension<AppColors>()!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Document'),
            actions: [
              if (isDraft)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/documents/${document.id}/edit'),
                ),
              if (isDraft)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') _delete();
                  },
                  itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(document.number ?? 'Draft', style: Theme.of(context).textTheme.headlineSmall),
                    DocumentStatusPill(status: document.status, paymentStatus: document.paymentStatus),
                  ],
                ),
                const SizedBox(height: 8),
                Text(document.customer.name),
                if (document.customer.email != null) Text(document.customer.email!),
                const SizedBox(height: 16),
                Text('Issued ${document.issueDate.split('T').first}'),
                if (document.dueDate != null) Text('Due ${document.dueDate!.split('T').first}'),
                if (document.notes != null) ...[
                  const SizedBox(height: 16),
                  Text(document.notes!),
                ],
                const SizedBox(height: 24),
                for (final line in document.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.description),
                              Text(
                                '${line.quantity.toStringAsFixed(2)} × RWF ${line.unitPrice}'
                                '${_lineDiscountLabel(line).isEmpty ? '' : ' · ${_lineDiscountLabel(line)}'}',
                              ),
                            ],
                          ),
                        ),
                        MoneyText(line.lineTotal),
                      ],
                    ),
                  ),
                const Divider(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal'), MoneyText(document.subtotal)]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tax'), MoneyText(document.taxTotal)]),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.titleMedium),
                    MoneyText(document.total, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                if (document.convertedFrom != null) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.push('/documents/${document.convertedFrom!.id}'),
                    child: Text('Converted from ${document.convertedFrom!.number ?? document.convertedFrom!.id}'),
                  ),
                ],
                if (document.convertedTo != null)
                  TextButton(
                    onPressed: () => context.push('/documents/${document.convertedTo!.id}'),
                    child: Text('Converted to ${document.convertedTo!.number ?? document.convertedTo!.id}'),
                  ),
                if (document.referencedDocument != null)
                  TextButton(
                    onPressed: () => context.push('/documents/${document.referencedDocument!.id}'),
                    child: Text('References ${document.referencedDocument!.number ?? document.referencedDocument!.id}'),
                  ),
                if (_actionError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(AppRadii.small)),
                    child: Row(
                      children: [
                        Expanded(child: Text(_actionError!, style: TextStyle(color: colors.error))),
                        TextButton(
                          onPressed: _lastAction == null ? null : () => _runAction(_lastAction!),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (isDraft)
                  AppButton(label: 'Finalize', isLoading: _actionInProgress, onPressed: _finalize),
                if (isConvertible) ...[
                  const SizedBox(height: 8),
                  AppButton(label: 'Convert to Invoice', isLoading: _actionInProgress, onPressed: _convert),
                ],
                if (isFinalized) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('document-share-pdf'),
                          onPressed: _actionInProgress ? null : _sharePdf,
                          child: const Text('Share PDF'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Tooltip(
                          message: document.customer.email == null ? 'Add an email for this customer first' : '',
                          child: OutlinedButton(
                            key: const Key('document-send'),
                            onPressed: (_actionInProgress || document.customer.email == null)
                                ? null
                                : () => _send(document.customer.email!),
                            child: const Text('Send'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

```bash
flutter test test/features/documents/presentation/screens/document_detail_screen_test.dart
```

Expected: PASS (10 tests).

- [ ] **Step 6: Run the full suite, analyze, and commit**

```bash
flutter test
flutter analyze
git add pubspec.yaml pubspec.lock lib/features/documents/presentation/screens/document_detail_screen.dart test/features/documents/presentation/screens/document_detail_screen_test.dart
git commit -m "feat: add finalize, convert, send, share, and delete actions to the document detail screen"
```

---

### Task 4: Final verification

**Files:** none created — this task only runs checks and fixes anything they surface.

- [ ] **Step 1: Static analysis**

```bash
flutter analyze
```

Expected: "No issues found!" — fix anything reported and re-run until clean.

- [ ] **Step 2: Full test suite**

```bash
flutter test
```

Expected: every test from Tasks 1–3 passes, plus all of Phases 1–4b's existing tests still pass unchanged.

- [ ] **Step 3: Android debug build**

```bash
flutter build apk --debug
```

Expected: builds successfully.

- [ ] **Step 4: Note the iOS build status**

Same as every prior phase: iOS build verification is deferred to macOS (this branch is built on Windows).

- [ ] **Step 5: Commit any fixes from Steps 1–2**

Only if something needed fixing:

```bash
git add -A
git commit -m "fix: resolve issues from phase 4c verification"
```

If nothing needed fixing, this step is a no-op.

---

## Definition of done for this plan

`flutter analyze` is clean, `flutter test` passes in full, `flutter build
apk --debug` succeeds, and a manual run shows: open a draft → Finalize
(with confirmation) → the document now has a number and a Finalized
pill → Share PDF hands off to the native share sheet → Send (disabled
when the customer has no email, confirms and succeeds when they do) →
for a finalized Proforma/Quote, Convert to Invoice creates and opens a
new draft invoice with the same lines → back on a draft, the overflow
menu's Delete (with confirmation) removes it and returns to a list that
no longer shows it. Every failure path (no lines, requires-approval,
not-convertible, no-email, render/send failures) shows its specific
message with a working Retry, never a silent failure.
