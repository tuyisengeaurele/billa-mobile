import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/media/image_picker_provider.dart';
import 'package:billa_mobile/core/media/photo_picker.dart';
import 'package:billa_mobile/core/platform/link_launcher.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/attachments_section.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

DocumentAttachment _file(String id, {String name = 'po.png', int size = 2048, String type = 'image/png'}) =>
    DocumentAttachment(
      id: id,
      fileName: name,
      url: '/uploads/b1/$name',
      contentType: type,
      sizeBytes: size,
      createdAt: '2026-01-02T00:00:00.000Z',
    );

void main() {
  late _MockDocumentRepository repository;
  late List<PhotoSource> asked;
  late List<Uri> opened;
  PickedImage? picked;
  Object? pickerError;
  var canOpen = true;

  setUp(() {
    repository = _MockDocumentRepository();
    asked = [];
    opened = [];
    picked = (bytes: [1, 2, 3], name: 'photo.jpg');
    pickerError = null;
    canOpen = true;
  });

  Widget build(List<DocumentAttachment> initial) => ProviderScope(
        overrides: [
          documentRepositoryProvider.overrideWithValue(repository),
          photoPickerProvider.overrideWithValue((source) async {
            asked.add(source);
            if (pickerError != null) throw pickerError!;
            return picked;
          }),
          externalUrlOpenerProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return canOpen;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: SingleChildScrollView(child: AttachmentsSection(documentId: 'd1', initial: initial))),
        ),
      );

  DioException offline() => DioException(
        requestOptions: RequestOptions(path: '/documents/d1/attachments'),
        type: DioExceptionType.connectionError,
      );

  testWidgets('lists each file with its size and how many of the five are used', (tester) async {
    await tester.pumpWidget(build([_file('a1'), _file('a2', name: 'pod.png', size: 3 * 1024 * 1024)]));

    expect(find.text('po.png'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);
    expect(find.text('3.0 MB'), findsOneWidget);
    expect(find.text('2 of 5'), findsOneWidget);
  });

  testWidgets('says what attachments are for when there are none, with the add action', (tester) async {
    await tester.pumpWidget(build([]));

    expect(find.text('Keep a purchase order or proof of delivery with this document.'), findsOneWidget);
    expect(find.byKey(const Key('attachment-add')), findsOneWidget);
  });

  testWidgets('adding from the camera uploads the photo and lists it', (tester) async {
    when(() => repository.uploadAttachment('d1', [1, 2, 3], 'photo.jpg'))
        .thenAnswer((_) async => _file('a9', name: 'photo.jpg'));
    await tester.pumpWidget(build([]));

    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(asked, [PhotoSource.camera]);
    verify(() => repository.uploadAttachment('d1', [1, 2, 3], 'photo.jpg')).called(1);
    expect(find.text('photo.jpg'), findsOneWidget);
  });

  testWidgets('adding from the gallery asks the gallery', (tester) async {
    when(() => repository.uploadAttachment(any(), any(), any())).thenAnswer((_) async => _file('a9'));
    await tester.pumpWidget(build([]));

    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(asked, [PhotoSource.gallery]);
  });

  testWidgets('backing out of the picker uploads nothing', (tester) async {
    picked = null;
    await tester.pumpWidget(build([]));

    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.uploadAttachment(any(), any(), any()));
  });

  testWidgets('a failed upload keeps the list, says why, and Retry uploads the same photo', (tester) async {
    var failing = true;
    when(() => repository.uploadAttachment('d1', [1, 2, 3], 'photo.jpg')).thenAnswer((_) async {
      if (failing) throw offline();
      return _file('a9', name: 'photo.jpg');
    });
    await tester.pumpWidget(build([_file('a1')]));

    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('po.png'), findsOneWidget);

    failing = false;
    await tester.tap(find.byKey(const Key('attachment-retry')));
    await tester.pumpAndSettle();

    expect(find.text('photo.jpg'), findsOneWidget);
    expect(find.text('Check your connection and try again'), findsNothing);
    verify(() => repository.uploadAttachment('d1', [1, 2, 3], 'photo.jpg')).called(2);
  });

  testWidgets('at five files the add action goes and the screen says why', (tester) async {
    await tester.pumpWidget(build([for (var i = 0; i < 5; i++) _file('a$i', name: 'f$i.png')]));

    expect(find.byKey(const Key('attachment-add')), findsNothing);
    expect(find.text('A document can have 5 files. Remove one to add another'), findsOneWidget);
  });

  testWidgets('removing asks first, then deletes and drops the row', (tester) async {
    when(() => repository.deleteAttachment('d1', 'a1')).thenAnswer((_) async {});
    await tester.pumpWidget(build([_file('a1')]));

    await tester.tap(find.byKey(const Key('attachment-remove-a1')));
    await tester.pumpAndSettle();
    expect(find.text('Remove this file?'), findsOneWidget);
    verifyNever(() => repository.deleteAttachment(any(), any()));

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    verify(() => repository.deleteAttachment('d1', 'a1')).called(1);
    expect(find.text('po.png'), findsNothing);
  });

  testWidgets('cancelling the question keeps the file', (tester) async {
    await tester.pumpWidget(build([_file('a1')]));

    await tester.tap(find.byKey(const Key('attachment-remove-a1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.deleteAttachment(any(), any()));
    expect(find.text('po.png'), findsOneWidget);
  });

  testWidgets('a failed removal keeps the file and Retry removes it', (tester) async {
    var failing = true;
    when(() => repository.deleteAttachment('d1', 'a1')).thenAnswer((_) async {
      if (failing) throw offline();
    });
    await tester.pumpWidget(build([_file('a1')]));

    await tester.tap(find.byKey(const Key('attachment-remove-a1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Check your connection and try again'), findsOneWidget);
    expect(find.text('po.png'), findsOneWidget);

    failing = false;
    await tester.tap(find.byKey(const Key('attachment-retry')));
    await tester.pumpAndSettle();

    expect(find.text('po.png'), findsNothing);
  });

  testWidgets('tapping a file opens it from the server', (tester) async {
    await tester.pumpWidget(build([_file('a1')]));

    await tester.tap(find.text('po.png'));
    await tester.pumpAndSettle();

    expect(opened.single.path, '/uploads/b1/po.png');
  });

  testWidgets('a file that cannot be opened says so and what to do', (tester) async {
    canOpen = false;
    await tester.pumpWidget(build([_file('a1')]));

    await tester.tap(find.text('po.png'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't open the file. Check your connection and try again"), findsOneWidget);
  });

  testWidgets('a photo over 5 MB is refused up front, saying what to do, with no pointless retry', (tester) async {
    picked = (bytes: List.filled(5 * 1024 * 1024 + 1, 0), name: 'big.jpg');
    await tester.pumpWidget(build([]));

    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.uploadAttachment(any(), any(), any()));
    expect(find.text('That photo is over 5 MB. Choose a smaller one or take it again'), findsOneWidget);
    expect(find.byKey(const Key('attachment-retry')), findsNothing);
  });

  testWidgets('a camera or photo access problem says how to fix it, and Retry asks again', (tester) async {
    pickerError = PlatformException(code: 'camera_access_denied');
    await tester.pumpWidget(build([]));

    await tester.tap(find.byKey(const Key('attachment-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't open the camera or photos. Allow access in your phone's settings, then try again"),
      findsOneWidget,
    );

    pickerError = null;
    when(() => repository.uploadAttachment('d1', [1, 2, 3], 'photo.jpg'))
        .thenAnswer((_) async => _file('a9', name: 'photo.jpg'));
    await tester.tap(find.byKey(const Key('attachment-retry')));
    await tester.pumpAndSettle();

    expect(find.text('photo.jpg'), findsOneWidget);
  });
}
