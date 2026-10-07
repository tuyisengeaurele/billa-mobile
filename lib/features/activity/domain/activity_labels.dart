import 'activity_entry.dart';

const _documentKinds = {
  'INVOICE': 'an invoice',
  'PROFORMA': 'a proforma invoice',
  'DELIVERY_NOTE': 'a delivery note',
  'QUOTE': 'a quote',
  'RECEIPT': 'a receipt',
  'CREDIT_NOTE': 'a credit note',
};

String? _text(Map<String, dynamic>? metadata, String key) {
  final value = metadata?[key];
  return value is String && value.isNotEmpty ? value : null;
}

/// What the entry says happened, worded like the web app so the same event reads the same on both. An action the
/// phone has no wording for becomes plain lowercase words rather than a raw code.
String describeActivity(ActivityEntry entry) {
  final metadata = entry.metadata;
  final type = _text(metadata, 'type');
  final number = _text(metadata, 'number');
  final name = _text(metadata, 'name');
  final email = _text(metadata, 'email');
  final kind = type == null ? 'a document' : (_documentKinds[type] ?? 'a document');

  return switch (entry.action) {
    'DOCUMENT_CREATED' => 'created $kind',
    'DOCUMENT_FINALIZED' => 'finalized ${number ?? kind}',
    'DOCUMENT_DELETED' => 'deleted $kind',
    'DOCUMENT_SHARED' => 'shared ${number ?? kind} on WhatsApp',
    'CUSTOMER_CREATED' => name == null ? 'added a customer' : 'added customer $name',
    'CUSTOMER_DEACTIVATED' => name == null ? 'deactivated a customer' : 'deactivated customer $name',
    'MEMBER_INVITED' => email == null ? 'invited a team member' : 'invited $email',
    'MEMBER_JOINED' => 'joined the team',
    'MEMBER_REMOVED' => email == null ? 'removed a team member' : 'removed $email',
    'MEMBER_IMPERSONATION_STARTED' =>
      email == null ? "viewed a team member's account" : 'viewed the account as $email',
    'MEMBER_IMPERSONATION_ENDED' =>
      email == null ? "stopped viewing a team member's account" : 'stopped viewing the account as $email',
    final other => other.toLowerCase().replaceAll('_', ' '),
  };
}

/// Who did it: their name, else their email, else "Someone" for an entry with no person behind it.
String activityActorName(ActivityEntry entry) {
  final name = entry.actor?.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  final email = entry.actor?.email?.trim();
  if (email != null && email.isNotEmpty) return email;
  return 'Someone';
}
