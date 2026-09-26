import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/errors/action_errors.dart';

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  test('maps every known error code to its message', () {
    expect(describeActionError(_error('no_lines')), 'Add at least one line before finalizing');
    expect(
      describeActionError(_error('finalize_requires_approval')),
      'Only the business owner can finalize documents',
    );
    expect(describeActionError(_error('already_finalized')), 'This document was already finalized');
    expect(
      describeActionError(_error('not_convertible')),
      "This document type can't be converted to an invoice",
    );
    expect(describeActionError(_error('not_finalized')), 'Finalize this document first');
    expect(describeActionError(_error('already_converted')), 'This was already converted to an invoice');
    expect(describeActionError(_error('already_declined')), 'The customer already declined this');
    expect(describeActionError(_error('customer_has_no_email')), 'This customer has no email on file');
    expect(describeActionError(_error('pdf_render_failed')), "Couldn't generate the PDF");
    expect(describeActionError(_error('email_send_failed')), "Couldn't send the email");
    expect(describeActionError(_error('not_an_invoice')), 'Only invoices support this action');
    expect(
      describeActionError(_error('amount_exceeds_owed')),
      "That's more than what's owed on this invoice",
    );
    expect(describeActionError(_error('already_voided')), 'This payment was already voided');
    expect(describeActionError(_error('already_paid')), 'This invoice is already fully paid');
    expect(describeActionError(_error('not_written_off')), "This invoice hasn't been written off");
    expect(
      describeActionError(_error('subscription_required')),
      'An active subscription is required to do that',
    );
    expect(describeActionError(_error('read_only_role')), 'Your role on this business is read-only');
    expect(describeActionError(_error('business_limit_reached')), "You've reached the limit of 3 businesses");
    expect(describeActionError(_error('already_member')), 'That person is already on this team');
    expect(describeActionError(_error('no_access')), "You don't have access to that business");
    expect(describeActionError(_error('owner_cannot_leave')), "Owners can't leave their own business");
    expect(describeActionError(_error('not_a_member')), "You're not a member of this business");
    expect(
      describeActionError(_error('email_mismatch')),
      'This invite was sent to a different email address',
    );
    expect(describeActionError(_error('expired')), 'This invite has expired');
    expect(describeActionError(_error('already_accepted')), 'This invite was already accepted');
    expect(describeActionError(_error('not_found')), "We couldn't find that. It may have been removed");
    expect(describeActionError(_error('invalid_code')), "That code isn't right. Try again");
    expect(describeActionError(_error('not_enabled')), "Two-factor sign-in isn't turned on");
    expect(
      describeActionError(_error('has_admin_history')),
      "This account can't be deleted because it has administrator history",
    );
    expect(describeActionError(_error('upload_failed')), 'The upload failed. Try again');
    expect(describeActionError(_error('invalid_file_type')), 'Choose a PNG, JPG, or WebP image');
    expect(describeActionError(_error('no_file')), 'Choose an image first');
    expect(describeActionError(_error('not_owner')), 'Only the business owner can change this');
    expect(describeActionError(_error('forbidden')), "You don't have permission to use that file");
  });

  test('an unknown server code is kept as a short support code', () {
    expect(describeActionError(_error('something_else')), 'Something went wrong. Try again (code: something_else)');
  });

  test('a server failure with no error body is reported by its status', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: 502, data: '<html>Bad gateway</html>'),
    );

    expect(describeActionError(error), 'Something went wrong. Try again (code: 502)');
  });

  test('a known code never carries a support code, since the message already explains it', () {
    expect(describeActionError(_error('no_lines')).contains('code:'), isFalse);
  });

  test('a rate limit and a dropped connection stay free of codes', () {
    expect(describeActionError(DioException(requestOptions: RequestOptions(path: '/x'))).contains('code:'), isFalse);
  });

  test('falls back to a generic message for a non-Dio error', () {
    expect(describeActionError(Exception('boom')), 'Something went wrong. Try again');
  });

  test('a request that never got a response asks the user to check their connection', () {
    final offline = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );

    expect(describeActionError(offline), 'Check your connection and try again');
  });

  test('an expired sign-in challenge and a rate limit each get their own message', () {
    expect(describeActionError(_error('invalid_challenge')), 'This sign-in expired. Log in again');

    final limited = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), statusCode: 429, data: 'Too many requests'),
    );
    expect(describeActionError(limited), 'Too many attempts. Wait a few minutes and try again');
  });
}
