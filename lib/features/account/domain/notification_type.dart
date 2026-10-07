enum NotificationType {
  invoiceOverdue('INVOICE_OVERDUE', 'Invoice overdue'),
  paymentReceived('PAYMENT_RECEIVED', 'Payment received'),
  memberJoined('MEMBER_JOINED', 'Team member joined'),
  contactMessageReceived('CONTACT_MESSAGE_RECEIVED', 'Contact message received'),
  documentAccepted('DOCUMENT_ACCEPTED', 'Document accepted'),
  documentDeclined('DOCUMENT_DECLINED', 'Document declined');

  const NotificationType(this.wireName, this.label);

  final String wireName;
  final String label;

  // Null for unknown names so a type the server adds later is skipped
  // instead of crashing a screen built before it existed.
  static NotificationType? fromWire(String name) {
    for (final type in values) {
      if (type.wireName == name) return type;
    }
    return null;
  }
}
