import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/activity/domain/activity_entry.dart';
import 'package:billa_mobile/features/activity/domain/activity_labels.dart';

ActivityEntry _entry(String action, {Map<String, dynamic>? metadata, ActivityActor? actor}) => ActivityEntry(
      id: 'e1',
      action: action,
      createdAt: '2026-01-02T10:00:00.000Z',
      metadata: metadata,
      actor: actor,
    );

void main() {
  test('says what happened to a document by its number, or its kind when it has none', () {
    expect(describeActivity(_entry('DOCUMENT_FINALIZED', metadata: {'number': 'INV-0001'})), 'finalized INV-0001');
    expect(describeActivity(_entry('DOCUMENT_FINALIZED', metadata: {'type': 'QUOTE'})), 'finalized a quote');
    expect(describeActivity(_entry('DOCUMENT_CREATED', metadata: {'type': 'INVOICE'})), 'created an invoice');
    expect(describeActivity(_entry('DOCUMENT_DELETED', metadata: {'type': 'PROFORMA'})), 'deleted a proforma invoice');
    expect(describeActivity(_entry('DOCUMENT_SHARED', metadata: {'number': 'INV-0001'})), 'shared INV-0001 on WhatsApp');
    expect(describeActivity(_entry('DOCUMENT_CREATED')), 'created a document');
  });

  test('names the customer or the person when the entry has one', () {
    expect(describeActivity(_entry('CUSTOMER_CREATED', metadata: {'name': 'Acme'})), 'added customer Acme');
    expect(describeActivity(_entry('CUSTOMER_CREATED')), 'added a customer');
    expect(describeActivity(_entry('CUSTOMER_DEACTIVATED', metadata: {'name': 'Acme'})), 'deactivated customer Acme');
    expect(describeActivity(_entry('MEMBER_INVITED', metadata: {'email': 'b@x.com'})), 'invited b@x.com');
    expect(describeActivity(_entry('MEMBER_INVITED')), 'invited a team member');
    expect(describeActivity(_entry('MEMBER_JOINED')), 'joined the team');
    expect(describeActivity(_entry('MEMBER_REMOVED', metadata: {'email': 'b@x.com'})), 'removed b@x.com');
    expect(
      describeActivity(_entry('MEMBER_IMPERSONATION_STARTED', metadata: {'email': 'b@x.com'})),
      'viewed the account as b@x.com',
    );
    expect(
      describeActivity(_entry('MEMBER_IMPERSONATION_ENDED', metadata: {'email': 'b@x.com'})),
      'stopped viewing the account as b@x.com',
    );
  });

  test('an action the phone has no wording for reads as plain words, not as a code', () {
    expect(describeActivity(_entry('MEMBER_IMPERSONATION_ENDED_BY_TARGET')), 'member impersonation ended by target');
  });

  test('names the person who did it, by name then email, and says someone when unknown', () {
    expect(activityActorName(_entry('X', actor: const ActivityActor(name: 'Ada', email: 'ada@x.com'))), 'Ada');
    expect(activityActorName(_entry('X', actor: const ActivityActor(name: '', email: 'ada@x.com'))), 'ada@x.com');
    expect(activityActorName(_entry('X')), 'Someone');
  });
}
