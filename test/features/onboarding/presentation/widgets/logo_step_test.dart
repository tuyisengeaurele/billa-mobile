import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/media/image_picker_provider.dart';
import 'package:billa_mobile/features/onboarding/data/logo_pipeline_service.dart';
import 'package:billa_mobile/features/onboarding/domain/logo_pipeline_step.dart';
import 'package:billa_mobile/features/onboarding/presentation/widgets/logo_step.dart';

class _MockLogoPipelineService extends Mock implements LogoPipelineService {}

const _stages = [
  LogoPipelineStage.uploading,
  LogoPipelineStage.checkingBackground,
  LogoPipelineStage.extractingColors,
  LogoPipelineStage.done,
];

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockLogoPipelineService service;
  late int doneCalls;
  PickedImage? picked;

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    service = _MockLogoPipelineService();
    doneCalls = 0;
    picked = (bytes: [1, 2, 3], name: 'logo.png');
    when(() => service.result).thenReturn(
      const LogoPipelineResult(url: '/uploads/l.png', primaryColor: '#112233', accentColors: []),
    );
  });

  Widget buildApp() => ProviderScope(
        overrides: [imagePickerProvider.overrideWithValue(() async => picked)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: LogoStep(
              service: service,
              onDone: () async => doneCalls++,
              onSkip: () {},
            ),
          ),
        ),
      );

  Future<void> choose(WidgetTester tester) async {
    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();
  }

  testWidgets('a completed pipeline shows the colour and Confirm finishes the step', (tester) async {
    when(() => service.run(any(), any())).thenAnswer((_) => Stream.fromIterable(_stages));
    when(() => service.confirm()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await choose(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    verify(() => service.run([1, 2, 3], 'logo.png')).called(1);
    verify(() => service.confirm()).called(1);
    expect(doneCalls, 1);
  });

  testWidgets('backing out of the picker does nothing', (tester) async {
    picked = null;

    await tester.pumpWidget(buildApp());
    await choose(tester);

    verifyNever(() => service.run(any(), any()));
    expect(find.text('Choose a photo'), findsOneWidget);
  });

  testWidgets('a failing stage stops the spinner, shows its message, and Retry re-runs the same image', (tester) async {
    var attempts = 0;
    when(() => service.run(any(), any())).thenAnswer((_) {
      attempts++;
      return attempts == 1
          ? Stream<LogoPipelineStage>.error(_error('invalid_file_type'))
          : Stream.fromIterable(_stages);
    });
    when(() => service.confirm()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await choose(tester);

    expect(find.text('Choose a PNG, JPG, or WebP image'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => service.run([1, 2, 3], 'logo.png')).called(2);
    expect(find.text('Choose a PNG, JPG, or WebP image'), findsNothing);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('a failed confirm shows its message and Retry confirms again', (tester) async {
    var confirms = 0;
    when(() => service.run(any(), any())).thenAnswer((_) => Stream.fromIterable(_stages));
    when(() => service.confirm()).thenAnswer((_) async {
      confirms++;
      if (confirms == 1) throw _error('forbidden');
    });

    await tester.pumpWidget(buildApp());
    await choose(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text("You don't have permission to use that file"), findsOneWidget);
    expect(doneCalls, 0);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(confirms, 2);
    expect(doneCalls, 1);
  });

  testWidgets('a failure while finishing onboarding is shown too, and Confirm stays usable', (tester) async {
    when(() => service.run(any(), any())).thenAnswer((_) => Stream.fromIterable(_stages));
    when(() => service.confirm()).thenAnswer((_) async {});

    var attempts = 0;
    final app = ProviderScope(
      overrides: [imagePickerProvider.overrideWithValue(() async => picked)],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: LogoStep(
            service: service,
            onDone: () async {
              attempts++;
              if (attempts == 1) throw _error('server_error');
            },
            onSkip: () {},
          ),
        ),
      ),
    );

    await tester.pumpWidget(app);
    await choose(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong — try again'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Confirm')).onPressed, isNotNull);
  });
}
