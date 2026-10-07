import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/media/image_picker_provider.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/presentation/screens/logo_screen.dart';
import 'package:billa_mobile/features/onboarding/data/logo_pipeline_service.dart';
import 'package:billa_mobile/features/onboarding/domain/logo_pipeline_step.dart';
import 'package:billa_mobile/features/onboarding/presentation/providers/logo_pipeline_provider.dart';
import '../../support.dart';

class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

class _MockLogoPipelineService extends Mock implements LogoPipelineService {}

const _stages = [
  LogoPipelineStage.uploading,
  LogoPipelineStage.checkingBackground,
  LogoPipelineStage.extractingColors,
  LogoPipelineStage.done,
];

void main() {
  late _MockBusinessSettingsRepository repository;
  late _MockLogoPipelineService service;
  PickedImage? picked;

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    repository = _MockBusinessSettingsRepository();
    service = _MockLogoPipelineService();
    picked = (bytes: [1, 2], name: 'logo.png');
    when(() => repository.get()).thenAnswer((_) async => testSettings);
    when(() => service.result).thenReturn(
      const LogoPipelineResult(url: '/uploads/new.png', primaryColor: '#112233', accentColors: ['#445566']),
    );
  });

  Widget buildApp() => businessSettingsApp(
        screen: const LogoScreen(),
        path: '/settings/business/logo',
        overrides: [
          businessSettingsRepositoryProvider.overrideWithValue(repository),
          logoPipelineServiceProvider.overrideWithValue(service),
          imagePickerProvider.overrideWithValue(() async => picked),
        ],
      );

  testWidgets('a chosen image runs the pipeline and offers the extracted colour', (tester) async {
    when(() => service.run(any(), any())).thenAnswer((_) => Stream.fromIterable(_stages));

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('logo-choose')));
    await tester.pumpAndSettle();

    verify(() => service.run([1, 2], 'logo.png')).called(1);
    expect(find.text('New primary color #112233'), findsOneWidget);
    expect(find.byKey(const Key('logo-confirm')), findsOneWidget);
  });

  testWidgets('shows the stage while the pipeline is running', (tester) async {
    final controller = StreamController<LogoPipelineStage>();
    addTearDown(controller.close);
    when(() => service.run(any(), any())).thenAnswer((_) => controller.stream);

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('logo-choose')));
    await tester.pump();
    controller.add(LogoPipelineStage.checkingBackground);
    await tester.pump();

    expect(find.text('Checking background…'), findsOneWidget);
  });

  testWidgets('confirming saves the logo and reloads the settings', (tester) async {
    when(() => service.run(any(), any())).thenAnswer((_) => Stream.fromIterable(_stages));
    when(() => service.confirm()).thenAnswer((_) async {});

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('logo-choose')));
    await tester.pumpAndSettle();
    clearInteractions(repository);
    await tester.tap(find.byKey(const Key('logo-confirm')));
    await tester.pumpAndSettle();

    verify(() => service.confirm()).called(1);
    verify(() => repository.get()).called(1);
    expect(find.text('Logo saved'), findsOneWidget);
    expect(find.byKey(const Key('logo-confirm')), findsNothing);
  });

  testWidgets('backing out of the picker does nothing', (tester) async {
    picked = null;

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('logo-choose')));
    await tester.pumpAndSettle();

    verifyNever(() => service.run(any(), any()));
  });

  testWidgets('a failing stage shows its message and Retry re-runs the same image', (tester) async {
    var attempts = 0;
    when(() => service.run(any(), any())).thenAnswer((_) {
      attempts++;
      return attempts == 1 ? Stream<LogoPipelineStage>.error(apiError('invalid_file_type')) : Stream.fromIterable(_stages);
    });

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('logo-choose')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a PNG, JPG, or WebP image'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => service.run([1, 2], 'logo.png')).called(2);
    expect(find.byKey(const Key('logo-confirm')), findsOneWidget);
  });

  testWidgets('a failed confirm shows its message with a retry', (tester) async {
    when(() => service.run(any(), any())).thenAnswer((_) => Stream.fromIterable(_stages));
    when(() => service.confirm()).thenAnswer((_) async => throw apiError('forbidden'));

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('logo-choose')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logo-confirm')));
    await tester.pumpAndSettle();

    expect(find.text("You don't have permission to use that file"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
