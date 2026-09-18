import 'package:dio/dio.dart';

String describeDocumentActionError(Object error) {
  final code = error is DioException ? (error.response?.data?['error'] as String?) : null;
  return switch (code) {
    'no_lines' => 'Add at least one line before finalizing',
    'finalize_requires_approval' => 'Only the business owner can finalize documents',
    'already_finalized' => 'This document was already finalized',
    'not_convertible' => "This document type can't be converted to an invoice",
    'not_finalized' => 'Finalize this document first',
    'already_converted' => 'This was already converted to an invoice',
    'already_declined' => 'The customer already declined this',
    'customer_has_no_email' => 'This customer has no email on file',
    'pdf_render_failed' => "Couldn't generate the PDF",
    'email_send_failed' => "Couldn't send the email",
    'not_an_invoice' => 'Only invoices support this action',
    'amount_exceeds_owed' => "That's more than what's owed on this invoice",
    'already_voided' => 'This payment was already voided',
    'already_paid' => 'This invoice is already fully paid',
    'not_written_off' => "This invoice hasn't been written off",
    'subscription_required' => 'Subscription required to record payments',
    _ => 'Something went wrong — try again',
  };
}
