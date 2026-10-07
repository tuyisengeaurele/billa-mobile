import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/activity/domain/activity_entry.dart';

void main() {
  test('reads who did what, to what, and when', () {
    final entry = ActivityEntry.fromJson({
      'id': 'e1',
      'action': 'DOCUMENT_FINALIZED',
      'entityType': 'Document',
      'metadata': {'number': 'INV-0001'},
      'createdAt': '2026-01-02T10:00:00.000Z',
      'actor': {'id': 'u1', 'name': 'Ada', 'email': 'ada@example.com'},
    });

    expect(entry.action, 'DOCUMENT_FINALIZED');
    expect(entry.metadata?['number'], 'INV-0001');
    expect(entry.actor?.name, 'Ada');
    expect(entry.actor?.email, 'ada@example.com');
  });

  test('copes with no actor and no metadata', () {
    final entry = ActivityEntry.fromJson({
      'id': 'e1',
      'action': 'MEMBER_JOINED',
      'entityType': null,
      'metadata': null,
      'createdAt': '2026-01-02T10:00:00.000Z',
      'actor': null,
    });

    expect(entry.actor, isNull);
    expect(entry.metadata, isNull);
  });
}
