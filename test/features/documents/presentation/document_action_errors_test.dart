import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/documents/presentation/document_action_errors.dart';

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  test('maps every known error code to its message', () {
    expect(describeDocumentActionError(_error('no_lines')), 'Add at least one line before finalizing');
    expect(
      describeDocumentActionError(_error('finalize_requires_approval')),
      'Only the business owner can finalize documents',
    );
    expect(describeDocumentActionError(_error('already_finalized')), 'This document was already finalized');
    expect(
      describeDocumentActionError(_error('not_convertible')),
      "This document type can't be converted to an invoice",
    );
    expect(describeDocumentActionError(_error('not_finalized')), 'Finalize this document first');
    expect(describeDocumentActionError(_error('already_converted')), 'This was already converted to an invoice');
    expect(describeDocumentActionError(_error('already_declined')), 'The customer already declined this');
    expect(describeDocumentActionError(_error('customer_has_no_email')), 'This customer has no email on file');
    expect(describeDocumentActionError(_error('pdf_render_failed')), "Couldn't generate the PDF");
    expect(describeDocumentActionError(_error('email_send_failed')), "Couldn't send the email");
    expect(describeDocumentActionError(_error('not_an_invoice')), 'Only invoices support this action');
    expect(
      describeDocumentActionError(_error('amount_exceeds_owed')),
      "That's more than what's owed on this invoice",
    );
    expect(describeDocumentActionError(_error('already_voided')), 'This payment was already voided');
    expect(describeDocumentActionError(_error('already_paid')), 'This invoice is already fully paid');
    expect(describeDocumentActionError(_error('not_written_off')), "This invoice hasn't been written off");
    expect(
      describeDocumentActionError(_error('subscription_required')),
      'Subscription required to record payments',
    );
  });

  test('falls back to a generic message for an unknown code', () {
    expect(describeDocumentActionError(_error('something_else')), 'Something went wrong — try again');
  });

  test('falls back to a generic message for a non-Dio error', () {
    expect(describeDocumentActionError(Exception('boom')), 'Something went wrong — try again');
  });
}
