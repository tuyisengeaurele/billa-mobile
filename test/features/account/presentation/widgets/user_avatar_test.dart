import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/account/presentation/widgets/user_avatar.dart';
import 'package:billa_mobile/features/auth/domain/auth_user.dart';

void main() {
  const plain = AuthUser(id: 'u1', email: 'ada@example.com', name: 'Ada', totpEnabled: false, isAdmin: false);

  testWidgets('shows the first initial when there is no photo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserAvatar(user: plain)));

    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('loads the photo through the disk cache', (tester) async {
    await tester.pumpWidget(MaterialApp(home: UserAvatar(user: plain.copyWith(avatarUrl: 'https://example.com/a.png'))));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<CachedNetworkImageProvider>());
  });
}
