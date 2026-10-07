import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/businesses/domain/business_summary.dart';
import 'package:billa_mobile/features/businesses/domain/invite_preview.dart';
import 'package:billa_mobile/features/businesses/domain/leave_result.dart';

void main() {
  test('BusinessSummary.fromJson parses ownership', () {
    final summary = BusinessSummary.fromJson({'id': 'b1', 'name': 'Acme', 'isOwner': true});

    expect(summary.name, 'Acme');
    expect(summary.isOwner, isTrue);
  });

  test('InvitePreview.fromJson parses the public preview', () {
    final preview = InvitePreview.fromJson({
      'email': 'new@example.com',
      'businessName': 'Acme',
      'expired': false,
      'alreadyAccepted': true,
    });

    expect(preview.businessName, 'Acme');
    expect(preview.alreadyAccepted, isTrue);
  });

  test('LeaveResult.fromJson tolerates a partial business', () {
    final result = LeaveResult.fromJson({
      'business': {'id': 'b2', 'name': 'My Business'},
      'createdReplacement': true,
    });

    expect(result.business.id, 'b2');
    expect(result.business.onboardingCompletedAt, isNull);
    expect(result.createdReplacement, isTrue);
  });
}
