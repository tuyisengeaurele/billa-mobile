import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/domain/profile_repository.dart';
import 'package:billa_mobile/features/account/domain/user_profile.dart';
import 'package:billa_mobile/core/media/image_picker_provider.dart';
import 'package:billa_mobile/features/account/presentation/providers/current_user_provider.dart';
import 'package:billa_mobile/features/account/presentation/providers/profile_repository_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/profile_screen.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../support.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;
  late FakeAuthController auth;
  PickedImage? picked;

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    repository = _MockProfileRepository();
    auth = FakeAuthController();
    picked = (bytes: [1, 2, 3], name: 'me.png');
  });

  Widget buildApp({AuthUser user = testUser}) {
    auth = FakeAuthController(user);
    return accountApp(
      screen: const ProfileScreen(),
      path: '/settings/profile',
      overrides: [
        authControllerProvider.overrideWith(() => auth),
        profileRepositoryProvider.overrideWithValue(repository),
        imagePickerProvider.overrideWithValue(() async => picked),
      ],
    );
  }

  AuthUser? currentUser(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ProfileScreen))).read(currentUserProvider);

  testWidgets('saves the name and phone and updates the signed-in user', (tester) async {
    when(() => repository.updateProfile(name: 'Ada L', phone: '0799')).thenAnswer(
      (_) async => const UserProfile(id: 'u1', email: 'ada@example.com', name: 'Ada L', phone: '0799'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile-name')), 'Ada L');
    await tester.enterText(find.byKey(const Key('profile-phone')), '0799');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-save')));
    await tester.pumpAndSettle();

    verify(() => repository.updateProfile(name: 'Ada L', phone: '0799')).called(1);
    expect(currentUser(tester)!.name, 'Ada L');
    expect(currentUser(tester)!.phone, '0799');
  });

  testWidgets('a cleared phone is sent as null', (tester) async {
    when(() => repository.updateProfile(name: 'Ada', phone: null)).thenAnswer(
      (_) async => const UserProfile(id: 'u1', email: 'ada@example.com', name: 'Ada'),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile-phone')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-save')));
    await tester.pumpAndSettle();

    verify(() => repository.updateProfile(name: 'Ada', phone: null)).called(1);
    expect(currentUser(tester)!.phone, isNull);
  });

  testWidgets('a blank name disables Save', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('profile-name')), '   ');
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(find.byKey(const Key('profile-save'))).onPressed, isNull);
  });

  testWidgets('choosing a photo uploads it and stores the new url', (tester) async {
    when(() => repository.uploadAvatar([1, 2, 3], 'me.png')).thenAnswer((_) async => '/uploads/me.png');

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-avatar-change')));
    await tester.pumpAndSettle();

    verify(() => repository.uploadAvatar([1, 2, 3], 'me.png')).called(1);
    expect(currentUser(tester)!.avatarUrl, '/uploads/me.png');
  });

  testWidgets('backing out of the picker uploads nothing', (tester) async {
    picked = null;

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-avatar-change')));
    await tester.pumpAndSettle();

    verifyNever(() => repository.uploadAvatar(any(), any()));
  });

  testWidgets('a rejected image shows its message with a retry', (tester) async {
    when(() => repository.uploadAvatar([1, 2, 3], 'me.png')).thenThrow(apiError('invalid_file_type'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-avatar-change')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a PNG, JPG, or WebP image'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('removing the photo clears the avatar url', (tester) async {
    when(() => repository.removeAvatar()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp(user: testUser.copyWith(avatarUrl: '/uploads/old.png')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-avatar-remove')));
    await tester.pumpAndSettle();

    verify(() => repository.removeAvatar()).called(1);
    expect(currentUser(tester)!.avatarUrl, isNull);
    expect(find.byKey(const Key('profile-avatar-remove')), findsNothing);
  });
}
